import Toybox.Lang;
import Toybox.Test;

// The English texts the tests pin, word for word. English is the base language: test-eng.jungle (and a plain
// test build of monkey.jungle) builds them over the base strings; every other build leaves out :eng. The
// other languages' pins define the same tests, and TextPins.mc holds the checks they share.

// Also names the suite in its log, so scripts/test-all.sh can tell this suite's output from another's.
(:test :eng)
function setNamesArePluralAndSingular(logger as Logger) as Boolean {
    logger.debug("suite=eng");
    return TextPins.setNames(logger, "Joyful,Sorrowful,Glorious,Luminous", "Joyful,Sorrowful,Glorious,Luminous");
}

(:test :eng)
function mysteryNamesCoverEverySet(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, ["The Annunciation", "The Crucifixion and Death", "The Descent of the Holy Spirit",
        "The Wedding Feast at Cana"]);
}

(:test :eng)
function lastMysteryOfEachSetIsCorrect(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, ["The Finding in the Temple", "The Agony in the Garden", "The Coronation of Mary",
        "The Institution of the Eucharist"]);
}

(:test :eng)
function subtitleShowsTheMysteryOrTheDaySet(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, ["Sorrowful Mysteries", "The Scourging at the Pillar", "Luminous Mysteries"]);
}

(:test :eng)
function prayerLabelNamesTheCurrentBead(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger,
        "Apostles' Creed,Our Father,Hail Mary 2,Glory Be,Hail Mary 7,Hail Mary 10,Glory Be,O My Jesus,Hail Holy Queen");
}

// "Apostles' Creed" and "Hail Holy Queen" are too wide for the large font, so they take the medium one.
(:test :eng)
function prayerLabelStepsDownOnlyForLongNames(logger as Logger) as Boolean {
    return TextPins.prayerFonts(logger, "medium,large,large,large,large,large,large,large,medium");
}

(:test :eng)
function decadeTitleUsesTheOrdinals(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, ["Opening Prayers", "1st Joyful Mystery", "2nd Sorrowful Mystery",
        "3rd Glorious Mystery", "4th Luminous Mystery", "5th Luminous Mystery", "Closing Prayer"]);
}

(:test :eng)
function glanceShowsTheDaySetAndProgress(logger as Logger) as Boolean {
    return TextPins.glance(logger, "Joyful",
        "Not started,In progress,In progress,Mystery 1/5,Mystery 2/5,Mystery 5/5,Hail Holy Queen,Completed");
}

(:test :eng)
function resetPromptIsTranslated(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, "Restart the rosary?");
}

(:test :eng)
function readingFollowsTheCurrentMystery(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, ["1st Joyful Mystery", "3rd Sorrowful Mystery", "5th Luminous Mystery"]);
}

(:test :eng)
function menuOffersReadingTheMysteryAndRestarting(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, ["1st Joyful Mystery", "2nd Glorious Mystery", "5th Sorrowful Mystery"],
        ["1st Joyful", "Mystery"]);
}

(:test :eng)
function everyMysteryHasItsBibleQuote(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, [
            "Lk 1:28", "Lk 1:42", "Lk 2:7", "Lk 2:30-31", "Lk 2:49",
            "Lk 22:42", "Jn 19:1", "Jn 19:2", "Jn 19:17", "Lk 23:46",
            "Lk 24:5-6", "Acts 1:9", "Acts 2:4", "Lk 1:48", "Apoc 12:1",
            "Mt 3:17", "Jn 2:5", "Mk 1:15", "Mk 9:6", "Lk 22:19"],
        "And the angel being come in, said unto her: Hail, full of grace, the Lord is with thee: blessed art thou among women.",
        "This is my body, which is given for you. Do this for a commemoration of me.");
}
