import Toybox.Lang;
import Toybox.WatchUi;

// Menu on hold UP (MENU) on the main screen: "Leer el misterio", with the title of the mystery it
// opens as sublabel ("1er Misterio Gozoso"), and "Reiniciar".
module RosaryMenu {

    function build(position as Number, set as Rosary.MysterySet) as WatchUi.Menu2 {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.AppName});
        var title = Rosary.mysteryTitle(set, Rosary.readingDecade(position));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuRead, title, :read, null));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuReset, null, :reset, null));
        return menu;
    }
}

// Answer to the menu: the menu closes, then "Leer el misterio" opens the reading view and "Reiniciar"
// asks "¿Reiniciar el rosario?" as before. Either way BACK lands on the rosary, on the same bead.
class RosaryMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _rosary as RosaryDelegate;

    function initialize(rosary as RosaryDelegate) {
        Menu2InputDelegate.initialize();
        _rosary = rosary;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        if (id == :read) {
            _rosary.readMystery();
        } else if (id == :reset) {
            _rosary.confirmRestart();
        }
    }
}
