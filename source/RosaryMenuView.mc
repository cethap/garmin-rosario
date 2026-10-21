import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Layout of the app's lists, the hold-UP menu and the language picker, shared with the layout tests. The app
// draws its own lists because the system's Menu2 draws its items in a small font that an app cannot change.
// The items use the large font, each centered on its own bar in the full-width rows below the subscreen lens
// (rows 73..135 span the whole screen; below them the bezel narrows the rows). Two bars fill those rows, so
// a list shows two items at a time and scrolls as the selection moves past them, with a scroll bar beside
// the bars. The selected item is drawn inverted, a white bar with black text; any other is white text on
// black. Above the bars sits a header beside the lens: the menu shows the reading view's (the current
// mystery's title, its number in the subscreen, ReadingLayout.headerPlan), so it stays in place when "Read
// mystery" opens.
module MenuLayout {
    // Items shown at once. A third bar would end at row 187, past the screen's last row (175).
    const VISIBLE_ITEMS = 2;
    // Item bars [BAR_LEFT, top, BAR_RIGHT, top + BAR_HEIGHT], the first from FIRST_BAR_TOP and each next
    // one BAR_PITCH lower. The first starts just below the title (the box of its last line ends at row 74);
    // the second ends where the rounding bezel still leaves it the 2px margin (LayoutTests.mc measures them).
    const BAR_LEFT = 14;
    const BAR_RIGHT = 162;
    const FIRST_BAR_TOP = 77;
    const BAR_HEIGHT = 34;
    const BAR_PITCH = 38;
    const BAR_RADIUS = 4;
    // The scroll bar, right of the bars: a 1px track at TRACK_X from TRACK_TOP to TRACK_BOTTOM, centered on
    // the bars, and on it a THUMB_WIDTH thumb whose length and place show the part of the list on screen. The
    // track ends where the bezel still leaves the thumb the 2px margin, rows below included (row 141). The
    // reading view draws the same scroll bar in the same place, beside its window (ReadingLayout.thumb).
    const TRACK_X = 166;
    const TRACK_TOP = 85;
    const TRACK_BOTTOM = 141;
    const THUMB_WIDTH = 3;
    // The shortest thumb, for a long list or text: 8px still reads as a bar, not a dot.
    const THUMB_MIN = 8;
    // The mark of the saved choice in the language picker: a filled disc at the left end of its bar, clear of
    // the widest label ("Automatique", 118px, from x 29).
    const MARK_X = 21;
    const MARK_RADIUS = 3;
    // The lists' background: the views clear the screen with it.
    const BACKGROUND = Graphics.COLOR_BLACK;

    // Screen box [left, top, right, bottom] of the bar in slot 0..VISIBLE_ITEMS - 1.
    function bar(slot as Number) as Array<Number> {
        var top = FIRST_BAR_TOP + slot * BAR_PITCH;
        return [BAR_LEFT, top, BAR_RIGHT, top + BAR_HEIGHT] as Array<Number>;
    }

    // The label shown in a slot, in the large font, centered on its bar. The font box (31px: ascent 24,
    // descent 7) is centered, so the letters, which have no descenders, sit near the bar's middle.
    function label(slot as Number, text as String) as Layout.TextItem {
        var box = bar(slot);
        return new Layout.TextItem(text, Graphics.FONT_LARGE, (box[0] + box[2]) / 2, (box[1] + box[3]) / 2,
            (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER) as Number);
    }

    // Colours of item index while item selected is selected: [text, bar]. The selected item is inverted,
    // black text on a white bar; any other item is white text straight on the black background, with no
    // bar (Graphics.COLOR_TRANSPARENT).
    function itemColors(index as Number, selected as Number) as Array<Number> {
        if (index == selected) {
            return [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE] as Array<Number>;
        }
        return [Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT] as Array<Number>;
    }

    // The first item shown once item selected is selected, the list having shown items from first: the
    // window moves only as far as it must to show the selected item.
    function windowStart(first as Number, selected as Number) as Number {
        if (selected < first) {
            return selected;
        }
        if (selected >= first + VISIBLE_ITEMS) {
            return selected - VISIBLE_ITEMS + 1;
        }
        return first;
    }

    // Box [left, top, right, bottom] of the scroll bar's thumb, with shown items (or lines) on screen out of
    // count, the first of them first: as long as the track times the share on screen, and at least THUMB_MIN;
    // at the top of the track while the first item shows, at its bottom once the last one does, and in
    // proportion between.
    function thumb(first as Number, shown as Number, count as Number) as Array<Number> {
        var track = TRACK_BOTTOM - TRACK_TOP;
        var length = count > shown ? track * shown / count : track;
        if (length < THUMB_MIN) {
            length = THUMB_MIN;
        }
        var offScreen = count - shown;
        var top = TRACK_TOP + (offScreen > 0 ? (track - length) * first / offScreen : 0);
        var left = TRACK_X - THUMB_WIDTH / 2;
        return [left, top, left + THUMB_WIDTH, top + length] as Array<Number>;
    }

    // Draws the scroll bar in white for shown items (or lines) on screen out of count, the first of them first,
    // when they do not all fit on screen; nothing when they do.
    function drawScrollBar(dc as Dc, first as Number, shown as Number, count as Number) as Void {
        if (count <= shown) {
            return;
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(TRACK_X, TRACK_TOP, TRACK_X, TRACK_BOTTOM);
        var box = thumb(first, shown, count);
        dc.fillRectangle(box[0], box[1], box[2] - box[0], box[3] - box[1]);
    }

    // Center and radius [x, y, radius] of the saved choice's mark on the bar in a slot.
    function mark(slot as Number) as Array<Number> {
        var box = bar(slot);
        return [MARK_X, (box[1] + box[3]) / 2, MARK_RADIUS] as Array<Number>;
    }
}

// A list in the lists' style (MenuLayout): two items on screen, one of them selected, under a header the
// subclass draws. moveDown and moveUp stop at either end; the window follows the selection.
class BarListView extends WatchUi.View {

    // Index of the selected item, and of the first one shown.
    var selected as Number;
    var first as Number;
    private var _labels as Array<String>;

    function initialize(labels as Array<String>, selected as Number) {
        View.initialize();
        _labels = labels;
        self.selected = selected;
        first = MenuLayout.windowStart(0, selected);
    }

    function labels() as Array<String> {
        return _labels;
    }

    // One item down; false (and nothing changes) on the last one.
    function moveDown() as Boolean {
        return selectItem(selected + 1);
    }

    // One item up; false (and nothing changes) on the first one.
    function moveUp() as Boolean {
        return selectItem(selected - 1);
    }

    private function selectItem(index as Number) as Boolean {
        if (index < 0 || index >= _labels.size() || index == selected) {
            return false;
        }
        selected = index;
        first = MenuLayout.windowStart(first, selected);
        return true;
    }

    // Whether the item carries the saved choice's mark: none here.
    function isMarked(index as Number) as Boolean {
        return false;
    }

    // What sits above the bars.
    function drawHeader(dc as Dc) as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, MenuLayout.BACKGROUND);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawHeader(dc);
        for (var slot = 0; slot < MenuLayout.VISIBLE_ITEMS && first + slot < _labels.size(); slot++) {
            var index = first + slot;
            var colors = MenuLayout.itemColors(index, selected);
            if (colors[1] != Graphics.COLOR_TRANSPARENT) {
                var bar = MenuLayout.bar(slot);
                dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(bar[0], bar[1], bar[2] - bar[0], bar[3] - bar[1], MenuLayout.BAR_RADIUS);
            }
            dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
            MenuLayout.label(slot, _labels[index]).draw(dc);
            if (isMarked(index)) {
                var mark = MenuLayout.mark(slot);
                dc.fillCircle(mark[0], mark[1], mark[2]);
            }
        }
        MenuLayout.drawScrollBar(dc, first, MenuLayout.VISIBLE_ITEMS, _labels.size());
    }
}

// The hold-UP menu: the title of the current mystery (and its number in the subscreen) over "Read
// mystery", "Language" and "Restart" in large type, "Read mystery" selected first (RosaryMenuDelegate:
// UP/DOWN move the selection, START opens the selected item, BACK returns to the rosary). It never touches
// the saved progress.
class RosaryMenuView extends BarListView {

    private var _decade as Number;
    private var _title as String;
    private var _titleLines as Array<String>;
    // What each item opens, in order.
    private var _ids as Array<Symbol>;

    function initialize(set as Rosary.MysterySet, decade as Number) {
        BarListView.initialize([I18n.text(I18n.MenuRead), I18n.text(I18n.MenuLanguage), I18n.text(I18n.MenuReset)]
            as Array<String>, 0);
        _decade = decade;
        _title = Rosary.mysteryTitle(set, decade);
        _titleLines = MainLayout.wrapTitle(_title);
        _ids = [:read, :language, :reset] as Array<Symbol>;
    }

    function title() as String {
        return _title;
    }

    function titleLines() as Array<String> {
        return _titleLines;
    }

    // What the selected item opens: :read, :language or :reset.
    function selectedId() as Symbol {
        return _ids[selected];
    }

    function drawHeader(dc as Dc) as Void {
        var ring = MainLayout.ring();
        var header = ReadingLayout.headerPlan(_titleLines, _decade, ring[0], ring[1]);
        for (var i = 0; i < header.size(); i++) {
            header[i].draw(dc);
        }
    }
}
