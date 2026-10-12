import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;
import Toybox.WatchUi;

// Visible area of the Instinct 2, and checks that drawn text stays inside it. Measured from the
// display opening in the SDK's simulator image of the watch (Devices/instinct2/instinct2.png,
// screen at 99,164):
//   - the 176x176 screen, clipped by a disk of radius 98 around its center (88,88);
//   - minus the subscreen lens: its window is a disk of radius 31 around (144,31), and the opaque
//     ring around the window reaches radius 44, so text outside the subscreen keeps clear of the ring.
// The glance keeps to the inscribed circle (radius 88) instead: where the lower slots of the glance
// loop place it is not known, and the deeper indent keeps it off the round edge there too.
// Text boxes span the full font height (ascent + descent), as accented capitals reach the ascent.
(:test)
module ScreenArea {

    const SIZE = Layout.SCREEN_SIZE;
    const CENTER = Layout.SCREEN_SIZE / 2;
    const DISPLAY_RADIUS = 98;
    const GLANCE_RADIUS = 88;
    const SUBSCREEN_X = 144;
    const SUBSCREEN_Y = 31;
    const SUBSCREEN_RADIUS = 31;
    const RING_RADIUS = 44;
    const MARGIN = 2;
    // Screen position and width of the glance content area in the selected slot.
    const GLANCE_X = 9;
    const GLANCE_Y = 19;
    const GLANCE_WIDTH = 164;

    function measuringDc() as Dc {
        return new Graphics.BufferedBitmap({:width => SIZE, :height => SIZE}).getDc();
    }

    // Box [left, top, right, bottom] of the item, measured with the real font.
    function measure(dc as Dc, item as Layout.TextItem) as Array<Float> {
        var size = dc.getTextDimensions(item.text, item.font);
        return Layout.textBox(item, size[0], size[1]);
    }

    function offset(box as Array<Float>, dx as Number, dy as Number) as Array<Float> {
        return [box[0] + dx, box[1] + dy, box[2] + dx, box[3] + dy] as Array<Float>;
    }

    function boxInRect(box as Array<Float>, left as Numeric, top as Numeric, right as Numeric, bottom as Numeric) as Boolean {
        return box[0] >= left && box[1] >= top && box[2] <= right && box[3] <= bottom;
    }

    // True when all 4 corners of the box lie within radius of (cx, cy): the farthest one does.
    function boxInDisk(box as Array<Float>, cx as Numeric, cy as Numeric, radius as Numeric) as Boolean {
        var dx = farther(box[0] - cx, box[2] - cx);
        var dy = farther(box[1] - cy, box[3] - cy);
        return dx * dx + dy * dy <= radius * radius;
    }

    // True when the box point closest to (cx, cy) is farther than radius.
    function boxClearOfDisk(box as Array<Float>, cx as Numeric, cy as Numeric, radius as Numeric) as Boolean {
        var dx = clamp(cx, box[0], box[2]) - cx;
        var dy = clamp(cy, box[1], box[3]) - cy;
        return dx * dx + dy * dy > radius * radius;
    }

    // Screen box inside the display (the given radius) with the margin, and clear of the subscreen ring.
    function visibleOnScreen(box as Array<Float>, displayRadius as Number) as Boolean {
        return boxInRect(box, MARGIN, MARGIN, SIZE - MARGIN, SIZE - MARGIN)
            && boxInDisk(box, CENTER, CENTER, displayRadius - MARGIN)
            && boxClearOfDisk(box, SUBSCREEN_X, SUBSCREEN_Y, RING_RADIUS + MARGIN);
    }

    // Screen box inside the subscreen window with the margin.
    function insideSubscreen(box as Array<Float>) as Boolean {
        return boxInDisk(box, SUBSCREEN_X, SUBSCREEN_Y, SUBSCREEN_RADIUS - MARGIN);
    }

    function describe(text as String, box as Array<Float>) as String {
        return "'" + text + "' [" + box[0].format("%.1f") + "," + box[1].format("%.1f") + " .. "
            + box[2].format("%.1f") + "," + box[3].format("%.1f") + "]";
    }

    function farther(a as Float, b as Float) as Float {
        a = a < 0 ? -a : a;
        b = b < 0 ? -b : b;
        return a > b ? a : b;
    }

    function clamp(value as Numeric, low as Float, high as Float) as Float {
        if (value < low) {
            return low;
        }
        if (value > high) {
            return high;
        }
        return value.toFloat();
    }
}

(:test)
function geometryChecksCornersAndClosestPoints(logger as Logger) as Boolean {
    // A 10x10 box whose far corner (110,110) is 14.1 from (100,100).
    var box = [100.0, 100.0, 110.0, 110.0] as Array<Float>;
    var inDisk = ScreenArea.boxInDisk(box, 100, 100, 15) && !ScreenArea.boxInDisk(box, 100, 100, 14);
    // The closest point to (95,105) is (100,105), 5 away; to (90,90) the corner (100,100), 14.1 away.
    var clear = ScreenArea.boxClearOfDisk(box, 95, 105, 4) && !ScreenArea.boxClearOfDisk(box, 95, 105, 5)
        && ScreenArea.boxClearOfDisk(box, 90, 90, 14) && !ScreenArea.boxClearOfDisk(box, 90, 90, 15)
        && !ScreenArea.boxClearOfDisk(box, 105, 105, 30);
    var center = Layout.textBox(new Layout.TextItem("x", Graphics.FONT_TINY, 50, 40,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER), 30, 23);
    var right = Layout.textBox(new Layout.TextItem("x", Graphics.FONT_TINY, 50, 40, Graphics.TEXT_JUSTIFY_RIGHT), 30, 23);
    logger.debug("inDisk=" + inDisk + " clear=" + clear + " center=" + center + " right=" + right);
    return inDisk && clear
        && center[0] == 35.0 && center[1] == 28.5 && center[2] == 65.0 && center[3] == 51.5
        && right[0] == 20.0 && right[1] == 40.0 && right[2] == 50.0 && right[3] == 63.0;
}

// Every label the glance shows, for each mystery set, stays inside the selected glance slot and the
// visible area: off the round edge and clear of the subscreen.
(:test)
function glanceTextStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var seen = {} as Dictionary<String, Boolean>;
    var ok = true;
    for (var set = 0; set < 4; set++) {
        // -1 is a day not started yet and STEP_COUNT a finished rosary.
        for (var position = -1; position <= Rosary.STEP_COUNT; position++) {
            var items = Layout.glancePlan(set as Rosary.MysterySet, position, Layout.GLANCE_HEIGHT);
            for (var i = 0; i < items.size(); i++) {
                var item = items[i];
                var key = item.text + "@" + item.x + "," + item.y;
                if (seen.hasKey(key)) {
                    continue;
                }
                seen[key] = true;
                var box = ScreenArea.measure(dc, item);
                var screen = ScreenArea.offset(box, ScreenArea.GLANCE_X, ScreenArea.GLANCE_Y);
                var fits = ScreenArea.boxInRect(box, 0, 0, ScreenArea.GLANCE_WIDTH, Layout.GLANCE_HEIGHT)
                    && ScreenArea.visibleOnScreen(screen, ScreenArea.GLANCE_RADIUS);
                logger.debug((fits ? "fits " : "OUT ") + ScreenArea.describe(item.text, screen));
                ok = ok && fits;
            }
        }
    }
    return ok;
}

// Every text the main screen draws, for each of the 72 steps of each mystery set, stays inside the
// visible area and clear of the subscreen ring; the Avemaría number (the only FONT_NUMBER_MILD text)
// sits centered inside the subscreen window instead. The blocks keep their top-to-bottom order
// without overlapping, and wrapping never cuts a title or a mystery short.
(:test)
function mainScreenTextStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
    var seen = {} as Dictionary<String, Boolean>;
    var ok = true;
    for (var set = 0; set < 4; set++) {
        var titles = {} as Dictionary<Number, Array<String>>;
        var mysteries = {} as Dictionary<Number, Array<String>>;
        for (var step = 0; step < Rosary.STEP_COUNT; step++) {
            var decade = Rosary.decadeAt(step);
            if (!titles.hasKey(decade)) {
                // Wrapping is slow, and both texts depend only on the decade.
                var title = Rosary.decadeTitle(step, set as Rosary.MysterySet);
                var mystery = Rosary.subtitle(step, set as Rosary.MysterySet);
                titles[decade] = MainLayout.wrapTitle(title);
                mysteries[decade] = MainLayout.wrapMystery(mystery);
                ok = LayoutCheck.wrapsWhole(title, titles[decade] as Array<String>, 3, logger) && ok;
                ok = LayoutCheck.wrapsWhole(mystery, mysteries[decade] as Array<String>, 2, logger) && ok;
            }
            var items = MainLayout.plan(step, "00:00", clockFont, titles[decade] as Array<String>,
                mysteries[decade] as Array<String>, ScreenArea.SUBSCREEN_X, ScreenArea.SUBSCREEN_Y);
            ok = LayoutCheck.blocksInOrder(dc, items, logger) && ok;
            for (var i = 0; i < items.size(); i++) {
                ok = LayoutCheck.mainItemFits(dc, items[i], seen, logger) && ok;
            }
        }
    }
    var boxes = MainLayout.boxesBounds();
    var boxesFit = ScreenArea.visibleOnScreen([boxes[0].toFloat(), boxes[1].toFloat(), boxes[2].toFloat(), boxes[3].toFloat()] as Array<Float>,
        ScreenArea.DISPLAY_RADIUS);
    logger.debug((boxesFit ? "fits " : "OUT ") + "progress boxes " + boxes);
    return ok && boxesFit;
}

// The clock fits for every time it can show, in 12h and 24h: every digit in every position.
(:test)
function mainScreenClockStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
    var seen = {} as Dictionary<String, Boolean>;
    var minutes = [0, 11, 22, 33, 44, 55, 6, 17, 28, 39];
    var ok = true;
    for (var hour = 0; hour < 24; hour++) {
        for (var m = 0; m < minutes.size(); m++) {
            for (var mode = 0; mode < 2; mode++) {
                var text = Rosary.formatClock(hour, minutes[m], mode == 0);
                var items = MainLayout.plan(0, text, clockFont, ["Inicio"] as Array<String>, ["Misterios Gozosos"] as Array<String>,
                    ScreenArea.SUBSCREEN_X, ScreenArea.SUBSCREEN_Y);
                ok = LayoutCheck.mainItemFits(dc, items[0], seen, logger) && ok;
            }
        }
    }
    return ok;
}

(:test)
module LayoutCheck {

    // Checks one main-screen item, logging each distinct text and position once.
    function mainItemFits(dc as Dc, item as Layout.TextItem, seen as Dictionary<String, Boolean>, logger as Logger) as Boolean {
        var box = ScreenArea.measure(dc, item);
        var inSubscreen = item.font == Graphics.FONT_NUMBER_MILD;
        var fits;
        if (inSubscreen) {
            var centerX = (box[0] + box[2]) / 2;
            var centerY = (box[1] + box[3]) / 2;
            fits = ScreenArea.insideSubscreen(box)
                && centerX == ScreenArea.SUBSCREEN_X.toFloat() && centerY == ScreenArea.SUBSCREEN_Y.toFloat();
        } else {
            fits = ScreenArea.visibleOnScreen(box, ScreenArea.DISPLAY_RADIUS);
        }
        var key = item.text + "@" + item.x + "," + item.y;
        if (!seen.hasKey(key)) {
            seen[key] = true;
            logger.debug((fits ? "fits " : "OUT ") + (inSubscreen ? "subscreen " : "") + ScreenArea.describe(item.text, box));
        }
        return fits;
    }

    // The clock, the title, the mystery and the prayer stack top to bottom, above the progress boxes,
    // without their boxes overlapping. Items come in that order; the subscreen number is left out.
    function blocksInOrder(dc as Dc, items as Array<Layout.TextItem>, logger as Logger) as Boolean {
        var bottom = 0.0;
        var previous = "";
        var ok = true;
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            if (item.font == Graphics.FONT_NUMBER_MILD) {
                continue;
            }
            var box = ScreenArea.measure(dc, item);
            // Lines of one wrapped block share x and step down by their pitch; only blocks are compared.
            var sameBlock = i > 0 && items[i - 1].x == item.x && items[i - 1].font == item.font && items[i - 1].y < item.y
                && item.font == Graphics.FONT_TINY;
            if (!sameBlock && box[1] < bottom) {
                logger.debug("OVERLAP '" + item.text + "' top " + box[1] + " under '" + previous + "' bottom " + bottom);
                ok = false;
            }
            bottom = box[3];
            previous = item.text;
        }
        var boxesTop = MainLayout.boxesBounds()[1];
        if (bottom > boxesTop) {
            logger.debug("OVERLAP progress boxes top " + boxesTop + " under '" + previous + "' bottom " + bottom);
            ok = false;
        }
        return ok;
    }

    // Wrapping kept every word (no "..." cut) in at most maxLines lines.
    function wrapsWhole(text as String, lines as Array<String>, maxLines as Number, logger as Logger) as Boolean {
        var joined = "";
        for (var i = 0; i < lines.size(); i++) {
            joined += (i > 0 ? " " : "") + lines[i];
        }
        var ok = lines.size() <= maxLines && joined.equals(text);
        if (!ok) {
            logger.debug("CUT '" + text + "' -> " + lines);
        }
        return ok;
    }
}
