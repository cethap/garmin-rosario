import Toybox.Lang;
import Toybox.Test;

// The English texts the tests pin, word for word. Every test here ends in Eng and reads in English; the other
// languages' pins define the same tests, and TextPins.mc holds the checks they share.

(:test)
function setNamesArePluralAndSingularEng(logger as Logger) as Boolean {
    return TextPins.setNames(logger, I18n.ENG, "Joyful,Sorrowful,Glorious,Luminous", "Joyful,Sorrowful,Glorious,Luminous");
}

(:test)
function mysteryNamesCoverEverySetEng(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, I18n.ENG, ["The Annunciation", "The Crucifixion and Death", "The Descent of the Holy Spirit",
        "The Wedding Feast at Cana"]);
}

(:test)
function lastMysteryOfEachSetIsCorrectEng(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, I18n.ENG, ["The Finding in the Temple", "The Agony in the Garden", "The Coronation of Mary",
        "The Institution of the Eucharist"]);
}

(:test)
function subtitleShowsTheMysteryOrTheDaySetEng(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, I18n.ENG, ["Sorrowful Mysteries", "The Scourging at the Pillar", "Luminous Mysteries"]);
}

(:test)
function prayerLabelNamesTheCurrentBeadEng(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger, I18n.ENG,
        "Apostles' Creed,Our Father,Hail Mary 2,Glory Be,Hail Mary 7,Hail Mary 10,Glory Be,O My Jesus,Hail Holy Queen");
}

// "Apostles' Creed" and "Hail Holy Queen" are too wide for the large font, so they take the medium one.
(:test)
function prayerLabelStepsDownOnlyForLongNamesEng(logger as Logger) as Boolean {
    return TextPins.prayerFonts(logger, I18n.ENG, "medium,large,large,large,large,large,large,large,medium");
}

(:test)
function decadeTitleUsesTheOrdinalsEng(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, I18n.ENG, ["Opening Prayers", "1st Joyful Mystery", "2nd Sorrowful Mystery",
        "3rd Glorious Mystery", "4th Luminous Mystery", "5th Luminous Mystery", "Closing Prayer"]);
}

(:test)
function glanceShowsTheDaySetAndProgressEng(logger as Logger) as Boolean {
    return TextPins.glance(logger, I18n.ENG, "Joyful",
        "Not started,In progress,In progress,Mystery 1/5,Mystery 2/5,Mystery 5/5,Hail Holy Queen,Completed");
}

(:test)
function resetPromptIsTranslatedEng(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, I18n.ENG, "Restart the rosary?");
}

(:test)
function readingFollowsTheCurrentMysteryEng(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, I18n.ENG, ["1st Joyful Mystery", "3rd Sorrowful Mystery", "5th Luminous Mystery"]);
}

(:test)
function menuOffersReadingTheMysteryAndRestartingEng(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, I18n.ENG, ["1st Joyful Mystery", "2nd Glorious Mystery", "5th Sorrowful Mystery"],
        ["1st Joyful", "Mystery"]);
}

(:test)
function everyMysteryHasItsBibleQuoteEng(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, I18n.ENG, [
            "Lk 1:28", "Lk 1:42", "Lk 2:7", "Lk 2:30-31", "Lk 2:49",
            "Lk 22:42", "Jn 19:1", "Jn 19:2", "Jn 19:17", "Lk 23:46",
            "Lk 24:5-6", "Acts 1:9", "Acts 2:4", "Lk 1:48", "Apoc 12:1",
            "Mt 3:17", "Jn 2:5", "Mk 1:15", "Mk 9:6", "Lk 22:19"],
        "And the angel being come in, said unto her: Hail, full of grace, the Lord is with thee: blessed art thou among women.",
        "This is my body, which is given for you. Do this for a commemoration of me.");
}
