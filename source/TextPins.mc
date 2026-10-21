import Toybox.Lang;
import Toybox.Test;

// The checks behind the tests that pin texts. A test about a text itself (a label, a title, a name) pins
// it word for word, so each language has its own pins: PinsEng.mc, PinsSpa.mc and PinsFre.mc define the
// same tests, each named with its language's suffix, and call these checks with that language and its
// words. Each check reads in the language it is given (TestLanguage.use), so the one test build runs every
// language's pins.
(:test)
module TextPins {

    // The set names in MysterySet order, comma-joined: in plural as the glance shows them, and in singular
    // as the mystery titles use them.
    function setNames(logger as Logger, language as Number, plural as String, singular as String) as Boolean {
        TestLanguage.use(logger, language);
        var plurals = Rosary.setNamePlural(Rosary.JOYFUL) + "," + Rosary.setNamePlural(Rosary.SORROWFUL) + ","
            + Rosary.setNamePlural(Rosary.GLORIOUS) + "," + Rosary.setNamePlural(Rosary.LUMINOUS);
        var singulars = Rosary.setNameSingular(Rosary.JOYFUL) + "," + Rosary.setNameSingular(Rosary.SORROWFUL) + ","
            + Rosary.setNameSingular(Rosary.GLORIOUS) + "," + Rosary.setNameSingular(Rosary.LUMINOUS);
        logger.debug("plural=" + plurals + " singular=" + singulars);
        return plurals.equals(plural) && singulars.equals(singular);
    }

    // One mystery of each set (the 1st Joyful, 5th Sorrowful, 3rd Glorious and 2nd Luminous); the opening
    // and the closing have no mystery name.
    function mysteryNames(logger as Logger, language as Number, expected as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var actual = [Rosary.mysteryName(Rosary.JOYFUL, 1), Rosary.mysteryName(Rosary.SORROWFUL, 5),
            Rosary.mysteryName(Rosary.GLORIOUS, 3), Rosary.mysteryName(Rosary.LUMINOUS, 2)] as Array<String>;
        var opening = Rosary.mysteryName(Rosary.JOYFUL, 0);
        var closing = Rosary.mysteryName(Rosary.JOYFUL, 6);
        logger.debug(actual + " | '" + opening + "' | '" + closing + "'");
        return sameTexts(actual, expected) && opening.equals("") && closing.equals("");
    }

    // The last mystery of the Joyful, Glorious and Luminous sets, and the first Sorrowful one.
    function lastMysteries(logger as Logger, language as Number, expected as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var actual = [Rosary.mysteryName(Rosary.JOYFUL, 5), Rosary.mysteryName(Rosary.SORROWFUL, 1),
            Rosary.mysteryName(Rosary.GLORIOUS, 5), Rosary.mysteryName(Rosary.LUMINOUS, 5)] as Array<String>;
        logger.debug(actual.toString());
        return sameTexts(actual, expected);
    }

    // The line under the title: the day's set at the opening (step 0) and the Salve (71), the mystery
    // during a decade (step 20, the 2nd Sorrowful).
    function subtitles(logger as Logger, language as Number, expected as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var actual = [Rosary.subtitle(0, Rosary.SORROWFUL), Rosary.subtitle(20, Rosary.SORROWFUL),
            Rosary.subtitle(71, Rosary.LUMINOUS)] as Array<String>;
        logger.debug(actual.toString());
        return sameTexts(actual, expected);
    }

    // The current bead's label at steps 0, 1, 3, 5, 13, 16, 17, 18 and 71, comma-joined.
    function prayerLabels(logger as Logger, language as Number, expected as String) as Boolean {
        TestLanguage.use(logger, language);
        var steps = [0, 1, 3, 5, 13, 16, 17, 18, 71];
        var actual = "";
        for (var i = 0; i < steps.size(); i++) {
            actual += (i > 0 ? "," : "") + Rosary.prayerLabel(steps[i]);
        }
        logger.debug("labels=" + actual);
        return actual.equals(expected);
    }

    // The font of each label prayerLabels pins, as the main screen draws it (MainLayout.prayerFont),
    // comma-joined: the large font unless the label is too wide for it.
    function prayerFonts(logger as Logger, language as Number, expected as String) as Boolean {
        TestLanguage.use(logger, language);
        var dc = ScreenArea.measuringDc();
        var steps = [0, 1, 3, 5, 13, 16, 17, 18, 71];
        var actual = "";
        for (var i = 0; i < steps.size(); i++) {
            actual += (i > 0 ? "," : "") + ScreenArea.fontName(MainLayout.prayerFont(dc, Rosary.prayerLabel(steps[i])));
        }
        logger.debug("fonts=" + actual);
        return actual.equals(expected);
    }

    // The main screen's title at the opening, each decade (with its ordinal and the set's name) and the Salve.
    function decadeTitles(logger as Logger, language as Number, expected as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var actual = [Rosary.decadeTitle(3, Rosary.JOYFUL), Rosary.decadeTitle(6, Rosary.JOYFUL),
            Rosary.decadeTitle(19, Rosary.SORROWFUL), Rosary.decadeTitle(32, Rosary.GLORIOUS),
            Rosary.decadeTitle(45, Rosary.LUMINOUS), Rosary.decadeTitle(70, Rosary.LUMINOUS),
            Rosary.decadeTitle(71, Rosary.LUMINOUS)] as Array<String>;
        logger.debug(actual.toString());
        return sameTexts(actual, expected);
    }

    // The glance's set name and its progress at each kind of position, comma-joined. A day not started (-1)
    // differs from one started and moved back to the Credo (0); the Salve reads as itself until it is prayed,
    // and only the finished rosary (DONE) reads as completed.
    function glance(logger as Logger, language as Number, title as String, summaries as String) as Boolean {
        TestLanguage.use(logger, language);
        var actualTitle = Rosary.glanceTitle(Rosary.JOYFUL);
        var positions = [Rosary.NOT_STARTED, 0, 3, 6, 20, 70, 71, Rosary.DONE];
        var actual = "";
        for (var i = 0; i < positions.size(); i++) {
            actual += (i > 0 ? "," : "") + Rosary.glanceSummary(positions[i]);
        }
        logger.debug("title=" + actualTitle + " summaries=" + actual);
        return actualTitle.equals(title) && Rosary.NOT_STARTED == -1 && actual.equals(summaries);
    }

    // The question "Reiniciar" (the menu's second item) asks before starting the day over.
    function resetPrompt(logger as Logger, language as Number, expected as String) as Boolean {
        TestLanguage.use(logger, language);
        var prompt = I18n.text(I18n.ResetPrompt);
        logger.debug("prompt=" + prompt);
        return prompt.equals(expected);
    }

    // "Leer misterio" reads the current mystery: the first, the one coming next, during the opening;
    // mystery n during decade n; the fifth on the Salve and once the rosary is done. Its title is the main
    // screen's: expected holds the 1st Joyful, the 3rd Sorrowful and the 5th Luminous mystery's titles.
    function readingTitles(logger as Logger, language as Number, expected as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var positions = [0, 5, 6, 18, 19, 44, 57, 58, 70, 71, Rosary.DONE];
        var decades = [];
        for (var i = 0; i < positions.size(); i++) {
            decades.add(Rosary.readingDecade(positions[i]));
        }
        var titles = [Rosary.mysteryTitle(Rosary.JOYFUL, 1), Rosary.mysteryTitle(Rosary.SORROWFUL, 3),
            Rosary.mysteryTitle(Rosary.LUMINOUS, 5)] as Array<String>;
        logger.debug("decades=" + decades + " titles=" + titles);
        return decades.toString().equals([1, 1, 1, 1, 2, 3, 4, 5, 5, 5, 5].toString())
            && sameTexts(titles, expected) && titles[0].equals(Rosary.decadeTitle(6, Rosary.JOYFUL));
    }

    // Hold UP opens the app's own menu: the title of the mystery "Leer misterio" reads (the 1st during the
    // opening, the n-th during decade n, the 5th on the Salve), over "Leer misterio", selected first, and
    // "Reiniciar". expected holds the titles at the opening (Joyful), at step 20 (Glorious) and on the Salve
    // (Sorrowful); firstLines is how the first one wraps beside the lens.
    function menuTitles(logger as Logger, language as Number, expected as Array<String>, firstLines as Array<String>) as Boolean {
        TestLanguage.use(logger, language);
        var opening = new RosaryMenuView(Rosary.JOYFUL, Rosary.readingDecade(0));
        var second = new RosaryMenuView(Rosary.GLORIOUS, Rosary.readingDecade(20));
        var salve = new RosaryMenuView(Rosary.SORROWFUL, Rosary.readingDecade(Rosary.LAST_STEP));
        var labels = opening.labels();
        var titles = [opening.title(), second.title(), salve.title()] as Array<String>;
        logger.debug("labels=" + labels + " selected=" + opening.selected + " id=" + opening.selectedId()
            + " titles=" + titles + " first lines=" + opening.titleLines());
        return labels.size() == MenuLayout.ITEM_COUNT && labels[0].equals(I18n.text(I18n.MenuRead))
            && labels[1].equals(I18n.text(I18n.MenuReset))
            && opening.selected == 0 && opening.selectedId() == :read
            && sameTexts(titles, expected) && sameTexts(opening.titleLines(), firstLines);
    }

    // Each of the 20 mysteries has its own quote, loaded from the resources with its reference, in
    // Rosary.mysteryIndex order. The first and the last quotes are pinned word for word.
    function bibleQuotes(logger as Logger, language as Number, references as Array<String>, first as String, last as String) as Boolean {
        TestLanguage.use(logger, language);
        var refs = "";
        var ok = references.size() == Rosary.DECADES * 4;
        for (var i = 0; ok && i < references.size(); i++) {
            var reference = Quotes.reference(i);
            refs += (i > 0 ? "; " : "") + reference;
            ok = reference.equals(references[i]) && Quotes.text(i).length() > 0;
        }
        var annunciation = Quotes.text(Rosary.mysteryIndex(Rosary.JOYFUL, 1));
        var eucharist = Quotes.text(Rosary.mysteryIndex(Rosary.LUMINOUS, 5));
        logger.debug("refs=" + refs + " | " + annunciation + " | " + eucharist);
        return ok && annunciation.equals(first) && eucharist.equals(last);
    }

    // Same texts in the same order (the callers log the actual ones).
    function sameTexts(actual as Array<String>, expected as Array<String>) as Boolean {
        var same = actual.size() == expected.size();
        for (var i = 0; same && i < actual.size(); i++) {
            same = actual[i].equals(expected[i]);
        }
        return same;
    }
}
