import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Layout of the reading view ("Leer misterio"), shared with the layout tests. No text ever goes
// under the subscreen lens or its ring: the header (the mystery title) stays fixed in the band left of
// the lens, where the main screen puts its title, and the body (the mystery's name, its Bible quote and
// the reference) scrolls only inside a fixed window below the lens. The view clips its drawing to that
// window, and the body is wrapped to the window's width, the narrowest visible width over its rows.
// The body wraps at spaces only: Graphics.fitTextToArea also breaks after "«" and before a closing
// ".", which leaves "«" alone at the end of a line and "." alone on the next.
module ReadingLayout {
    // Header: the title wrapped like the main screen's ("1er" / "Misterio" / "Gozoso") and centered on
    // the main screen's title column, high enough that its 3 lines end above the window.
    const HEADER_CENTER_Y = 43;
    const HEADER_PITCH = 19;
    // Body window [left, top, right, bottom]. The lens ring covers the right side of rows 0..72, so the
    // window starts 2px below it (row 75); 4 lines of the tiny font fit down to row 158. The window keeps
    // the 2px margin inside the visible area on every row it covers (rows 73..160 limit it to 21..156).
    const WINDOW_LEFT = 22;
    const WINDOW_TOP = 75;
    const WINDOW_RIGHT = 154;
    const WINDOW_BOTTOM = 158;
    const BODY_PITCH = 20;

    function windowWidth() as Number {
        return WINDOW_RIGHT - WINDOW_LEFT;
    }

    // Body lines shown at once: every one whole inside the window.
    function visibleLines() as Number {
        return (WINDOW_BOTTOM - WINDOW_TOP - Graphics.getFontHeight(Graphics.FONT_TINY)) / BODY_PITCH + 1;
    }

    // First line shown at the last scroll position: the last window of lines.
    function maxOffset(count as Number) as Number {
        var last = count - visibleLines();
        return last > 0 ? last : 0;
    }

    // DOWN moves a whole window of lines on, and stops at the last window, so its pages start at 0, 4,
    // 8, ... and then at the last window (with 10 lines: 0, 4, 6). UP goes back through those same pages
    // (6, 4, 0): to the last whole window before the current first line, and stops at the first line.
    function nextOffset(offset as Number, count as Number) as Number {
        var next = offset + visibleLines();
        var last = maxOffset(count);
        return next < last ? next : last;
    }

    function prevOffset(offset as Number) as Number {
        if (offset <= 0) {
            return 0;
        }
        return (offset - 1) / visibleLines() * visibleLines();
    }

    // The scrolling text: the mystery's name, the quote and its reference, each wrapped to the window.
    function bodyLines(dc as Dc, name as String, quote as String, reference as String) as Array<String> {
        var lines = wrapWords(dc, name);
        lines.addAll(wrapWords(dc, quote));
        lines.addAll(wrapWords(dc, reference));
        return lines;
    }

    // Greedy word wrap at spaces, each line as wide as the window allows in the tiny font. Joined back
    // with spaces, the lines give the text again. (A single word wider than the window would overflow
    // it; no quote has one, and the layout tests would catch it.)
    function wrapWords(dc as Dc, text as String) as Array<String> {
        var lines = [] as Array<String>;
        var width = windowWidth();
        var line = null as String?;
        var rest = text;
        while (rest.length() > 0) {
            var cut = rest.find(" ");
            var word = (cut == null ? rest : rest.substring(0, cut)) as String;
            rest = (cut == null ? "" : rest.substring(cut + 1, rest.length())) as String;
            if (line == null) {
                line = word;
            } else if (dc.getTextWidthInPixels(line + " " + word, Graphics.FONT_TINY) <= width) {
                line = line + " " + word;
            } else {
                lines.add(line);
                line = word;
            }
        }
        if (line != null) {
            lines.add(line);
        }
        return lines;
    }

    // Fixed items: the wrapped title beside the lens and, centered on the subscreen ring at (ringX, ringY),
    // the number of the mystery.
    function headerPlan(titleLines as Array<String>, decade as Number, ringX as Number, ringY as Number) as Array<Layout.TextItem> {
        var items = [] as Array<Layout.TextItem>;
        MainLayout.addLines(items, titleLines, MainLayout.TITLE_X, HEADER_CENTER_Y, HEADER_PITCH);
        items.add(new Layout.TextItem(decade.format("%d"), Graphics.FONT_NUMBER_MILD, ringX, ringY,
            (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER) as Number));
        return items;
    }

    // The body lines shown from the given first line: each centered in the window, one pitch apart.
    function bodyPlan(lines as Array<String>, offset as Number) as Array<Layout.TextItem> {
        var items = [] as Array<Layout.TextItem>;
        var end = offset + visibleLines();
        if (end > lines.size()) {
            end = lines.size();
        }
        var centerX = (WINDOW_LEFT + WINDOW_RIGHT) / 2;
        for (var i = offset; i < end; i++) {
            items.add(new Layout.TextItem(lines[i], Graphics.FONT_TINY, centerX, WINDOW_TOP + (i - offset) * BODY_PITCH,
                Graphics.TEXT_JUSTIFY_CENTER as Number));
        }
        return items;
    }
}

// The Bible quote of each mystery and its reference (resources/strings/quotes.xml), by
// Rosary.mysteryIndex. Only the one being read is loaded.
module Quotes {

    function text(index as Number) as String {
        var ids = [
            Rez.Strings.Quote1, Rez.Strings.Quote2, Rez.Strings.Quote3, Rez.Strings.Quote4, Rez.Strings.Quote5,
            Rez.Strings.Quote6, Rez.Strings.Quote7, Rez.Strings.Quote8, Rez.Strings.Quote9, Rez.Strings.Quote10,
            Rez.Strings.Quote11, Rez.Strings.Quote12, Rez.Strings.Quote13, Rez.Strings.Quote14, Rez.Strings.Quote15,
            Rez.Strings.Quote16, Rez.Strings.Quote17, Rez.Strings.Quote18, Rez.Strings.Quote19, Rez.Strings.Quote20
        ] as Array<ResourceId>;
        return WatchUi.loadResource(ids[index]) as String;
    }

    function reference(index as Number) as String {
        var ids = [
            Rez.Strings.Ref1, Rez.Strings.Ref2, Rez.Strings.Ref3, Rez.Strings.Ref4, Rez.Strings.Ref5,
            Rez.Strings.Ref6, Rez.Strings.Ref7, Rez.Strings.Ref8, Rez.Strings.Ref9, Rez.Strings.Ref10,
            Rez.Strings.Ref11, Rez.Strings.Ref12, Rez.Strings.Ref13, Rez.Strings.Ref14, Rez.Strings.Ref15,
            Rez.Strings.Ref16, Rez.Strings.Ref17, Rez.Strings.Ref18, Rez.Strings.Ref19, Rez.Strings.Ref20
        ] as Array<ResourceId>;
        return WatchUi.loadResource(ids[index]) as String;
    }
}

// Reading view of one mystery: its title fixed beside the lens, its number in the subscreen, and its
// name, Bible quote and reference scrolling in the window below the lens (MysteryDelegate: UP/DOWN
// scroll, BACK returns to the rosary). It never touches the saved progress.
class MysteryView extends WatchUi.View {

    // First body line shown (0..ReadingLayout.maxOffset).
    var offset as Number;
    private var _set as Rosary.MysterySet;
    private var _decade as Number;
    private var _titleLines as Array<String>;
    private var _bodyLines as Array<String>;

    function initialize(set as Rosary.MysterySet, decade as Number) {
        View.initialize();
        offset = 0;
        _set = set;
        _decade = decade;
        _titleLines = MainLayout.wrapTitle(Rosary.mysteryTitle(set, decade));
        _bodyLines = [] as Array<String>;
    }

    // Loads the quote and wraps the body once (wrapping is the costliest part of a render); the body
    // wrap measures text, so it waits for a Dc. A later layout keeps the lines and the scroll position.
    function onLayout(dc as Dc) as Void {
        if (_bodyLines.size() > 0) {
            return;
        }
        var index = Rosary.mysteryIndex(_set, _decade);
        _bodyLines = ReadingLayout.bodyLines(dc, Rosary.mysteryName(_set, _decade), Quotes.text(index), Quotes.reference(index));
    }

    function titleLines() as Array<String> {
        return _titleLines;
    }

    function bodyLines() as Array<String> {
        return _bodyLines;
    }

    // One window of lines down; false (and nothing changes) at the last one.
    function scrollDown() as Boolean {
        return scrollTo(ReadingLayout.nextOffset(offset, _bodyLines.size()));
    }

    // One window of lines up; false (and nothing changes) at the first line.
    function scrollUp() as Boolean {
        return scrollTo(ReadingLayout.prevOffset(offset));
    }

    private function scrollTo(target as Number) as Boolean {
        if (target == offset) {
            return false;
        }
        offset = target;
        return true;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var ring = MainLayout.ring();
        drawItems(dc, ReadingLayout.headerPlan(_titleLines, _decade, ring[0], ring[1]));
        // Belt and braces: whatever the body draws stays inside its window, clear of the lens.
        dc.setClip(ReadingLayout.WINDOW_LEFT, ReadingLayout.WINDOW_TOP, ReadingLayout.windowWidth(),
            ReadingLayout.WINDOW_BOTTOM - ReadingLayout.WINDOW_TOP);
        drawItems(dc, ReadingLayout.bodyPlan(_bodyLines, offset));
        dc.clearClip();
    }

    private function drawItems(dc as Dc, items as Array<Layout.TextItem>) as Void {
        for (var i = 0; i < items.size(); i++) {
            items[i].draw(dc);
        }
    }
}
