import Toybox.Lang;
import Toybox.WatchUi;

// Buttons of the language picker (LanguageView): DOWN and UP move the selection and stop at either end.
// START saves the selected choice and closes the picker: the rosary reads in the new language at once, and
// so does every screen opened after it; the glance does from its next refresh. BACK closes the picker and
// changes nothing. Holding UP does nothing here. Nothing vibrates.
class LanguageDelegate extends WatchUi.BehaviorDelegate {

    private var _picker as LanguageView;
    private var _rosary as RosaryDelegate;

    function initialize(picker as LanguageView, rosary as RosaryDelegate) {
        BehaviorDelegate.initialize();
        _picker = picker;
        _rosary = rosary;
    }

    // DOWN
    function onNextPage() as Boolean {
        if (_picker.moveDown()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // UP
    function onPreviousPage() as Boolean {
        if (_picker.moveUp()) {
            WatchUi.requestUpdate();
        }
        return true;
    }

    // START: saves the choice, then closes the picker over the rosary, which reads in it.
    function onSelect() as Boolean {
        I18n.saveChoice(_picker.selectedChoice());
        _rosary.languageChanged();
        return true;
    }

    // BACK: back to the rosary, in the language it was in.
    function onBack() as Boolean {
        _rosary.closeMenu();
        return true;
    }

    // Hold UP: consumed, so it neither opens the menu again nor moves the selection.
    function onMenu() as Boolean {
        return true;
    }
}
