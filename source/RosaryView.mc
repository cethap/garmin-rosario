import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Layout of the main screen on the Instinct 2 (176x176). The visible area narrows toward the
// corners and the subscreen lens, with its ring, takes the top right; LayoutTests.mc checks every
// text item of every step against it. The blocks stack from the top without overlapping. The system
// tiny font is 23px tall (18 ascent).
module MainLayout {
    // Clock: pixel font (60x12 for "HH:MM"), centered left of the subscreen, at the top.
    const CLOCK_X = 69;
    const CLOCK_Y = 6;
    // Decade title: centered in the band left of the subscreen, under the clock. The band is about
    // 74px wide at the top, too narrow for "1er Misterio" (90px), so titles wrap in up to 3 lines,
    // "1er" / "Misterio" / "Gozoso", and the longer words fall on the wider rows below.
    const TITLE_X = 59;
    const TITLE_CENTER_Y = 48;
    const TITLE_WIDTH = 76;
    const TITLE_PITCH = 19;
    // Mystery name: up to 2 lines across the full width, low enough to clear the subscreen ring.
    // Every mystery fits in 2 lines at 164px.
    const MYSTERY_CENTER_Y = 101;
    const MYSTERY_WIDTH = 164;
    const MYSTERY_PITCH = 21;
    // fitTextToArea heights that allow 2 and 3 lines of the tiny font (it spaces them 26px apart).
    const TWO_LINES_HEIGHT = 52;
    const THREE_LINES_HEIGHT = 78;
    // Current prayer, centered horizontally, from this top line, in the largest font whose line holds it
    // (prayerFont): the large font, or a smaller one for a name too wide for it (English "Apostles' Creed",
    // French "Je crois en Dieu"). Every Spanish label fits the large font.
    const PRAYER_TOP = 123;
    // Progress boxes (opening, 5 mysteries, closing), centered on this line.
    const BOXES_Y = 160;
    const BOX_SIZE = 9;
    const BOX_GAP = 5;
    const BOX_COUNT = 7;
    // Avemaría ring on the Instinct 2's subscreen (x=113 y=0 62x62), until the device reports its own:
    // centered on the window, 5px in so the 3px stroke keeps clear of the bezel.
    const RING_X = 144;
    const RING_Y = 31;
    const RING_INSET = 5;
    const RING_RADIUS = 31 - RING_INSET;

    // Center and radius [x, y, radius] of the Avemaría ring and its number: on the subscreen the device
    // reports, or the Instinct 2's when it reports none. The view and the layout tests both use it.
    function ring() as Array<Number> {
        if (WatchUi has :getSubscreen) {
            var subscreen = WatchUi.getSubscreen();
            if (subscreen != null) {
                return [subscreen.x + subscreen.width / 2, subscreen.y + subscreen.height / 2,
                    subscreen.width / 2 - RING_INSET] as Array<Number>;
            }
        }
        return [RING_X, RING_Y, RING_RADIUS] as Array<Number>;
    }

    // Word-wraps the decade title and the mystery with a system font (they have accents).
    function wrapTitle(text as String) as Array<String> {
        return wrap(text, TITLE_WIDTH, THREE_LINES_HEIGHT);
    }

    function wrapMystery(text as String) as Array<String> {
        return wrap(text, MYSTERY_WIDTH, TWO_LINES_HEIGHT);
    }

    function wrap(text as String, width as Number, height as Number) as Array<String> {
        return Rosary.splitLines(Graphics.fitTextToArea(text, Graphics.FONT_TINY, width, height, true));
    }

    // The prayer's font: the largest of large, medium and small whose line holds the label, else tiny. A
    // taller font reaches lower rows, which the bezel narrows, so each has its own width (LayoutTests.mc
    // checks every label against the visible area, and that no larger font would fit). The view measures
    // once per step.
    function prayerFont(dc as Dc, label as String) as Graphics.FontType {
        var fonts = [Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL] as Array<Graphics.FontType>;
        var widths = [136, 146, 152] as Array<Number>;
        for (var i = 0; i < fonts.size(); i++) {
            if (dc.getTextWidthInPixels(label, fonts[i]) <= widths[i]) {
                return fonts[i];
            }
        }
        return Graphics.FONT_TINY;
    }

    // The current prayer in its font, centered horizontally from PRAYER_TOP.
    function prayerItem(prayer as String, font as Graphics.FontType) as Layout.TextItem {
        return new Layout.TextItem(prayer, font, Layout.SCREEN_SIZE / 2, PRAYER_TOP, Graphics.TEXT_JUSTIFY_CENTER as Number);
    }

    // Every text the screen draws for a step: the clock, the wrapped title and mystery, the current
    // prayer (Rosary.prayerLabel, in prayerFont) and, on an Avemaría, its number centered in the subscreen
    // ring at (ringX, ringY).
    function plan(step as Number, clockText as String, clockFont as Graphics.FontType, titleLines as Array<String>,
        mysteryLines as Array<String>, prayer as String, prayerFont as Graphics.FontType, ringX as Number,
        ringY as Number) as Array<Layout.TextItem> {
        var centerX = Layout.SCREEN_SIZE / 2;
        var center = Graphics.TEXT_JUSTIFY_CENTER as Number;
        var middle = (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER) as Number;
        var items = [new Layout.TextItem(clockText, clockFont, CLOCK_X, CLOCK_Y, center)] as Array<Layout.TextItem>;
        addLines(items, titleLines, TITLE_X, TITLE_CENTER_Y, TITLE_PITCH);
        addLines(items, mysteryLines, centerX, MYSTERY_CENTER_Y, MYSTERY_PITCH);
        items.add(prayerItem(prayer, prayerFont));
        var index = Rosary.hailMaryIndex(step);
        if (index > 0) {
            items.add(new Layout.TextItem(index.format("%d"), Graphics.FONT_NUMBER_MILD, ringX, ringY, middle));
        }
        return items;
    }

    // Wrapped lines centered on (centerX, centerY), pitch px apart: tighter than the font's own line
    // spacing, which is too loose for this screen.
    function addLines(items as Array<Layout.TextItem>, lines as Array<String>, centerX as Number, centerY as Number,
        pitch as Number) as Void {
        var top = centerY - ((lines.size() - 1) * pitch + Graphics.getFontHeight(Graphics.FONT_TINY)) / 2;
        for (var i = 0; i < lines.size(); i++) {
            items.add(new Layout.TextItem(lines[i], Graphics.FONT_TINY, centerX, top + i * pitch, Graphics.TEXT_JUSTIFY_CENTER as Number));
        }
    }

    // Area [left, top, right, bottom] the progress boxes cover, the current box's 2px frame included.
    function boxesBounds() as Array<Number> {
        var left = Layout.SCREEN_SIZE / 2 - (BOX_COUNT * BOX_SIZE + (BOX_COUNT - 1) * BOX_GAP) / 2;
        var top = BOXES_Y - BOX_SIZE / 2;
        return [left - 2, top - 2, left + BOX_COUNT * BOX_SIZE + (BOX_COUNT - 1) * BOX_GAP + 2, top + BOX_SIZE + 2] as Array<Number>;
    }
}

// Main widget screen: small clock, decade title, mystery, current prayer, the Avemaría ring in
// the subscreen and the overall progress boxes.
class RosaryView extends WatchUi.View {

    var step as Number;
    // The day's mysteries.
    var mysterySet as Rosary.MysterySet;
    private var _clockFont as FontResource?;
    private var _ringX as Number;
    private var _ringY as Number;
    private var _ringRadius as Number;
    private var _clockTimer as Timer.Timer?;
    // Text for the current step, loaded from the resources and wrapped only when the step changes
    // (loading and wrapping are the costliest part of a render, and the clock redraws every minute).
    private var _titleLines as Array<String>;
    private var _mysteryLines as Array<String>;
    private var _prayer as String;
    // The prayer's font, measured on the first draw of each step (MainLayout.prayerFont needs a Dc).
    private var _prayerFont as Graphics.FontType?;

    function initialize(step as Number, set as Rosary.MysterySet) {
        View.initialize();
        self.step = step;
        mysterySet = set;
        // Instinct 2 subscreen until onLayout reads the device's.
        _ringX = MainLayout.RING_X;
        _ringY = MainLayout.RING_Y;
        _ringRadius = MainLayout.RING_RADIUS;
        _titleLines = [] as Array<String>;
        _mysteryLines = [] as Array<String>;
        _prayer = "";
    }

    function onLayout(dc as Dc) as Void {
        _clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
        var ring = MainLayout.ring();
        _ringX = ring[0];
        _ringY = ring[1];
        _ringRadius = ring[2];
        loadStepText();
    }

    // Keep the clock current while the screen is open.
    function onShow() as Void {
        scheduleClockTick();
    }

    function onHide() as Void {
        if (_clockTimer != null) {
            _clockTimer.stop();
        }
    }

    // Fires at the start of each minute.
    function onClockTick() as Void {
        WatchUi.requestUpdate();
        scheduleClockTick();
    }

    private function scheduleClockTick() as Void {
        if (_clockTimer == null) {
            _clockTimer = new Timer.Timer();
        }
        var timer = _clockTimer as Timer.Timer;
        timer.stop();
        timer.start(method(:onClockTick), (60 - System.getClockTime().sec) * 1000, false);
    }

    function showStep(newStep as Number) as Void {
        step = newStep;
        loadStepText();
        WatchUi.requestUpdate();
    }

    private function loadStepText() as Void {
        _titleLines = MainLayout.wrapTitle(Rosary.decadeTitle(step, mysterySet));
        _mysteryLines = MainLayout.wrapMystery(Rosary.subtitle(step, mysterySet));
        _prayer = Rosary.prayerLabel(step);
        _prayerFont = null;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        drawRing(dc);
        var clock = System.getClockTime();
        var clockText = Rosary.formatClock(clock.hour, clock.min, System.getDeviceSettings().is24Hour);
        if (_prayerFont == null) {
            _prayerFont = MainLayout.prayerFont(dc, _prayer);
        }
        var items = MainLayout.plan(step, clockText, _clockFont as FontResource, _titleLines, _mysteryLines, _prayer,
            _prayerFont as Graphics.FontType, _ringX, _ringY);
        for (var i = 0; i < items.size(); i++) {
            items[i].draw(dc);
        }
        drawProgressBoxes(dc, Rosary.partsDone(step));
    }

    // 10 segments clockwise from 12 o'clock: Avemarías reached are 3px thick, the rest a 1px track.
    // The plan puts the number of the current Avemaría in the center.
    private function drawRing(dc as Dc) as Void {
        var filled = Rosary.ringFill(step);
        for (var i = 0; i < Rosary.HAIL_MARYS_PER_DECADE; i++) {
            dc.setPenWidth(i < filled ? 3 : 1);
            dc.drawArc(_ringX, _ringY, _ringRadius, Graphics.ARC_CLOCKWISE, Rosary.ringSegmentStart(i), Rosary.ringSegmentEnd(i));
        }
        dc.setPenWidth(1);
    }

    // One box per part of the rosary: filled when done, outlined when pending, and a larger
    // 2px frame for the current one.
    private function drawProgressBoxes(dc as Dc, current as Number) as Void {
        var bounds = MainLayout.boxesBounds();
        var left = bounds[0] + 2;
        var top = bounds[1] + 2;
        var size = MainLayout.BOX_SIZE;
        for (var i = 0; i < MainLayout.BOX_COUNT; i++) {
            var x = left + i * (size + MainLayout.BOX_GAP);
            if (i < current) {
                dc.fillRectangle(x, top, size, size);
            } else if (i == current) {
                dc.drawRectangle(x - 2, top - 2, size + 4, size + 4);
                dc.drawRectangle(x - 1, top - 1, size + 2, size + 2);
            } else {
                dc.drawRectangle(x, top, size, size);
            }
        }
    }
}
