import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Layout for the Instinct 2 (176x176, round-ish, subscreen circle at the top right). Every block
// stays inside the visible area, which narrows toward the top and the bottom. The system tiny font
// is 23px tall (18 ascent) and about 8px per character.
// Clock: pixel font, centered left of the subscreen, at the top.
const CLOCK_X = 69;
const CLOCK_Y = 4;
// Decade title: up to 2 lines in the band left of the subscreen ("1er Misterio" is about 90px).
const TITLE_X = 59;
const TITLE_CENTER_Y = 38;
const TITLE_WIDTH = 96;
const TITLE_PITCH = 19;
// Mystery name: up to 2 lines across the full-width band under the subscreen. Every mystery
// fits in 2 lines at 164px.
const MYSTERY_CENTER_Y = 92;
const MYSTERY_WIDTH = 164;
const MYSTERY_PITCH = 21;
// fitTextToArea height that allows 2 lines of the tiny font (it spaces them 26px apart) but not 3.
const TWO_LINES_HEIGHT = 52;
// Current prayer, large, centered on this line.
const PRAYER_Y = 129;
// Progress boxes (opening, 5 mysteries, closing), centered on this line.
const BOXES_Y = 155;
const BOX_SIZE = 9;
const BOX_GAP = 5;
const BOX_COUNT = 7;

// Main widget screen: small clock, decade title, mystery, current prayer, the Avemaría ring in
// the subscreen and the overall progress boxes.
class RosaryView extends WatchUi.View {

    var step as Number;
    private var _set as Rosary.MysterySet;
    private var _clockFont as FontResource?;
    private var _ringX as Number;
    private var _ringY as Number;
    private var _ringRadius as Number;
    private var _clockTimer as Timer.Timer?;
    // Wrapped text for the current step, rebuilt only when the step changes (wrapping is the
    // costliest part of a render, and the clock redraws every minute).
    private var _titleLines as Array<String>;
    private var _mysteryLines as Array<String>;

    function initialize(step as Number, set as Rosary.MysterySet) {
        View.initialize();
        self.step = step;
        _set = set;
        // Instinct 2 subscreen (x=113 y=0 62x62) until onLayout reads the real one.
        _ringX = 144;
        _ringY = 31;
        _ringRadius = 26;
        _titleLines = [] as Array<String>;
        _mysteryLines = [] as Array<String>;
    }

    function onLayout(dc as Dc) as Void {
        _clockFont = WatchUi.loadResource(Rez.Fonts.PixelSmall) as FontResource;
        if (WatchUi has :getSubscreen) {
            var subscreen = WatchUi.getSubscreen();
            if (subscreen != null) {
                _ringX = subscreen.x + subscreen.width / 2;
                _ringY = subscreen.y + subscreen.height / 2;
                _ringRadius = subscreen.width / 2 - 5; // keeps the 3px stroke clear of the bezel
            }
        }
        wrapText();
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
        wrapText();
        WatchUi.requestUpdate();
    }

    // Word-wraps the decade title and the mystery in up to 2 lines with a system font (they have
    // accents).
    private function wrapText() as Void {
        _titleLines = wrap(Rosary.decadeTitle(step, _set), TITLE_WIDTH);
        _mysteryLines = wrap(Rosary.subtitle(step, _set), MYSTERY_WIDTH);
    }

    private function wrap(text as String, width as Number) as Array<String> {
        return Rosary.splitLines(Graphics.fitTextToArea(text, Graphics.FONT_TINY, width, TWO_LINES_HEIGHT, true));
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var clock = System.getClockTime();
        var clockText = Rosary.formatClock(clock.hour, clock.min, System.getDeviceSettings().is24Hour);
        dc.drawText(CLOCK_X, CLOCK_Y, _clockFont as FontResource, clockText, Graphics.TEXT_JUSTIFY_CENTER);

        drawRing(dc);
        var centerX = dc.getWidth() / 2;
        drawLines(dc, _titleLines, TITLE_X, TITLE_CENTER_Y, TITLE_PITCH);
        drawLines(dc, _mysteryLines, centerX, MYSTERY_CENTER_Y, MYSTERY_PITCH);
        dc.drawText(centerX, PRAYER_Y, Graphics.FONT_LARGE, Rosary.prayerLabel(step),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawProgressBoxes(dc, centerX, Rosary.decadeAt(step));
    }

    // 10 segments clockwise from 12 o'clock: Avemarías reached are 3px thick, the rest a 1px track.
    // The number of the current Avemaría sits in the center; other prayers leave it blank.
    private function drawRing(dc as Dc) as Void {
        var filled = Rosary.ringFill(step);
        for (var i = 0; i < Rosary.HAIL_MARYS_PER_DECADE; i++) {
            dc.setPenWidth(i < filled ? 3 : 1);
            dc.drawArc(_ringX, _ringY, _ringRadius, Graphics.ARC_CLOCKWISE, Rosary.ringSegmentStart(i), Rosary.ringSegmentEnd(i));
        }
        dc.setPenWidth(1);
        var index = Rosary.hailMaryIndex(step);
        if (index > 0) {
            dc.drawText(_ringX, _ringY, Graphics.FONT_NUMBER_MILD, index.format("%d"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Draws wrapped lines centered on (centerX, centerY), pitch px apart: tighter than the font's
    // own line spacing, which is too loose for this screen.
    private function drawLines(dc as Dc, lines as Array<String>, centerX as Number, centerY as Number, pitch as Number) as Void {
        var font = Graphics.FONT_TINY;
        var top = centerY - ((lines.size() - 1) * pitch + dc.getFontHeight(font)) / 2;
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(centerX, top + i * pitch, font, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // One box per part of the rosary: filled when done, outlined when pending, and a larger
    // 2px frame for the current one.
    private function drawProgressBoxes(dc as Dc, centerX as Number, current as Number) as Void {
        var left = centerX - (BOX_COUNT * BOX_SIZE + (BOX_COUNT - 1) * BOX_GAP) / 2;
        var top = BOXES_Y - BOX_SIZE / 2;
        for (var i = 0; i < BOX_COUNT; i++) {
            var x = left + i * (BOX_SIZE + BOX_GAP);
            if (i < current) {
                dc.fillRectangle(x, top, BOX_SIZE, BOX_SIZE);
            } else if (i == current) {
                dc.drawRectangle(x - 2, top - 2, BOX_SIZE + 4, BOX_SIZE + 4);
                dc.drawRectangle(x - 1, top - 1, BOX_SIZE + 2, BOX_SIZE + 2);
            } else {
                dc.drawRectangle(x, top, BOX_SIZE, BOX_SIZE);
            }
        }
    }
}
