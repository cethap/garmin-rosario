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

    // Plays Rosary.vibePattern: a short pulse per bead, three strong pulses into a decade's Gloria,
    // one long pulse when the Salve is prayed and the rosary ends.
    private function pulse(vibe as Rosary.Vibe) as Void {
        var pattern = Rosary.vibePattern(vibe);
        if (!(Attention has :vibrate) || pattern.size() == 0) {
            return;
        }
        var profiles = [] as Array<Attention.VibeProfile>;
        for (var i = 0; i < pattern.size(); i++) {
            profiles.add(new Attention.VibeProfile(pattern[i][0], pattern[i][1]));
        }
        Attention.vibrate(profiles);
    }
}
