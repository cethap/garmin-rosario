import Toybox.Lang;
import Toybox.WatchUi;

// Answer to "¿Reiniciar el rosario?", asked from "Reiniciar" in the hold-UP menu: YES starts today's
// rosary over, NO leaves everything as it was. The system closes the confirmation either way.
class ResetDelegate extends WatchUi.ConfirmationDelegate {

    private var _rosary as RosaryDelegate;

    function initialize(rosary as RosaryDelegate) {
        ConfirmationDelegate.initialize();
        _rosary = rosary;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _rosary.restart();
        }
        return true;
    }
}
