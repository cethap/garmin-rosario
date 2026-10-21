import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

// The language the app reads in, and the lookups that read its texts.
//
// An app can load string resources only in the watch's language, so every text the app shows is a JSON
// table per language instead (i18n/<lang>.json, which scripts/gen-i18n.py turns into resources/i18n and the
// keys in I18nKeys.mc). A lookup loads its table in the current language, takes the one text and lets the
// table go, so no table stays in memory. A text made of parts is a template whose $1$, $2$ Lang.format
// fills in, so each language can order its words. Views look a text up once and keep it, never on every
// frame.
//
// The glance can load only the glance table, the one glance-scoped table: loading any other one there
// crashes it with "Symbol Not Found", and the compiler does not warn. So this part, which the glance loads,
// looks up glance texts only (glanceText), and text, which loads any table, lives outside the glance
// (scripts/check-glance-strings.py checks both).
(:glance)
module I18n {

    // The language option: Automatic follows the watch; the others read in one language whatever the
    // watch's. Latin is only ever chosen here: no watch is set to Latin, so Automatic never reads it.
    enum Choice {
        AUTOMATIC,
        ENGLISH,
        SPANISH,
        FRENCH,
        LATIN
    }

    // Application.Storage key of the saved choice. The glance reads it too.
    const CHOICE_KEY = "language";

    // The language every lookup reads in, resolved at the first lookup from the saved choice and the
    // watch's language; null until then, and again after reset.
    var current as Language? = null;

    function language() as Language {
        if (current == null) {
            current = resolve(loadChoice(), System.getDeviceSettings().systemLanguage);
        }
        return current as Language;
    }

    // Makes the next lookup resolve the language again: after a new choice, and on each glance refresh.
    function reset() as Void {
        current = null;
    }

    // Makes every lookup read the given language until the next reset (the tests read each language so).
    function setLanguage(language as Language) as Void {
        current = language;
    }

    // The language a choice reads in on a watch set to systemLanguage. Automatic reads Spanish on a watch
    // in Spanish, French on one in French, and English on any other, as the app did before the option; it
    // never reads Latin, which no watch language is.
    function resolve(choice as Choice, systemLanguage as System.Language) as Language {
        if (choice == ENGLISH) {
            return ENG;
        }
        if (choice == SPANISH) {
            return SPA;
        }
        if (choice == FRENCH) {
            return FRE;
        }
        if (choice == LATIN) {
            return LAT;
        }
        if (systemLanguage == System.LANGUAGE_SPA) {
            return SPA;
        }
        if (systemLanguage == System.LANGUAGE_FRE) {
            return FRE;
        }
        return ENG;
    }

    // The saved choice.
    function loadChoice() as Choice {
        return decodeChoice(Storage.getValue(CHOICE_KEY));
    }

    // A stored value as a choice: Automatic when it is missing or is not a choice.
    function decodeChoice(stored) as Choice {
        if (stored instanceof Number && stored >= AUTOMATIC && stored <= LATIN) {
            return stored as Choice;
        }
        return AUTOMATIC;
    }

    // A text of the glance table, by its key (I18nKeys.mc), in the current language.
    function glanceText(key as Number) as String {
        var texts = Application.loadResource(glanceTable(language())) as Array<String>;
        return texts[key];
    }
}

// The lookups only the full-screen widget makes.
module I18n {

    // Any text, by its key (I18nKeys.mc), in the current language.
    function text(key as Number) as String {
        var texts = Application.loadResource(tableId(key / TABLE_KEYS, language())) as Array<String>;
        return texts[key % TABLE_KEYS];
    }

    // Saves the choice, which every screen reads in from the next lookup on, and the glance from its next
    // refresh.
    function saveChoice(choice as Choice) as Void {
        Storage.setValue(CHOICE_KEY, choice as Number);
        reset();
    }
}
