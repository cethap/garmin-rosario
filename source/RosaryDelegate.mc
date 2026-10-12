import Toybox.Attention;
import Toybox.Lang;
import Toybox.WatchUi;

// Button input for the main widget screen: START and DOWN move to the next bead (on the Salve, they
// pray it and finish the rosary), UP to the previous one. BACK keeps its default behavior (exit);
// every move is already saved.
class RosaryDelegate extends WatchUi.BehaviorDelegate {

    private var _view as RosaryView;
    private var _dateKey as Number;

    function initialize(view as RosaryView, dateKey as Number) {
        BehaviorDelegate.initialize();
        _view = view;
        _dateKey = dateKey;
    }

    // START
    function onSelect() as Boolean {
        return moveTo(Rosary.next(_view.step));
    }

    // DOWN
    function onNextPage() as Boolean {
        return moveTo(Rosary.next(_view.step));
    }

    // UP
    function onPreviousPage() as Boolean {
        return moveTo(Rosary.prev(_view.step));
    }

    // Shows, saves and vibrates a move. Presses past either end are consumed without feedback.
    private function moveTo(target as Number) as Boolean {
        var vibe = Rosary.vibeForMove(_view.step, target);
        if (vibe == Rosary.VIBE_NONE) {
            return true;
        }
        _view.showStep(target);
        getApp().saveProgress(target, _dateKey);
        pulse(vibe);
        return true;
    }

    // Short pulse per bead, three pulses into a decade's Gloria, one long pulse when the Salve is
    // prayed and the rosary ends.
    private function pulse(vibe as Rosary.Vibe) as Void {
        if (!(Attention has :vibrate)) {
            return;
        }
        var pattern;
        if (vibe == Rosary.VIBE_GLORIA) {
            pattern = [
                new Attention.VibeProfile(100, 150),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(100, 150),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(100, 150)
            ];
        } else if (vibe == Rosary.VIBE_END) {
            pattern = [new Attention.VibeProfile(100, 1000)];
        } else {
            pattern = [new Attention.VibeProfile(50, 100)];
        }
        Attention.vibrate(pattern);
    }
}
