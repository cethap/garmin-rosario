import Toybox.Attention;
import Toybox.Lang;
import Toybox.WatchUi;

// Button input for the main widget screen: START and DOWN move to the next bead (on the Salve, they
// pray it and finish the rosary), UP to the previous one, and holding UP (MENU) opens a menu to read
// the current mystery or start the day over. BACK keeps its default behavior (exit); every move is
// already saved.
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

    // Hold UP: the app's menu with "Leer misterio" and "Reiniciar" under the title of the mystery it
    // reads (RosaryMenuView); RosaryMenuDelegate answers it.
    function onMenu() as Boolean {
        var menu = new RosaryMenuView(_view.mysterySet, Rosary.readingDecade(_view.step));
        WatchUi.pushView(menu, new RosaryMenuDelegate(menu, self), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    // Closes the menu, which sits on top of this screen: before the menu opens an item, so BACK from
    // that item lands here, and on BACK in the menu.
    function closeMenu() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // "Leer misterio": the reading view of the current mystery (Rosary.readingDecade). BACK returns
    // here, on the same bead; nothing is saved and nothing vibrates.
    function readMystery() as Void {
        var view = new MysteryView(_view.mysterySet, Rosary.readingDecade(_view.step));
        WatchUi.pushView(view, new MysteryDelegate(view), WatchUi.SLIDE_LEFT);
    }

    // "Reiniciar": asks "¿Reiniciar el rosario?"; ResetDelegate calls restart on YES.
    function confirmRestart() as Void {
        WatchUi.pushView(new WatchUi.Confirmation(I18n.text(I18n.ResetPrompt)), new ResetDelegate(self),
            WatchUi.SLIDE_IMMEDIATE);
    }

    // Starts today's rosary over: forgets the saved progress (the glance reads "Sin empezar" again),
    // shows the Credo and gives one short pulse. As on opening, nothing is saved until a bead moves.
    function restart() as Void {
        getApp().resetProgress();
        _view.showStep(0);
        pulse(Rosary.VIBE_SHORT);
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

    // Plays Rosary.vibePattern: a short pulse per bead, three strong pulses into each Gloria,
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
