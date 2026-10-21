import Toybox.Lang;
import Toybox.Test;

// The Latin texts the tests pin, word for word. Every test here ends in Lat and reads in Latin; the other
// languages' pins define the same tests, and TextPins.mc holds the checks they share. No watch is set to
// Latin: only the language picker's "Latina" reads it (I18nTests.mc checks that Automatic never does).

(:test)
function setNamesArePluralAndSingularLat(logger as Logger) as Boolean {
    return TextPins.setNames(logger, I18n.LAT, "Gaudiosa,Dolorosa,Gloriosa,Luminosa", "gaudiosum,dolorosum,gloriosum,luminosum");
}

(:test)
function mysteryNamesCoverEverySetLat(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, I18n.LAT, ["Annuntiatio", "Crucifixio et Mors", "Descensus Spiritus Sancti",
        "Autorevelatio apud Canense matrimonium"]);
}

(:test)
function lastMysteryOfEachSetIsCorrectLat(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, I18n.LAT, ["Inventio in Templo", "Agonia in Horto", "Coronatio in Caelo",
        "Eucharistiae institutio"]);
}

(:test)
function subtitleShowsTheMysteryOrTheDaySetLat(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, I18n.LAT, ["Mysteria dolorosa", "Flagellatio", "Mysteria luminosa"]);
}

(:test)
function prayerLabelNamesTheCurrentBeadLat(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger, I18n.LAT,
        "Credo,Pater Noster,Ave Maria 2,Gloria Patri,Ave Maria 7,Ave Maria 10,Gloria Patri,Domine Iesu,Salve Regina");
}

(:test)
function prayerLabelStepsDownOnlyForLongNamesLat(logger as Logger) as Boolean {
    return TextPins.prayerFonts(logger, I18n.LAT, "large,large,large,large,large,large,large,large,large");
}

(:test)
function decadeTitleUsesTheOrdinalsLat(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, I18n.LAT, ["Initium", "Primum mysterium gaudiosum", "Alterum mysterium dolorosum",
        "Tertium mysterium gloriosum", "Quartum mysterium luminosum", "Quintum mysterium luminosum", "Conclusio"]);
}

(:test)
function glanceShowsTheDaySetAndProgressLat(logger as Logger) as Boolean {
    return TextPins.glance(logger, I18n.LAT, "Gaudiosa",
        "Nondum coeptum,In cursu,In cursu,Mysterium 1/5,Mysterium 2/5,Mysterium 5/5,Salve Regina,Peractum");
}

(:test)
function resetPromptIsTranslatedLat(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, I18n.LAT, "Rosarium denuo incipere?");
}

(:test)
function readingFollowsTheCurrentMysteryLat(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, I18n.LAT, ["Primum mysterium gaudiosum", "Tertium mysterium dolorosum",
        "Quintum mysterium luminosum"]);
}

(:test)
function menuOffersReadingTheMysteryAndRestartingLat(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, I18n.LAT, ["Primum mysterium gaudiosum", "Alterum mysterium gloriosum",
        "Quintum mysterium dolorosum"], ["Primum", "mysterium", "gaudiosum"]);
}

// The quotes come from the Vulgata Clementina, which numbers its verses as the Douay-Rheims does (the voice
// from the cloud is Mark 9:6); the references are abbreviated as the Holy See's Latin documents do.
(:test)
function everyMysteryHasItsBibleQuoteLat(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, I18n.LAT, [
            "Lc 1, 28", "Lc 1, 42", "Lc 2, 7", "Lc 2, 30-31", "Lc 2, 49",
            "Lc 22, 42", "Io 19, 1", "Io 19, 2", "Io 19, 17", "Lc 23, 46",
            "Lc 24, 5-6", "Act 1, 9", "Act 2, 4", "Lc 1, 48", "Apc 12, 1",
            "Mt 3, 17", "Io 2, 5", "Mc 1, 15", "Mc 9, 6", "Lc 22, 19"],
        "Et ingressus angelus ad eam dixit: Ave gratia plena: Dominus tecum: benedicta tu in mulieribus.",
        "Hoc est corpus meum, quod pro vobis datur…");
}
