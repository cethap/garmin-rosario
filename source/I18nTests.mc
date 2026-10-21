import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

// Tests of the language the app reads in (I18n.mc) and of its tables. One test build covers every language:
// a test that reads a text sets the language first with TestLanguage.use, and the tests that do not pin a
// language's own words run once in each language.

(:test)
module TestLanguage {

    // The languages' codes, in I18n.Language order, for the logs.
    function code(language as Number) as String {
        return ["eng", "spa", "fre"][language];
    }

    // Makes every lookup read in the language, and names it in the test's log.
    function use(logger as Logger, language as Number) as Void {
        I18n.setLanguage(language as I18n.Language);
        logger.debug("language=" + code(language));
    }
}

(:test)
module TableCheck {

    // Most memory one loaded table may hold, in bytes. A lookup loads its whole table, so this bounds what a
    // lookup adds to the widget's peak. Measured: 784 to 1200 (the Spanish mysteries). The quotes are split by
    // mystery set to stay under it: all 20 in one table held 3.2 to 3.5 KB.
    const BUDGET = 1536;
    // The glance's table, which the glance loads inside its 32KB. Measured: 360 in each language.
    const GLANCE_BUDGET = 512;

    // Memory a table holds once loaded, and whether it is whole: as many texts as English's, none empty.
    // Returns [bytes held, texts in the table, whole].
    function load(table as Number, language as Number) as Array {
        var before = System.getSystemStats().usedMemory;
        var texts = Application.loadResource(I18n.tableId(table, language as I18n.Language)) as Array;
        var held = System.getSystemStats().usedMemory - before;
        var whole = texts.size() > 0;
        for (var i = 0; whole && i < texts.size(); i++) {
            whole = texts[i] instanceof String && (texts[i] as String).length() > 0;
        }
        return [held, texts.size(), whole];
    }
}

// Names the suite in its log, so scripts/test-all.sh can tell this build's output from another app's.
(:test)
function suiteCoversEveryLanguage(logger as Logger) as Boolean {
    logger.debug("suite=rosario languages=" + I18n.LANGUAGE_COUNT);
    var codes = "";
    for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
        codes += (language > 0 ? "," : "") + TestLanguage.code(language);
    }
    return I18n.LANGUAGE_COUNT == 3 && codes.equals("eng,spa,fre") && I18n.ENG == 0 && I18n.SPA == 1 && I18n.FRE == 2;
}

// Automatic follows the watch: Spanish on a watch in Spanish, French on one in French, English on any other
// (German and Portuguese among them). Any other choice reads in its own language whatever the watch's.
(:test)
function resolveFollowsTheChoiceThenTheWatch(logger as Logger) as Boolean {
    var watches = [System.LANGUAGE_ENG, System.LANGUAGE_SPA, System.LANGUAGE_FRE, System.LANGUAGE_DEU,
        System.LANGUAGE_POR] as Array<System.Language>;
    var choices = [I18n.AUTOMATIC, I18n.ENGLISH, I18n.SPANISH, I18n.FRENCH] as Array<I18n.Choice>;
    var expected = [
        [I18n.ENG, I18n.SPA, I18n.FRE, I18n.ENG, I18n.ENG],
        [I18n.ENG, I18n.ENG, I18n.ENG, I18n.ENG, I18n.ENG],
        [I18n.SPA, I18n.SPA, I18n.SPA, I18n.SPA, I18n.SPA],
        [I18n.FRE, I18n.FRE, I18n.FRE, I18n.FRE, I18n.FRE]
    ];
    var ok = true;
    for (var c = 0; c < choices.size(); c++) {
        var actual = [];
        for (var w = 0; w < watches.size(); w++) {
            actual.add(I18n.resolve(choices[c], watches[w]));
        }
        logger.debug("choice " + choices[c] + " on watches eng,spa,fre,deu,por: " + actual);
        ok = ok && actual.toString().equals(expected[c].toString());
    }
    return ok;
}

// The saved choice reads back as itself, and the language follows it at once. A missing value, or one that
// is not a choice, reads as Automatic. Uses the real Storage and puts back what was there.
(:test)
function savedChoiceRoundTripsAndInvalidReadsAsAutomatic(logger as Logger) as Boolean {
    var before = Application.Storage.getValue(I18n.CHOICE_KEY);
    var watch = System.getDeviceSettings().systemLanguage;
    var ok = false;
    try {
        Application.Storage.deleteValue(I18n.CHOICE_KEY);
        var missing = I18n.loadChoice();
        var trips = "";
        var tripsOk = true;
        var choices = [I18n.ENGLISH, I18n.FRENCH, I18n.SPANISH, I18n.AUTOMATIC] as Array<I18n.Choice>;
        for (var i = 0; i < choices.size(); i++) {
            I18n.saveChoice(choices[i]);
            var read = I18n.loadChoice();
            var language = I18n.language();
            trips += " " + choices[i] + "->" + read + "/" + language;
            tripsOk = tripsOk && read == choices[i] && language == I18n.resolve(choices[i], watch);
        }
        var stored = [-1, 4, "1", 1.0, [2], true] as Array<Application.PropertyValueType>;
        var invalid = "";
        var invalidOk = I18n.decodeChoice(null) == I18n.AUTOMATIC;
        for (var i = 0; i < stored.size(); i++) {
            Application.Storage.setValue(I18n.CHOICE_KEY, stored[i]);
            var read = I18n.loadChoice();
            invalid += " " + stored[i] + "->" + read;
            invalidOk = invalidOk && read == I18n.AUTOMATIC;
        }
        logger.debug("missing->" + missing + " saved:" + trips + " invalid:" + invalid);
        ok = missing == I18n.AUTOMATIC && tripsOk && invalidOk;
    } finally {
        if (before == null) {
            Application.Storage.deleteValue(I18n.CHOICE_KEY);
        } else {
            Application.Storage.setValue(I18n.CHOICE_KEY, before as Application.PropertyValueType);
        }
        I18n.reset();
    }
    return ok;
}

// Every table of every language is whole (as many texts as English's, none empty) and small: loading one,
// as each lookup does, holds at most TableCheck.BUDGET, and the glance's table at most GLANCE_BUDGET.
(:test)
function everyTableIsWholeAndSmall(logger as Logger) as Boolean {
    // Warm-up: the first table a run loads also pays a one-time cost (576 bytes measured), so it is loaded
    // once before the measurements.
    TableCheck.load(0, I18n.ENG);
    var ok = true;
    for (var table = 0; table < I18n.TABLE_COUNT; table++) {
        var budget = table == 0 ? TableCheck.GLANCE_BUDGET : TableCheck.BUDGET;
        var sizes = [] as Array<Number>;
        var held = [] as Array<Number>;
        for (var language = 0; language < I18n.LANGUAGE_COUNT; language++) {
            var loaded = TableCheck.load(table, language);
            held.add(loaded[0] as Number);
            sizes.add(loaded[1] as Number);
            ok = ok && (loaded[2] as Boolean) && loaded[1] == sizes[0] && loaded[0] > 0 && (loaded[0] as Number) <= budget;
        }
        logger.debug("table " + table + ": " + sizes[0] + " texts; bytes held eng,spa,fre " + held + " (budget " + budget + ")");
    }
    return ok;
}
