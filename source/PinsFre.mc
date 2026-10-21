import Toybox.Lang;
import Toybox.Test;

// The French texts the tests pin, word for word. Every test here ends in Fre and reads in French; the other
// languages' pins define the same tests, and TextPins.mc holds the checks they share. " " is a no-break
// space and " " a narrow one, as the French texts use them.

(:test)
function setNamesArePluralAndSingularFre(logger as Logger) as Boolean {
    return TextPins.setNames(logger, I18n.FRE, "Joyeux,Douloureux,Glorieux,Lumineux", "joyeux,douloureux,glorieux,lumineux");
}

(:test)
function mysteryNamesCoverEverySetFre(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, I18n.FRE, ["L’Annonciation", "La Crucifixion et la mort de Jésus", "La Pentecôte",
        "Les Noces de Cana"]);
}

(:test)
function lastMysteryOfEachSetIsCorrectFre(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, I18n.FRE, ["Le Recouvrement de Jésus au Temple", "L’Agonie au jardin",
        "Le Couronnement de Marie", "L’Institution de l’Eucharistie"]);
}

(:test)
function subtitleShowsTheMysteryOrTheDaySetFre(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, I18n.FRE, ["Mystères douloureux", "La Flagellation", "Mystères lumineux"]);
}

// A Je vous salue Marie has no number on the main screen: with it the label fits no font (the subscreen
// shows the number).
(:test)
function prayerLabelNamesTheCurrentBeadFre(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger, I18n.FRE, "Je crois en Dieu,Notre Père,Je vous salue Marie,Gloire au Père,"
        + "Je vous salue Marie,Je vous salue Marie,Gloire au Père,Ô mon Jésus,Salve Regina");
}

// "Je crois en Dieu" is too wide for the large font and takes the medium one; "Je vous salue Marie" is too
// wide for the medium one too and takes the small one.
(:test)
function prayerLabelStepsDownOnlyForLongNamesFre(logger as Logger) as Boolean {
    return TextPins.prayerFonts(logger, I18n.FRE, "medium,large,small,large,small,small,large,large,large");
}

(:test)
function decadeTitleUsesTheOrdinalsFre(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, I18n.FRE, ["Début", "1er mystère joyeux", "2e mystère douloureux", "3e mystère glorieux",
        "4e mystère lumineux", "5e mystère lumineux", "Fin"]);
}

(:test)
function glanceShowsTheDaySetAndProgressFre(logger as Logger) as Boolean {
    return TextPins.glance(logger, I18n.FRE, "Joyeux",
        "Non commencé,En cours,En cours,Mystère 1/5,Mystère 2/5,Mystère 5/5,Salve Regina,Terminé");
}

(:test)
function resetPromptIsTranslatedFre(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, I18n.FRE, "Recommencer le chapelet ?");
}

(:test)
function readingFollowsTheCurrentMysteryFre(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, I18n.FRE, ["1er mystère joyeux", "3e mystère douloureux", "5e mystère lumineux"]);
}

(:test)
function menuOffersReadingTheMysteryAndRestartingFre(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, I18n.FRE, ["1er mystère joyeux", "2e mystère glorieux", "5e mystère douloureux"],
        ["1er", "mystère", "joyeux"]);
}

// "douloureux" is wider than the title's width, so a Sorrowful title wraps at spaces, the word on the last
// line, instead of being cut to "doulour…".
(:test)
function sorrowfulTitleKeepsItsLongWordWholeFre(logger as Logger) as Boolean {
    TestLanguage.use(logger, I18n.FRE);
    var lines = MainLayout.wrapTitle(Rosary.mysteryTitle(Rosary.SORROWFUL, 2));
    logger.debug("lines=" + lines);
    return TextPins.sameTexts(lines, ["2e", "mystère", "douloureux"]);
}

// The main screen wraps a mystery's name at spaces, never after an elided article: "d’épines" and
// "l’Eucharistie" stay whole (fitTextToArea broke them after the apostrophe).
(:test)
function mysteryNameKeepsItsElisionsWholeFre(logger as Logger) as Boolean {
    TestLanguage.use(logger, I18n.FRE);
    var crowning = MainLayout.wrapMystery(Rosary.mysteryName(Rosary.SORROWFUL, 3));
    var eucharist = MainLayout.wrapMystery(Rosary.mysteryName(Rosary.LUMINOUS, 5));
    logger.debug("crowning=" + crowning + " eucharist=" + eucharist);
    return TextPins.sameTexts(crowning, ["Le Couronnement", "d’épines"])
        && TextPins.sameTexts(eucharist, ["L’Institution de", "l’Eucharistie"]);
}

(:test)
function everyMysteryHasItsBibleQuoteFre(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, I18n.FRE, [
            "Lc 1, 28", "Lc 1, 42", "Lc 2, 7", "Lc 2, 30-31", "Lc 2, 49",
            "Lc 22, 42", "Jn 19, 1", "Jn 19, 2", "Jn 19, 17", "Lc 23, 46",
            "Lc 24, 5-6", "Ac 1, 9", "Ac 2, 4", "Lc 1, 48", "Ap 12, 1",
            "Mt 3, 17", "Jn 2, 5", "Mc 1, 15", "Mc 9, 6", "Lc 22, 19"],
        "L’ange étant entré où elle était, lui dit : « Je vous salue, pleine de grâce ; le Seigneur est avec vous, "
            + "vous êtes bénie entre les femmes. »",
        "« Ceci est mon corps, qui est donné pour vous : faites ceci en mémoire de moi. »");
}
