import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

// Tests of the language picker (LanguageView and LanguageDelegate), opened from "Language" in the hold-UP
// menu. A recording rosary delegate (MenuFake.RecordingRosary) stands in for the real one, so closing the
// picker is recorded instead of popping a view; the rosary view itself is real. Each test uses the real
// Storage and puts back the saved choice that was there.

(:test)
module PickerCheck {

    // The prayer on the rosary's main screen at step 13, the 7th Avemaría of the 1st decade, in each language.
    function prayers() as Array<String> {
        return ["Hail Mary 7", "Avemaría 7", "Je vous salue Marie"] as Array<String>;
    }

    // The main screen's title there, for the Sorrowful mysteries.
    function titles() as Array<String> {
        return ["1st Sorrowful Mystery", "1er Misterio Doloroso", "1er mystère douloureux"] as Array<String>;
    }

    // Opens the picker over a rosary on step 13 of the Sorrowful mysteries, with the choice saved first:
    // [the rosary view, the recording rosary delegate, the picker, its delegate].
    function open(saved as I18n.Choice) as Array {
        I18n.saveChoice(saved);
        var rosaryView = new RosaryView(13, Rosary.SORROWFUL);
        rosaryView.onLayout(ScreenArea.measuringDc());
        var rosary = new MenuFake.RecordingRosary(rosaryView);
        var picker = new LanguageView();
        return [rosaryView, rosary, picker, new LanguageDelegate(picker, rosary)];
    }

    // Puts back the saved choice that was there before a test.
    function restore(before) as Void {
        if (before == null) {
            Application.Storage.deleteValue(I18n.CHOICE_KEY);
        } else {
            Application.Storage.setValue(I18n.CHOICE_KEY, before as Application.PropertyValueType);
        }
        I18n.reset();
    }
}

// The picker opens on the saved choice, which it marks, and lists Automatic in the current language, then
// each language in its own: "English", "Español", "Français". DOWN and UP move the selection and stop at
// either end (no wrap-around), the two-item window following it; hold UP does nothing; none of them saves
// or closes anything. BACK closes the picker and changes nothing: the saved choice and the rosary's texts
// stay as they were.
(:test)
function languagePickerStopsAtBothEndsAndBackCancels(logger as Logger) as Boolean {
    var before = Application.Storage.getValue(I18n.CHOICE_KEY);
    var autos = ["Automatic", "Automático", "Automatique"];
    var ok = true;
    try {
        var choices = [I18n.AUTOMATIC, I18n.ENGLISH, I18n.SPANISH, I18n.FRENCH] as Array<I18n.Choice>;
        for (var c = 0; c < choices.size(); c++) {
            var opened = PickerCheck.open(choices[c]);
            var rosaryView = opened[0] as RosaryView;
            var rosary = opened[1] as MenuFake.RecordingRosary;
            var picker = opened[2] as LanguageView;
            var delegate = opened[3] as LanguageDelegate;
            var prayer = rosaryView.prayer();
            var labels = picker.labels();
            var marked = [];
            for (var i = 0; i < labels.size(); i++) {
                marked.add(picker.isMarked(i));
            }
            var start = picker.selected;
            var trail = [];
            var handled = true;
            for (var i = 0; i < 4; i++) {
                handled = delegate.onPreviousPage() && handled;
            }
            trail.add(picker.selected + "/" + picker.first);
            for (var i = 0; i < 4; i++) {
                handled = delegate.onNextPage() && handled;
                trail.add(picker.selected + "/" + picker.first);
            }
            handled = delegate.onMenu() && handled;
            for (var i = 0; i < 3; i++) {
                handled = delegate.onPreviousPage() && handled;
                trail.add(picker.selected + "/" + picker.first);
            }
            var quiet = rosary.calls.size() == 0 && I18n.loadChoice() == choices[c];
            var back = delegate.onBack();
            var language = I18n.language() as Number;
            logger.debug("saved " + choices[c] + ": labels=" + labels + " marked=" + marked + " opened on " + start
                + " trail=" + trail + " handled=" + handled + " quiet=" + quiet + " back=" + back + " calls=" + rosary.calls
                + " prayer '" + prayer + "' -> '" + rosaryView.prayer() + "'");
            var expectedMarks = [false, false, false, false];
            expectedMarks[c] = true;
            ok = handled && quiet && back && start == choices[c] && picker.saved() == choices[c]
                && marked.toString().equals(expectedMarks.toString())
                && labels.toString().equals([autos[language], "English", "Español", "Français"].toString())
                && trail.toString().equals(["0/0", "1/0", "2/1", "3/2", "3/2", "2/2", "1/1", "0/0"].toString())
                && rosary.calls.toString().equals(["close"].toString()) && I18n.loadChoice() == choices[c]
                && rosaryView.prayer().equals(prayer) && ok;
        }
    } finally {
        PickerCheck.restore(before);
    }
    return ok;
}

// START saves the selected choice and closes the picker: the saved choice reads back as it, and the language
// follows it (Automatic follows the watch). It is the selected item, not the marked one, that START saves.
(:test)
function languagePickerSavesTheSelectedChoice(logger as Logger) as Boolean {
    var before = Application.Storage.getValue(I18n.CHOICE_KEY);
    var watch = System.getDeviceSettings().systemLanguage;
    var ok = true;
    try {
        var choices = [I18n.AUTOMATIC, I18n.ENGLISH, I18n.SPANISH, I18n.FRENCH] as Array<I18n.Choice>;
        for (var c = 0; c < choices.size(); c++) {
            var saved = choices[(c + 1) % choices.size()];
            var opened = PickerCheck.open(saved);
            var rosary = opened[1] as MenuFake.RecordingRosary;
            var picker = opened[2] as LanguageView;
            var delegate = opened[3] as LanguageDelegate;
            for (var i = 0; i < 3; i++) {
                delegate.onPreviousPage();
            }
            for (var i = 0; i < c; i++) {
                delegate.onNextPage();
            }
            var selected = picker.selected;
            var handled = delegate.onSelect();
            var read = I18n.loadChoice();
            var language = I18n.language();
            logger.debug("saved " + saved + ", selected " + selected + ", START handled=" + handled + " -> saved " + read
                + " language " + language + " calls=" + rosary.calls);
            ok = handled && selected == choices[c] && read == choices[c] && language == I18n.resolve(choices[c], watch)
                && rosary.calls.toString().equals(["close"].toString()) && ok;
        }
    } finally {
        PickerCheck.restore(before);
    }
    return ok;
}

// Choosing a language in the picker changes the rosary's texts at once, on the same bead: the prayer and the
// title under the clock read in the new language as soon as the picker closes.
(:test)
function rosaryReadsInTheChosenLanguageAtOnce(logger as Logger) as Boolean {
    var before = Application.Storage.getValue(I18n.CHOICE_KEY);
    var ok = true;
    try {
        // English first, then Spanish, French and back to English: each time from the language before.
        var choices = [I18n.SPANISH, I18n.FRENCH, I18n.ENGLISH] as Array<I18n.Choice>;
        var languages = [I18n.SPA, I18n.FRE, I18n.ENG];
        var saved = I18n.ENGLISH;
        for (var c = 0; c < choices.size(); c++) {
            var opened = PickerCheck.open(saved);
            var rosaryView = opened[0] as RosaryView;
            var delegate = opened[3] as LanguageDelegate;
            var prayer = rosaryView.prayer();
            var title = rosaryView.titleLines().toString();
            for (var i = 0; i < 3; i++) {
                delegate.onPreviousPage();
            }
            for (var i = 0; i < choices[c]; i++) {
                delegate.onNextPage();
            }
            delegate.onSelect();
            var after = rosaryView.prayer();
            var titleAfter = rosaryView.titleLines().toString();
            logger.debug("'" + prayer + "' " + title + " -> '" + after + "' " + titleAfter + " step " + rosaryView.step);
            var language = languages[c] as Number;
            ok = !after.equals(prayer) && after.equals(PickerCheck.prayers()[language])
                && titleAfter.equals(MainLayout.wrapTitle(PickerCheck.titles()[language]).toString()) && rosaryView.step == 13
                && ok;
            saved = choices[c];
        }
    } finally {
        PickerCheck.restore(before);
    }
    return ok;
}
