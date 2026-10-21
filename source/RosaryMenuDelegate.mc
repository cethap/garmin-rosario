import Toybox.Lang;
import Toybox.WatchUi;

// Buttons of the hold-UP menu (RosaryMenuView): DOWN and UP move the selection and stop at either end.
// START closes the menu, then opens the selected item over the rosary: "Leer misterio" the reading view,
// "Reiniciar" the "¿Reiniciar el rosario?" confirmation, so BACK from either lands on the rosary, on the
// same bead. BACK closes the menu. Holding UP does nothing here. Nothing vibrates and nothing is saved.
class RosaryMenuDelegate extends WatchUi.BehaviorDelegate {

    private var _menu as RosaryMenuView;
    private var _rosary as RosaryDelegate;

    function initialize(menu as RosaryMenuView, rosary as RosaryDelegate) {
        BehaviorDelegate.initialize();
        _menu = menu;
        _rosary = rosary;
    }

    // DOWN
    function onNextPage() as Boolean {
        if (_menu.moveDown()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // UP
    function onPreviousPage() as Boolean {
        if (_menu.moveUp()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // START: the menu closes first, so the item opens over the rosary.
    function onSelect() as Boolean {
        var id = _menu.selectedId();
        _rosary.closeMenu();
        if (id == :read) {
            _rosary.readMystery();
        } else if (id == :reset) {
            _rosary.confirmRestart();
        }
        return true;
    }

    // BACK: back to the rosary, on the same bead.
    function onBack() as Boolean {
        _rosary.closeMenu();
        return true;
    }

    // Hold UP: consumed, so it neither opens the menu again nor moves the selection.
    function onMenu() as Boolean {
        return true;
    }
}
