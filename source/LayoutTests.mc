import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Test;
import Toybox.WatchUi;

// Checks that drawn text stays inside the visible area of the Instinct 2: the per-row table the
// watch face uses (VisibleArea.mc), with a 2px margin. The Avemaría number is the one text drawn in
// the subscreen window instead, a disk of radius 31 around (144,31) inside the lens ring.
// Text boxes span the full font height (ascent + descent), as accented capitals reach the ascent. Every
// test that measures a text measures it in each language in turn (TestLanguage.use).
(:test)
module ScreenArea {

    const SIZE = Layout.SCREEN_SIZE;
    const SUBSCREEN_X = 144;
    const SUBSCREEN_Y = 31;
    const SUBSCREEN_RADIUS = 31;
    const MARGIN = 2;
    // Screen position and width of the glance content area (164x62) in the selected slot of the glance
    // loop. On the watch the selected glance is the lower band, with the selection bar on its left. Measured
    // from the user's photo of the Instinct 2 (about 4.66 photo px per screen px; the subscreen circle lands
    // at about (140,30), consistent with (144,31)): the bar spans screen rows 74..136, the 62px content
    // height, and "Gozosos" starts at screen x 17 to 18, the content's x 9 plus Layout.GLANCE_LEFT. The band
    // above it, beside the lens (at 9,19 in the simulator), shows the previous glance unselected; text there
    // may run under the lens, which the user accepts, so it is not checked.
    const GLANCE_X = 9;
    const GLANCE_Y = 74;
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

    // Screen box inside the visible main display with the margin.
    function visible(box as Array<Float>) as Boolean {
        return VisibleArea.boxFits(box, MARGIN);
    }

    // Screen box inside the subscreen window with the margin.
    function insideSubscreen(box as Array<Float>) as Boolean {
        return boxInDisk(box, SUBSCREEN_X, SUBSCREEN_Y, SUBSCREEN_RADIUS - MARGIN);
    }

    function describe(text as String, box as Array<Float>) as String {
        return "'" + text + "' [" + box[0].format("%.1f") + "," + box[1].format("%.1f") + " .. "
            + box[2].format("%.1f") + "," + box[3].format("%.1f") + "]";
    }

    // The text, its screen box and the margin it keeps inside the visible area (-1: cut).
    function describeVisible(text as String, box as Array<Float>) as String {
        return describe(text, box) + " margin " + VisibleArea.marginOf(box, 9);
    }

    // The system font's name, for logs and pins.
    function fontName(font as Graphics.FontType) as String {
        var fonts = [Graphics.FONT_XTINY, Graphics.FONT_TINY, Graphics.FONT_SMALL, Graphics.FONT_MEDIUM, Graphics.FONT_LARGE];
        var names = ["xtiny", "tiny", "small", "medium", "large"];
        for (var i = 0; i < fonts.size(); i++) {
            if (fonts[i] == font) {
                return names[i];
            }
        }
        return font.toString();
    }

    function farther(a as Float, b as Float) as Float {
        a = a < 0 ? -a : a;
        b = b < 0 ? -b : b;
        return a > b ? a : b;
    }
}

(:test)
function geometryChecksCornersAndClosestPoints(logger as Logger) as Boolean {
    // A 10x10 box whose far corner (110,110) is 14.1 from (100,100).
    var box = [100.0, 100.0, 110.0, 110.0] as Array<Float>;
    var inDisk = ScreenArea.boxInDisk(box, 100, 100, 15) && !ScreenArea.boxInDisk(box, 100, 100, 14);
    // Rows 73..135 span the full width (0..175): a box fits with the margin on both sides only.
    var fullWidth = VisibleArea.boxFits([2.0, 80.0, 173.0, 100.0] as Array<Float>, 2)
        && !VisibleArea.boxFits([1.0, 80.0, 173.0, 100.0] as Array<Float>, 2)
        && !VisibleArea.boxFits([2.0, 80.0, 174.0, 100.0] as Array<Float>, 2);
    // The margin covers rows too: rows 73..135 span the full width, but row 72 ends at 136 (the lens
    // ring), so a box from row 74 keeps only 1px and one from row 75 keeps 2px.
    var rowMargin = VisibleArea.marginOf([50.0, 75.0, 135.0, 90.0] as Array<Float>, 9) == 2
        && VisibleArea.marginOf([50.0, 74.0, 135.0, 90.0] as Array<Float>, 9) == 1;
    // Off the bottom of the screen is never visible; the top rows narrow toward the corner.
    var edges = VisibleArea.marginOf([50.0, 170.0, 60.0, 180.0] as Array<Float>, 9) == -1
        && VisibleArea.boxFits([38.0, 2.0, 100.0, 10.0] as Array<Float>, 2)
        && !VisibleArea.boxFits([37.0, 2.0, 100.0, 10.0] as Array<Float>, 2);
    var center = Layout.textBox(new Layout.TextItem("x", Graphics.FONT_TINY, 50, 40,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER), 30, 23);
    var right = Layout.textBox(new Layout.TextItem("x", Graphics.FONT_TINY, 50, 40, Graphics.TEXT_JUSTIFY_RIGHT), 30, 23);
    logger.debug("inDisk=" + inDisk + " fullWidth=" + fullWidth + " rowMargin=" + rowMargin + " edges=" + edges
        + " center=" + center + " right=" + right);
    return inDisk && fullWidth && rowMargin && edges
        && center[0] == 35.0 && center[1] == 28.5 && center[2] == 65.0 && center[3] == 51.5
        && right[0] == 20.0 && right[1] == 40.0 && right[2] == 50.0 && right[3] == 63.0;
}

// Every label the glance shows, for each mystery set, lies inside the glance's 164x62 content area and,
// in the selected slot measured on the watch (ScreenArea.GLANCE_Y), inside the visible area with the 2px
// margin. Both lines use the medium font.
(:test)
function glanceTextStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var seen = {} as Dictionary<String, Boolean>;
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            for (var position = Rosary.NOT_STARTED; position <= Rosary.DONE; position++) {
                var items = Layout.glancePlan(set as Rosary.MysterySet, position, Layout.GLANCE_HEIGHT);
                ok = ok && items.size() == 2;
                for (var i = 0; i < items.size(); i++) {
                    var item = items[i];
                    var key = item.text + "@" + item.x + "," + item.y;
                    if (seen.hasKey(key)) {
                        continue;
                    }
                    seen[key] = true;
                    var box = ScreenArea.measure(dc, item);
                    var screen = ScreenArea.offset(box, ScreenArea.GLANCE_X, ScreenArea.GLANCE_Y);
                    var fits = item.font == Graphics.FONT_MEDIUM
                        && ScreenArea.boxInRect(box, 0, 0, ScreenArea.GLANCE_WIDTH, Layout.GLANCE_HEIGHT)
                        && ScreenArea.visible(screen);
                    logger.debug((fits ? "fits " : "OUT ") + Graphics.getFontHeight(item.font) + "px "
                        + ScreenArea.describeVisible(item.text, screen) + ", " + (ScreenArea.GLANCE_WIDTH - box[2]).format("%.0f")
                        + "px to the content's right edge");
                    ok = ok && fits;
                }
            }
        }
    }
    return ok;
}

// The two glance lines read as one block, vertically centered in the 62px slot: the set name over the
// status, both in the medium font at the shared left x, the status's box starting where the set name's
// ends (touching, never overlapping), with the same room above the block as below it (1px apart at most).
(:test)
function glanceLinesReadAsOneBlock(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var font = Graphics.FONT_MEDIUM;
    var line = Graphics.getFontHeight(font);
    var ok = true;
    var seen = {} as Dictionary<String, Boolean>;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            for (var position = Rosary.NOT_STARTED; position <= Rosary.DONE; position++) {
                var items = Layout.glancePlan(set as Rosary.MysterySet, position, Layout.GLANCE_HEIGHT);
                var key = items[0].text + "|" + items[1].text;
                if (seen.hasKey(key)) {
                    continue;
                }
                seen[key] = true;
                var title = ScreenArea.measure(dc, items[0]);
                var status = ScreenArea.measure(dc, items[1]);
                var gap = status[1] - title[3];
                var above = title[1];
                var below = Layout.GLANCE_HEIGHT - status[3];
                var spread = above - below;
                var block = items.size() == 2 && items[0].font == font && items[1].font == font
                    && items[0].x == Layout.GLANCE_LEFT && items[1].x == Layout.GLANCE_LEFT && Layout.GLANCE_LEFT == 9
                    && items[1].y - items[0].y == line && gap == 0 && above >= 0 && below >= 0 && spread >= -1 && spread <= 1;
                if (!block || position == Rosary.NOT_STARTED) {
                    logger.debug((block ? "block " : "APART ") + ScreenArea.describe(items[0].text, title) + " over "
                        + ScreenArea.describe(items[1].text, status) + " gap " + gap.format("%.0f") + ", "
                        + above.format("%.0f") + "px above, " + below.format("%.0f") + "px below; medium " + line + "px (ascent "
                        + Graphics.getFontAscent(font) + ", descent " + Graphics.getFontDescent(font) + ")");
                }
                ok = ok && block;
            }
        }
    }
    return ok;
}

// The view centers the Avemaría ring and its number on the subscreen the device reports
// (MainLayout.ring). On the Instinct 2 that is the subscreen window the layout checks use, so the
// checks below, fed the same ring, measure what the view draws.
(:test)
function ringSitsOnTheDeviceSubscreen(logger as Logger) as Boolean {
    var subscreen = (WatchUi has :getSubscreen) ? WatchUi.getSubscreen() : null;
    var ring = MainLayout.ring();
    if (subscreen == null) {
        logger.debug("no subscreen reported; ring=" + ring);
        return false;
    }
    logger.debug("subscreen=" + subscreen.x + "," + subscreen.y + " " + subscreen.width + "x" + subscreen.height + " ring=" + ring);
    return subscreen.x + subscreen.width / 2 == ScreenArea.SUBSCREEN_X
        && subscreen.y + subscreen.height / 2 == ScreenArea.SUBSCREEN_Y
        && subscreen.width == subscreen.height && subscreen.width / 2 == ScreenArea.SUBSCREEN_RADIUS
        && ring[0] == ScreenArea.SUBSCREEN_X && ring[1] == ScreenArea.SUBSCREEN_Y && ring[2] < ScreenArea.SUBSCREEN_RADIUS;
}

// Every text the main screen draws, for each of the 72 steps of each mystery set and the finished
// rosary (DONE), stays inside the visible area (which ends at the subscreen lens ring); the
// Avemaría number (the only FONT_NUMBER_MILD text), drawn on the ring the view uses, stays inside
// the subscreen window instead. The blocks keep their top-to-bottom order without overlapping, and
// wrapping never cuts a title or a mystery short.
(:test)
function mainScreenTextStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
    var ring = MainLayout.ring();
    var seen = {} as Dictionary<String, Boolean>;
    var fonts = {} as Dictionary<String, Graphics.FontType>;
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            var titles = {} as Dictionary<Number, Array<String>>;
            var mysteries = {} as Dictionary<Number, Array<String>>;
            for (var step = 0; step <= Rosary.DONE; step++) {
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
                var prayer = Rosary.prayerLabel(step);
                if (!fonts.hasKey(prayer)) {
                    fonts[prayer] = MainLayout.prayerFont(dc, prayer);
                }
                var items = MainLayout.plan(step, "00:00", clockFont, titles[decade] as Array<String>,
                    mysteries[decade] as Array<String>, prayer, fonts[prayer] as Graphics.FontType, ring[0], ring[1]);
                ok = LayoutCheck.blocksInOrder(dc, items, logger) && ok;
                for (var i = 0; i < items.size(); i++) {
                    ok = LayoutCheck.mainItemFits(dc, items[i], seen, logger) && ok;
                }
            }
        }
    }
    var boxes = MainLayout.boxesBounds();
    var boxesBox = [boxes[0].toFloat(), boxes[1].toFloat(), boxes[2].toFloat(), boxes[3].toFloat()] as Array<Float>;
    var boxesFit = ScreenArea.visible(boxesBox);
    logger.debug((boxesFit ? "fits " : "OUT ") + ScreenArea.describeVisible("progress boxes", boxesBox));
    return ok && boxesFit;
}

// The clock fits for every time it can show, in 12h and 24h: every digit in every position.
(:test)
function mainScreenClockStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
    var ring = MainLayout.ring();
    var seen = {} as Dictionary<String, Boolean>;
    var minutes = [0, 11, 22, 33, 44, 55, 6, 17, 28, 39];
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        // The screen on the Credo, around the clock.
        var title = MainLayout.wrapTitle(Rosary.decadeTitle(0, Rosary.JOYFUL));
        var mystery = MainLayout.wrapMystery(Rosary.subtitle(0, Rosary.JOYFUL));
        var prayer = Rosary.prayerLabel(0);
        var prayerFont = MainLayout.prayerFont(dc, prayer);
        for (var hour = 0; hour < 24; hour++) {
            for (var m = 0; m < minutes.size(); m++) {
                for (var mode = 0; mode < 2; mode++) {
                    var text = Rosary.formatClock(hour, minutes[m], mode == 0);
                    var items = MainLayout.plan(0, text, clockFont, title, mystery, prayer, prayerFont, ring[0], ring[1]);
                    ok = LayoutCheck.mainItemFits(dc, items[0], seen, logger) && ok;
                }
            }
        }
    }
    return ok;
}

// The current prayer takes the largest font that keeps it inside the visible area: every label of every
// step, in the font MainLayout.prayerFont picks, fits with the 2px margin, and in each larger font it would
// not. So a label steps down from the large font only when it is too wide for it.
(:test)
function prayerLabelUsesTheLargestFontThatFits(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var fonts = [Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY] as Array<Graphics.FontType>;
    var seen = {} as Dictionary<String, Boolean>;
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var step = 0; step <= Rosary.LAST_STEP; step++) {
            var label = Rosary.prayerLabel(step);
            if (seen.hasKey(label)) {
                continue;
            }
            seen[label] = true;
            var font = MainLayout.prayerFont(dc, label);
            var box = ScreenArea.measure(dc, MainLayout.prayerItem(label, font));
            var fits = ScreenArea.visible(box);
            var largerFit = "";
            for (var i = 0; i < fonts.size() && fonts[i] != font; i++) {
                if (ScreenArea.visible(ScreenArea.measure(dc, MainLayout.prayerItem(label, fonts[i])))) {
                    largerFit += " " + ScreenArea.fontName(fonts[i]);
                }
            }
            var right = fits && largerFit.length() == 0;
            logger.debug((right ? "fits " : "WRONG ") + ScreenArea.fontName(font) + " " + ScreenArea.describeVisible(label, box)
                + (largerFit.length() > 0 ? ", also fits" + largerFit : ""));
            ok = ok && right;
        }
    }
    return ok;
}

// The scroll bar the lists and the reading view share (MenuLayout.thumb): the thumb is as long as the track
// times the share on screen, never shorter than THUMB_MIN, on the track's x. It sits at the top of the
// track while the first item (or line) shows, at its bottom once the last one does, and never moves up in
// between. The reading view pages through 4 lines at a time (offsets 0, 4, ..., then the last window) and
// shows no scroll bar when the whole text fits one window, as a list shows none when every item fits.
(:test)
function scrollThumbShowsWhereTheWindowIs(logger as Logger) as Boolean {
    var track = MenuLayout.TRACK_BOTTOM - MenuLayout.TRACK_TOP;
    var shown = ReadingLayout.visibleLines();
    // [shown, count]: the menu, the language picker, short and long readings, and a text long enough for the
    // minimum length.
    var cases = [[MenuLayout.VISIBLE_ITEMS, 3], [MenuLayout.VISIBLE_ITEMS, 5], [shown, 5], [shown, 9], [shown, 12],
        [shown, 400]];
    var ok = shown == 4;
    for (var c = 0; c < cases.size(); c++) {
        var visible = cases[c][0] as Number;
        var count = cases[c][1] as Number;
        var last = count - visible;
        var length = track * visible / count;
        length = length < MenuLayout.THUMB_MIN ? MenuLayout.THUMB_MIN : length;
        var tops = [] as Array<Number>;
        var caseOk = true;
        for (var first = 0; first <= last; first++) {
            var thumb = MenuLayout.thumb(first, visible, count);
            tops.add(thumb[1]);
            caseOk = caseOk && thumb[0] == MenuLayout.TRACK_X - 1 && thumb[2] == MenuLayout.TRACK_X + 2
                && thumb[3] - thumb[1] == length && thumb[1] >= MenuLayout.TRACK_TOP && thumb[3] <= MenuLayout.TRACK_BOTTOM
                && (first > 0 || thumb[1] == MenuLayout.TRACK_TOP) && (first < last || thumb[3] == MenuLayout.TRACK_BOTTOM)
                && (first == 0 || thumb[1] >= tops[first - 1]);
        }
        logger.debug((caseOk ? "ok " : "WRONG ") + visible + " of " + count + ": length " + length + ", tops "
            + (tops.size() > 12 ? tops.slice(0, 3) + "..." + tops.slice(tops.size() - 3, null) : tops));
        ok = ok && caseOk && tops[tops.size() - 1] > tops[0];
    }
    // The reading view: none for a text that fits one window; from the first line to the last window else.
    var fits = ReadingLayout.thumb(0, shown) == null && ReadingLayout.thumb(0, 1) == null;
    var first = ReadingLayout.thumb(0, 10);
    var lastPage = ReadingLayout.thumb(ReadingLayout.maxOffset(10), 10);
    var middle = ReadingLayout.thumb(ReadingLayout.nextOffset(0, 10), 10);
    logger.debug("reading, 10 lines: pages 0, " + ReadingLayout.nextOffset(0, 10) + ", " + ReadingLayout.maxOffset(10)
        + " thumbs " + first + " " + middle + " " + lastPage + "; fits one window: " + fits);
    if (!ok || !fits || first == null || middle == null || lastPage == null) {
        return false;
    }
    return first[1] == MenuLayout.TRACK_TOP && lastPage[3] == MenuLayout.TRACK_BOTTOM && middle[1] > first[1]
        && middle[3] < lastPage[3] && first.toString().equals(MenuLayout.thumb(0, shown, 10).toString());
}

// The reading view never puts text under the subscreen lens or its ring, for any of the 20 mysteries
// at any scroll position (the user's complaint about the system's message view). The body window fits
// the visible area with the 2px margin; the title, wrapped whole in up to 3 lines, fits beside the lens
// and ends above the window; the mystery number sits inside the subscreen window; every body line drawn
// lies whole inside the window (so it also keeps the margin); and wrapping never cuts the name, the
// quote or the reference short.
// Beside the window, the scroll bar shows where the window sits in the text, as the lists' does: it keeps
// the margin inside the visible area, clear of the lens and right of the window, its thumb at the top on the
// first lines and at the bottom on the last, moving down as the window does (ReadingCheck.thumbFits).
(:test)
function readingTextStaysClearOfTheLens(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var ring = MainLayout.ring();
    var window = ReadingCheck.window();
    var ok = ScreenArea.visible(window) && ReadingLayout.visibleLines() >= 3;
    logger.debug((ok ? "fits " : "OUT ") + ScreenArea.describeVisible("body window", window)
        + " lines=" + ReadingLayout.visibleLines());
    var seen = {} as Dictionary<String, Boolean>;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            for (var decade = 1; decade <= Rosary.DECADES; decade++) {
                var view = new MysteryView(set as Rosary.MysterySet, decade);
                view.onLayout(dc);
                var body = view.bodyLines();
                ok = LayoutCheck.wrapsWhole(Rosary.mysteryTitle(set as Rosary.MysterySet, decade), view.titleLines(), 3, logger) && ok;
                ok = ReadingCheck.bodyWrapsWhole(set as Rosary.MysterySet, decade, body, logger) && ok;
                var header = ReadingLayout.headerPlan(view.titleLines(), decade, ring[0], ring[1]);
                for (var i = 0; i < header.size(); i++) {
                    ok = LayoutCheck.mainItemFits(dc, header[i], seen, logger) && ok;
                    ok = ReadingCheck.aboveTheWindow(dc, header[i], logger) && ok;
                }
                var last = ReadingLayout.maxOffset(body.size());
                var previousTop = -1;
                for (var offset = 0; offset <= last; offset++) {
                    ok = ReadingCheck.bodyInsideTheWindow(dc, body, offset, logger) && ok;
                    var thumb = ReadingLayout.thumb(offset, body.size());
                    ok = ReadingCheck.thumbFits(thumb, offset, body.size(), previousTop, logger) && ok;
                    previousTop = thumb == null ? previousTop : (thumb as Array<Number>)[1];
                }
            }
        }
    }
    return ok;
}

// Every character of every quote, name and reference has a glyph in the tiny font: accents, ñ, ¡ ¿,
// « » and the ellipsis "…". The font draws a character it lacks as an 18px box, the width a CJK
// character measures here, so a glyph counts as present when it measures neither 0 nor that.
(:test)
function readingFontHasEveryGlyph(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var missing = dc.getTextWidthInPixels("中", Graphics.FONT_TINY);
    var checked = {} as Dictionary<String, Number>;
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var index = 0; index < Rosary.DECADES * 4; index++) {
            var name = Rosary.mysteryName((index / Rosary.DECADES) as Rosary.MysterySet, index % Rosary.DECADES + 1);
            var texts = [Quotes.text(index), Quotes.reference(index), name] as Array<String>;
            for (var t = 0; t < texts.size(); t++) {
                var chars = texts[t].toCharArray();
                for (var c = 0; c < chars.size(); c++) {
                    var glyph = chars[c].toString();
                    if (chars[c].toNumber() < 128 || checked.hasKey(glyph)) {
                        continue;
                    }
                    var width = dc.getTextWidthInPixels(glyph, Graphics.FONT_TINY);
                    checked[glyph] = width;
                    ok = ok && width > 0 && width != missing;
                }
            }
        }
    }
    logger.debug("non-ASCII glyph widths " + checked + " missing glyph (中)=" + missing);
    return ok;
}

// Every character the other screens draw has a glyph in the font they draw it with, as the reading view's
// in the tiny font above: the glance's labels (medium), the titles and the mystery names (tiny), the prayer
// labels (in MainLayout.prayerFont), the labels of the menu and the language picker (large), the picker's
// title (tiny) and the reset prompt, which the system's confirmation draws in a font of its own, so in every
// font. French needs é è ê à ç ô Ô É ’ and the no-break space, which every font has; the picker needs ñ and
// ç in the large font ("Español", "Français"). Latin needs only "…" beyond ASCII, as English does.
(:test)
function screenFontsHaveEveryGlyph(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var tiny = Graphics.FONT_TINY;
    var texts = [] as Array<String>;
    var fonts = [] as Array<Graphics.FontType>;
    // One step of the opening, of each decade and of the closing: the title and the line under it depend
    // only on the decade.
    var decadeSteps = [0, 6, 19, 32, 45, 58, Rosary.LAST_STEP];
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            texts.add(Rosary.glanceTitle(set as Rosary.MysterySet));
            fonts.add(Graphics.FONT_MEDIUM);
            for (var i = 0; i < decadeSteps.size(); i++) {
                texts.add(Rosary.decadeTitle(decadeSteps[i], set as Rosary.MysterySet));
                fonts.add(tiny);
                texts.add(Rosary.subtitle(decadeSteps[i], set as Rosary.MysterySet));
                fonts.add(tiny);
            }
        }
        for (var position = Rosary.NOT_STARTED; position <= Rosary.DONE; position++) {
            texts.add(Rosary.glanceSummary(position));
            fonts.add(Graphics.FONT_MEDIUM);
        }
        for (var step = 0; step <= Rosary.LAST_STEP; step++) {
            var label = Rosary.prayerLabel(step);
            texts.add(label);
            fonts.add(MainLayout.prayerFont(dc, label));
        }
        var menu = new RosaryMenuView(Rosary.JOYFUL, 1).labels();
        menu.addAll(LanguageLayout.labels());
        for (var i = 0; i < menu.size(); i++) {
            texts.add(menu[i]);
            fonts.add(Graphics.FONT_LARGE);
        }
        texts.add(I18n.text(I18n.MenuLanguage));
        fonts.add(tiny);
        var prompt = I18n.text(I18n.ResetPrompt);
        var all = [Graphics.FONT_XTINY, Graphics.FONT_TINY, Graphics.FONT_SMALL, Graphics.FONT_MEDIUM, Graphics.FONT_LARGE];
        for (var i = 0; i < all.size(); i++) {
            texts.add(prompt);
            fonts.add(all[i] as Graphics.FontType);
        }
    }
    var checked = {} as Dictionary<String, Number>;
    var ok = true;
    for (var t = 0; t < texts.size(); t++) {
        ok = GlyphCheck.allDrawn(dc, texts[t], fonts[t], checked) && ok;
    }
    logger.debug("non-ASCII glyph widths by font " + checked);
    return ok;
}

// The reading view never breaks a line before closing punctuation or after an opening guillemet: no body
// line of any mystery starts with : ; ? ! » , or . and none ends with «. French sets a space before : ; ? !
// and inside « », and the quotes keep the no-break spaces of their source there, which the wrap does not
// break at.
(:test)
function readingNeverBreaksAtPunctuation(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            for (var decade = 1; decade <= Rosary.DECADES; decade++) {
                var view = new MysteryView(set as Rosary.MysterySet, decade);
                view.onLayout(dc);
                var lines = view.bodyLines();
                for (var i = 0; i < lines.size(); i++) {
                    var chars = lines[i].toCharArray();
                    var first = chars[0];
                    var last = chars[chars.size() - 1];
                    var bad = first == ':' || first == ';' || first == '?' || first == '!' || first == '»' || first == ','
                        || first == '.' || last == '«';
                    if (bad) {
                        logger.debug("BREAK " + Quotes.reference(Rosary.mysteryIndex(set as Rosary.MysterySet, decade)) + " line "
                            + i + ": '" + lines[i] + "'");
                    }
                    ok = ok && !bad;
                }
            }
        }
    }
    return ok;
}

(:test)
module GlyphCheck {

    // Every non-ASCII character of the text has a glyph in the font: it measures neither 0 nor what a
    // character the font lacks measures (a CJK one; the font draws a box for it). Each character and font
    // is checked once and its width kept in checked ("é@medium" => 11).
    function allDrawn(dc as Dc, text as String, font as Graphics.FontType, checked as Dictionary<String, Number>) as Boolean {
        var missing = dc.getTextWidthInPixels("中", font);
        var name = ScreenArea.fontName(font);
        var chars = text.toCharArray();
        var ok = true;
        for (var c = 0; c < chars.size(); c++) {
            var glyph = chars[c].toString();
            var key = glyph + "@" + name;
            if (chars[c].toNumber() < 128 || checked.hasKey(key)) {
                continue;
            }
            var width = dc.getTextWidthInPixels(glyph, font);
            checked[key] = width;
            ok = ok && width > 0 && width != missing;
        }
        return ok;
    }
}

// The reading view lays out and draws every mystery at every scroll position, clip included, and stays
// small: each open view, measured on its own after one warm-up view, holds less than
// ReadingCheck.MEMORY_BUDGET bytes.
(:test)
function readingViewDrawsEveryScrollPosition(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    // Warm-up: the first view measured also pays a one-time cost, so it is measured and left out. The
    // bound then holds whichever test or view runs first.
    TestLanguage.use(logger, I18n.ENG);
    var warmUp = ReadingCheck.memoryHeld(dc, Rosary.JOYFUL, 1);
    var largest = 0;
    var drawn = 0;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        var held = [] as Array<Number>;
        for (var set = 0; set < 4; set++) {
            for (var decade = 1; decade <= Rosary.DECADES; decade++) {
                var bytes = ReadingCheck.memoryHeld(dc, set as Rosary.MysterySet, decade);
                held.add(bytes);
                largest = bytes > largest ? bytes : largest;
                var view = new MysteryView(set as Rosary.MysterySet, decade);
                view.onLayout(dc);
                var last = ReadingLayout.maxOffset(view.bodyLines().size());
                for (var offset = 0; offset <= last; offset++) {
                    view.offset = offset;
                    view.onUpdate(dc);
                    drawn++;
                }
            }
        }
        logger.debug("per mystery " + held);
    }
    var stats = System.getSystemStats();
    logger.debug("drew " + drawn + " screens; warm-up view " + warmUp + " bytes; largest open view " + largest + " bytes (budget "
        + ReadingCheck.MEMORY_BUDGET + "); test app used " + stats.usedMemory + " of " + stats.totalMemory);
    return drawn >= 20 * I18n.LANGUAGE_COUNT && largest > 0 && largest < ReadingCheck.MEMORY_BUDGET;
}

// The hold-UP menu, drawn by the app because the system menu's text was too small for the user: its three
// labels in the large font, two at a time, each centered on its own bar in the full-width rows below the
// subscreen lens, under the reading view's header (the current mystery's title beside the lens, its number
// in the subscreen). In every language and at every selection, every text drawn, the selected item's bar
// and the scroll bar keep the 2px margin inside the visible area (the number: inside the subscreen window),
// each label lies inside its bar (so the selected one sits wholly on the white bar), the bars do not
// overlap, and the menu draws (MenuCheck.listFits). The title, wrapped whole in up to 3 lines for every
// mystery, ends above the first bar.
(:test)
function menuStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var ring = MainLayout.ring();
    var seen = {} as Dictionary<String, Boolean>;
    var firstBarTop = MenuLayout.bar(0)[1];
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        for (var set = 0; set < 4; set++) {
            for (var decade = 1; decade <= Rosary.DECADES; decade++) {
                var menu = new RosaryMenuView(set as Rosary.MysterySet, decade);
                ok = LayoutCheck.wrapsWhole(menu.title(), menu.titleLines(), 3, logger) && ok;
                var header = ReadingLayout.headerPlan(menu.titleLines(), decade, ring[0], ring[1]);
                for (var i = 0; i < header.size(); i++) {
                    ok = LayoutCheck.mainItemFits(dc, header[i], seen, logger) && ok;
                    ok = MenuCheck.endsAbove(dc, header[i], firstBarTop, logger) && ok;
                }
                if (set == 0 && decade == 1) {
                    ok = MenuCheck.listFits(dc, menu, seen, logger) && ok;
                } else {
                    menu.onUpdate(dc);
                }
            }
        }
    }
    var first = MenuLayout.bar(0);
    var second = MenuLayout.bar(1);
    logger.debug("bars " + first + " " + second + " large font " + Graphics.getFontHeight(Graphics.FONT_LARGE) + "px (ascent "
        + Graphics.getFontAscent(Graphics.FONT_LARGE) + ", descent " + Graphics.getFontDescent(Graphics.FONT_LARGE) + ")");
    return ok && first[3] < second[1] && MenuLayout.VISIBLE_ITEMS == 2;
}

// The language picker, in the menu's style: its title ("Language") beside the lens where the menu shows the
// mystery's, over Automatic and the four languages, two at a time, the window scrolling over the five. In every language, with the saved
// choice's mark on each item in turn and at every selection, everything it draws keeps the 2px margin inside
// the visible area as the menu's does (MenuCheck.listFits), the mark lies inside its bar and clear of the
// label, and the title, wrapped whole, ends above the first bar. Uses the real Storage and puts back the
// saved choice that was there.
(:test)
function languagePickerStaysInsideTheVisibleArea(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var seen = {} as Dictionary<String, Boolean>;
    var firstBarTop = MenuLayout.bar(0)[1];
    var before = Application.Storage.getValue(I18n.CHOICE_KEY);
    var ok = true;
    try {
        for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
            for (var choice = I18n.AUTOMATIC; choice <= I18n.LATIN; choice++) {
                Application.Storage.setValue(I18n.CHOICE_KEY, choice);
                TestLanguage.use(logger, language);
                var picker = new LanguageView();
                ok = LayoutCheck.wrapsWhole(I18n.text(I18n.MenuLanguage), picker.titleLines(), 3, logger) && ok;
                var header = LanguageLayout.headerPlan(picker.titleLines());
                for (var i = 0; i < header.size(); i++) {
                    ok = LayoutCheck.mainItemFits(dc, header[i], seen, logger) && ok;
                    ok = MenuCheck.endsAbove(dc, header[i], firstBarTop, logger) && ok;
                }
                ok = picker.selected == choice && picker.isMarked(choice) && MenuCheck.listFits(dc, picker, seen, logger) && ok;
            }
        }
    } finally {
        if (before == null) {
            Application.Storage.deleteValue(I18n.CHOICE_KEY);
        } else {
            Application.Storage.setValue(I18n.CHOICE_KEY, before as Application.PropertyValueType);
        }
        I18n.reset();
    }
    return ok;
}

// The menu and the language picker stay small: each open list, measured on its own after one warm-up list,
// holds less than ReadingCheck.MEMORY_BUDGET bytes, in every language.
(:test)
function menuAndPickerStaySmall(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    TestLanguage.use(logger, I18n.ENG);
    var warmUp = MenuCheck.memoryHeld(dc, false);
    var held = [] as Array<Number>;
    var ok = true;
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        TestLanguage.use(logger, language);
        var menu = MenuCheck.memoryHeld(dc, false);
        var picker = MenuCheck.memoryHeld(dc, true);
        held.add(menu);
        held.add(picker);
        ok = ok && menu > 0 && picker > 0 && menu < ReadingCheck.MEMORY_BUDGET && picker < ReadingCheck.MEMORY_BUDGET;
    }
    logger.debug("warm-up menu " + warmUp + " bytes; menu, picker held eng, spa, fre, lat " + held + " (budget "
        + ReadingCheck.MEMORY_BUDGET + ")");
    return ok;
}

// Only the selected item of a list is inverted, at every selection: the selected one is black text on a
// white bar, any other white text on the black background with no bar. So the items always look different,
// and every label contrasts with what lies under it (MenuLayout.itemColors, which the lists draw with).
(:test)
function menuInvertsOnlyTheSelectedItem(logger as Logger) as Boolean {
    var ok = MenuLayout.BACKGROUND == Graphics.COLOR_BLACK;
    var looks = "";
    var count = LanguageLayout.labels().size();
    for (var selected = 0; selected < count; selected++) {
        looks += " selected " + selected + ":";
        for (var i = 0; i < count; i++) {
            var colors = MenuLayout.itemColors(i, selected);
            var under = colors[1] == Graphics.COLOR_TRANSPARENT ? MenuLayout.BACKGROUND : colors[1];
            var inverted = colors[0] == Graphics.COLOR_BLACK && colors[1] == Graphics.COLOR_WHITE;
            var plain = colors[0] == Graphics.COLOR_WHITE && colors[1] == Graphics.COLOR_TRANSPARENT;
            ok = ok && colors.size() == 2 && (i == selected ? inverted : plain) && colors[0] != under;
            looks += " item " + i + " " + MenuCheck.colorName(colors[0]) + " on " + MenuCheck.colorName(under)
                + (colors[1] == Graphics.COLOR_TRANSPARENT ? " (no bar)" : " bar");
        }
    }
    logger.debug("background " + MenuCheck.colorName(MenuLayout.BACKGROUND) + ";" + looks);
    return ok;
}

(:test)
module MenuCheck {

    // Memory an open list holds once drawn: the menu (over the 2nd Sorrowful mystery) or the picker.
    function memoryHeld(dc as Dc, picker as Boolean) as Number {
        var before = System.getSystemStats().usedMemory;
        var list = (picker ? new LanguageView() : new RosaryMenuView(Rosary.SORROWFUL, 2)) as BarListView;
        list.onUpdate(dc);
        return System.getSystemStats().usedMemory - before;
    }

    // Walks the list's selection from its first item to its last. At each step the window shows the selected
    // item, and every item on screen fits (shownFits); the list draws.
    function listFits(dc as Dc, list as BarListView, seen as Dictionary<String, Boolean>, logger as Logger) as Boolean {
        var count = list.labels().size();
        for (var i = 0; i < count; i++) {
            list.moveUp();
        }
        var ok = list.selected == 0 && list.first == 0;
        var trail = "";
        for (var position = 0; position < count; position++) {
            if (position > 0) {
                ok = list.moveDown() && ok;
            }
            trail += " " + list.selected + "/" + list.first;
            ok = list.selected == position && shownFits(dc, list, seen, logger) && ok;
            list.onUpdate(dc);
        }
        ok = !list.moveDown() && ok;
        if (!ok) {
            logger.debug("OUT list " + list.labels() + " selected/first" + trail);
        }
        return ok;
    }

    // The items on screen: each label, in the large font, fits the visible area and lies on its bar; the
    // selected item's bar fits; the saved choice's mark lies inside its bar, clear of the label; and the scroll
    // thumb fits, on the track.
    function shownFits(dc as Dc, list as BarListView, seen as Dictionary<String, Boolean>, logger as Logger) as Boolean {
        var labels = list.labels();
        var ok = list.selected >= list.first && list.selected < list.first + MenuLayout.VISIBLE_ITEMS;
        for (var slot = 0; slot < MenuLayout.VISIBLE_ITEMS && list.first + slot < labels.size(); slot++) {
            var index = list.first + slot;
            var item = MenuLayout.label(slot, labels[index]);
            ok = item.font == Graphics.FONT_LARGE && LayoutCheck.mainItemFits(dc, item, seen, logger) && ok;
            ok = onItsBar(dc, item, MenuLayout.bar(slot), logger) && ok;
            if (index == list.selected) {
                var bar = box(MenuLayout.bar(slot));
                var barFits = ScreenArea.visible(bar);
                if (!barFits) {
                    logger.debug("OUT " + ScreenArea.describeVisible("bar", bar));
                }
                ok = barFits && ok;
            }
            if (list.isMarked(index)) {
                ok = markFits(dc, item, slot, logger) && ok;
            }
        }
        if (labels.size() > MenuLayout.VISIBLE_ITEMS) {
            var thumb = box(MenuLayout.thumb(list.first, MenuLayout.VISIBLE_ITEMS, labels.size()));
            var thumbFits = ScreenArea.visible(thumb) && thumb[1] >= MenuLayout.TRACK_TOP && thumb[3] <= MenuLayout.TRACK_BOTTOM
                && thumb[3] - thumb[1] > 0 && thumb[0] > MenuLayout.BAR_RIGHT;
            if (!thumbFits) {
                logger.debug("OUT " + ScreenArea.describeVisible("scroll thumb", thumb));
            }
            ok = thumbFits && ok;
        }
        return ok;
    }

    // The saved choice's mark lies inside the bar, and at least 2px left of the label.
    function markFits(dc as Dc, item as Layout.TextItem, slot as Number, logger as Logger) as Boolean {
        var mark = MenuLayout.mark(slot);
        var bar = MenuLayout.bar(slot);
        var markBox = [mark[0] - mark[2], mark[1] - mark[2], mark[0] + mark[2] + 1, mark[1] + mark[2] + 1] as Array<Number>;
        var label = ScreenArea.measure(dc, item);
        var ok = ScreenArea.boxInRect(box(markBox), bar[0], bar[1], bar[2], bar[3]) && markBox[2] + 2 <= label[0];
        if (!ok) {
            logger.debug("MARK " + markBox + " not clear of " + ScreenArea.describe(item.text, label) + " in bar " + bar);
        }
        return ok;
    }

    function box(rect as Array<Number>) as Array<Float> {
        return [rect[0].toFloat(), rect[1].toFloat(), rect[2].toFloat(), rect[3].toFloat()] as Array<Float>;
    }

    function colorName(color as Number) as String {
        if (color == Graphics.COLOR_BLACK) {
            return "black";
        }
        if (color == Graphics.COLOR_WHITE) {
            return "white";
        }
        return color == Graphics.COLOR_TRANSPARENT ? "transparent" : color.format("%06X");
    }

    // The header text ends above the given row, so the bars never run into it.
    function endsAbove(dc as Dc, item as Layout.TextItem, row as Number, logger as Logger) as Boolean {
        var box = ScreenArea.measure(dc, item);
        var ok = box[3] <= row;
        if (!ok) {
            logger.debug("OVERLAP header " + ScreenArea.describe(item.text, box) + " runs into the bar at row " + row);
        }
        return ok;
    }

    // The label lies inside its bar, with the gap it keeps on each side logged when it does not.
    function onItsBar(dc as Dc, item as Layout.TextItem, bar as Array<Number>, logger as Logger) as Boolean {
        var box = ScreenArea.measure(dc, item);
        var ok = ScreenArea.boxInRect(box, bar[0], bar[1], bar[2], bar[3]);
        if (ok) {
            return true;
        }
        logger.debug("OFF bar " + ScreenArea.describe(item.text, box) + " in " + bar + " gaps left "
            + (box[0] - bar[0]).format("%.1f") + " top " + (box[1] - bar[1]).format("%.1f") + " right "
            + (bar[2] - box[2]).format("%.1f") + " bottom " + (bar[3] - box[3]).format("%.1f"));
        return ok;
    }
}

(:test)
module ReadingCheck {

    // Most memory one open reading view may hold, in bytes. A view holds its wrapped title and body lines
    // (the one quote it loads is let go once wrapped): 616 to 880 bytes measured. The first view a test
    // measures also pays a one-time cost of about 800 bytes (1672 in all), so the test measures one warm-up
    // view first and leaves it out. 3072 leaves about 3.5x the largest for longer texts, yet catches a view
    // that keeps every quote (the 20 quotes are 1909 bytes of UTF-8 text; with that change every view
    // measured 3072 to 4128, so it fails with or without the warm-up), the cost R12 avoided by loading only
    // the one being read. It is under 5% of the widget's 64KB.
    const MEMORY_BUDGET = 3072;

    // Memory one reading view holds once laid out. The view is the only thing allocated in between and is
    // let go on return, so no other view is counted or freed during the measurement.
    function memoryHeld(dc as Dc, set as Rosary.MysterySet, decade as Number) as Number {
        var before = System.getSystemStats().usedMemory;
        var view = new MysteryView(set, decade);
        view.onLayout(dc);
        return System.getSystemStats().usedMemory - before;
    }

    // The body window as a screen box [left, top, right, bottom].
    function window() as Array<Float> {
        return [ReadingLayout.WINDOW_LEFT.toFloat(), ReadingLayout.WINDOW_TOP.toFloat(),
            ReadingLayout.WINDOW_RIGHT.toFloat(), ReadingLayout.WINDOW_BOTTOM.toFloat()] as Array<Float>;
    }

    // The body is the mystery's name, the quote and the reference, every word of each in order: joined
    // back with spaces, the lines give exactly that text (a truncated wrap ends in "..." instead).
    function bodyWrapsWhole(set as Rosary.MysterySet, decade as Number, lines as Array<String>, logger as Logger) as Boolean {
        var index = Rosary.mysteryIndex(set, decade);
        var expected = Rosary.mysteryName(set, decade) + " " + Quotes.text(index) + " " + Quotes.reference(index);
        var joined = "";
        for (var i = 0; i < lines.size(); i++) {
            joined += (i > 0 ? " " : "") + lines[i];
        }
        var ok = joined.equals(expected);
        logger.debug((ok ? "whole " : "CUT ") + Quotes.reference(index) + ": " + lines.size() + " lines " + lines);
        return ok;
    }

    // The scroll thumb at this offset: none when the whole text fits one window; otherwise inside the visible
    // area with the margin, on the lists' track (MenuLayout), at least 2px right of the window, at the top of
    // the track on the first line, at its bottom on the last window, and lower than at the offset before.
    function thumbFits(thumb as Array<Number>?, offset as Number, count as Number, previousTop as Number,
        logger as Logger) as Boolean {
        if (count <= ReadingLayout.visibleLines()) {
            return thumb == null;
        }
        if (thumb == null) {
            logger.debug("NO THUMB at offset " + offset + " of " + count + " lines");
            return false;
        }
        var box = MenuCheck.box(thumb);
        var last = ReadingLayout.maxOffset(count);
        var ok = ScreenArea.visible(box) && thumb[0] >= ReadingLayout.WINDOW_RIGHT + 2
            && thumb[1] >= MenuLayout.TRACK_TOP && thumb[3] <= MenuLayout.TRACK_BOTTOM && thumb[3] > thumb[1]
            && (offset > 0 || thumb[1] == MenuLayout.TRACK_TOP) && (offset < last || thumb[3] == MenuLayout.TRACK_BOTTOM)
            && thumb[1] > previousTop;
        if (!ok) {
            logger.debug("THUMB at offset " + offset + " of " + count + " lines (last " + last + "): "
                + ScreenArea.describeVisible("thumb", box) + " after top " + previousTop);
        }
        return ok;
    }

    // Header text ends above the window, so the body never runs into it.
    function aboveTheWindow(dc as Dc, item as Layout.TextItem, logger as Logger) as Boolean {
        if (item.font == Graphics.FONT_NUMBER_MILD) {
            return true;
        }
        var box = ScreenArea.measure(dc, item);
        var ok = box[3] <= ReadingLayout.WINDOW_TOP;
        if (!ok) {
            logger.debug("OVERLAP header " + ScreenArea.describe(item.text, box) + " runs into the window");
        }
        return ok;
    }

    // At this scroll position the window shows as many lines as it holds (fewer only at the end of a
    // short text), each whole inside the window and inside the visible area with the margin.
    function bodyInsideTheWindow(dc as Dc, lines as Array<String>, offset as Number, logger as Logger) as Boolean {
        var items = ReadingLayout.bodyPlan(lines, offset);
        var shown = lines.size() - offset;
        if (shown > ReadingLayout.visibleLines()) {
            shown = ReadingLayout.visibleLines();
        }
        var ok = items.size() == shown;
        for (var i = 0; i < items.size(); i++) {
            var box = ScreenArea.measure(dc, items[i]);
            var fits = items[i].text.equals(lines[offset + i])
                && ScreenArea.boxInRect(box, ReadingLayout.WINDOW_LEFT, ReadingLayout.WINDOW_TOP,
                    ReadingLayout.WINDOW_RIGHT, ReadingLayout.WINDOW_BOTTOM)
                && ScreenArea.visible(box);
            if (!fits) {
                logger.debug("OUT at offset " + offset + " " + ScreenArea.describeVisible(items[i].text, box));
            }
            ok = ok && fits;
        }
        return ok;
    }
}

(:test)
module LayoutCheck {

    // Checks one main-screen item, each distinct text and position once (logged, then remembered).
    function mainItemFits(dc as Dc, item as Layout.TextItem, seen as Dictionary<String, Boolean>, logger as Logger) as Boolean {
        var key = item.text + "@" + item.x + "," + item.y;
        if (seen.hasKey(key)) {
            return seen[key] as Boolean;
        }
        var box = ScreenArea.measure(dc, item);
        var inSubscreen = item.font == Graphics.FONT_NUMBER_MILD;
        var fits;
        if (inSubscreen) {
            fits = ScreenArea.insideSubscreen(box);
        } else {
            fits = ScreenArea.visible(box);
        }
        seen[key] = fits;
        logger.debug((fits ? "fits " : "OUT ")
            + (inSubscreen ? "subscreen " + ScreenArea.describe(item.text, box) : ScreenArea.describeVisible(item.text, box)));
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
