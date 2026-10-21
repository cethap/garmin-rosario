import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Layout of the language picker, shared with the layout tests: the lists' bars (MenuLayout) under a title
// beside the lens, where the menu shows the mystery's title.
module LanguageLayout {

    // The items, in I18n.Choice order: Automatic in the current language, then each language named in its
    // own, the same whatever the language. Latin, which no watch language is, can be chosen only here.
    function labels() as Array<String> {
        return [I18n.text(I18n.LanguageAutomatic), "English", "Español", "Français", "Latina"] as Array<String>;
    }

    // The title, "Language" as the menu names the picker, wrapped like the menu's title and centered on the
    // same column beside the lens.
    function headerPlan(titleLines as Array<String>) as Array<Layout.TextItem> {
        var items = [] as Array<Layout.TextItem>;
        MainLayout.addLines(items, titleLines, MainLayout.TITLE_X, ReadingLayout.HEADER_CENTER_Y, ReadingLayout.HEADER_PITCH);
        return items;
    }
}

// The language picker, opened from "Language" in the hold-UP menu: Automatic, which follows the watch, and
// the four languages, the saved choice marked with a dot and selected first (LanguageDelegate: UP/DOWN move
// the selection, START chooses, BACK returns to the rosary).
class LanguageView extends BarListView {

    private var _saved as I18n.Choice;
    private var _titleLines as Array<String>;

    function initialize() {
        var saved = I18n.loadChoice();
        BarListView.initialize(LanguageLayout.labels(), saved as Number);
        _saved = saved;
        _titleLines = MainLayout.wrapTitle(I18n.text(I18n.MenuLanguage));
    }

    // The choice saved when the picker opened.
    function saved() as I18n.Choice {
        return _saved;
    }

    // The choice of the selected item.
    function selectedChoice() as I18n.Choice {
        return selected as I18n.Choice;
    }

    function titleLines() as Array<String> {
        return _titleLines;
    }

    function isMarked(index as Number) as Boolean {
        return index == _saved;
    }

    function drawHeader(dc as Dc) as Void {
        var header = LanguageLayout.headerPlan(_titleLines);
        for (var i = 0; i < header.size(); i++) {
            header[i].draw(dc);
        }
    }
}
