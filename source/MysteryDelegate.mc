import Toybox.Lang;
import Toybox.WatchUi;

// Buttons of the reading view: DOWN and UP scroll the text a window at a time and do nothing past
// either end; BACK keeps its default behavior and returns to the rosary on the same bead. Holding UP
// does nothing here: the menu belongs to the rosary screen. Nothing vibrates and nothing is saved.
class MysteryDelegate extends WatchUi.BehaviorDelegate {

    private var _view as MysteryView;

    function initialize(view as MysteryView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // DOWN
    function onNextPage() as Boolean {
        if (_view.scrollDown()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // UP
    function onPreviousPage() as Boolean {
        if (_view.scrollUp()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Hold UP: consumed, so it neither opens the menu again nor scrolls.
    function onMenu() as Boolean {
        return true;
    }
}
