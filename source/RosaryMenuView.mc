import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Layout of the hold-UP menu, shared with the layout tests. The app draws its own menu because the
// system's Menu2 draws its items in a small font that an app cannot change. The two items use the large
// font, each centered on its own bar in the full-width rows below the subscreen lens (rows 73..135 span
// the whole screen; below them the bezel narrows the rows). The selected item is drawn inverted, a white
// bar with black text; the other is white text on black. Above them sits the reading view's header (the
// current mystery's title beside the lens, its number in the subscreen, ReadingLayout.headerPlan), so it
// stays in place when "Leer misterio" opens.
module MenuLayout {
    const ITEM_COUNT = 2;
    // Item bars [BAR_LEFT, top, BAR_RIGHT, top + BAR_HEIGHT], the first from FIRST_BAR_TOP and each next
    // one BAR_PITCH lower. The first starts just below the title (the box of its last line ends at row 74);
    // the second ends where the rounding bezel still leaves it the 2px margin (LayoutTests.mc measures them).
    const BAR_LEFT = 14;
    const BAR_RIGHT = 162;
    const FIRST_BAR_TOP = 77;
    const BAR_HEIGHT = 34;
    const BAR_PITCH = 38;
    const BAR_RADIUS = 4;

    // Screen box [left, top, right, bottom] of item index's bar.
    function bar(index as Number) as Array<Number> {
        var top = FIRST_BAR_TOP + index * BAR_PITCH;
        return [BAR_LEFT, top, BAR_RIGHT, top + BAR_HEIGHT] as Array<Number>;
    }

    // The label of item index in the large font, centered on its bar. The font box (31px: ascent 24,
    // descent 7) is centered, so the letters, which have no descenders, sit near the bar's middle.
    function label(index as Number, text as String) as Layout.TextItem {
        var box = bar(index);
        return new Layout.TextItem(text, Graphics.FONT_LARGE, (box[0] + box[2]) / 2, (box[1] + box[3]) / 2,
            (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER) as Number);
    }
}

// The hold-UP menu: the title of the current mystery (and its number in the subscreen) over "Leer
// misterio" and "Reiniciar" in large type, "Leer misterio" selected first (RosaryMenuDelegate: UP/DOWN
// move the selection, START opens the selected item, BACK returns to the rosary). It never touches the
// saved progress.
class RosaryMenuView extends WatchUi.View {

    // Index of the selected item (0..MenuLayout.ITEM_COUNT - 1).
    var selected as Number;
    private var _decade as Number;
    private var _title as String;
    private var _titleLines as Array<String>;
    // The items in order: what each one opens, and its label.
    private var _ids as Array<Symbol>;
    private var _labels as Array<String>;

    function initialize(set as Rosary.MysterySet, decade as Number) {
        View.initialize();
        selected = 0;
        _decade = decade;
        _title = Rosary.mysteryTitle(set, decade);
        _titleLines = MainLayout.wrapTitle(_title);
        _ids = [:read, :reset] as Array<Symbol>;
        _labels = [
            WatchUi.loadResource(Rez.Strings.MenuRead) as String,
            WatchUi.loadResource(Rez.Strings.MenuReset) as String
        ] as Array<String>;
    }

    function title() as String {
        return _title;
    }

    function titleLines() as Array<String> {
        return _titleLines;
    }

    function labels() as Array<String> {
        return _labels;
    }

    // What the selected item opens: :read or :reset.
    function selectedId() as Symbol {
        return _ids[selected];
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
        if (index < 0 || index >= _ids.size() || index == selected) {
            return false;
        }
        selected = index;
        return true;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var ring = MainLayout.ring();
        var header = ReadingLayout.headerPlan(_titleLines, _decade, ring[0], ring[1]);
        for (var i = 0; i < header.size(); i++) {
            header[i].draw(dc);
        }
        for (var i = 0; i < _labels.size(); i++) {
            if (i == selected) {
                var bar = MenuLayout.bar(i);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(bar[0], bar[1], bar[2] - bar[0], bar[3] - bar[1], MenuLayout.BAR_RADIUS);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }
            MenuLayout.label(i, _labels[i]).draw(dc);
        }
    }
}
