import Toybox.Lang;
import Toybox.Test;

// The Spanish texts the tests pin, word for word. Every test here ends in Spa and reads in Spanish; the other
// languages' pins define the same tests, and TextPins.mc holds the checks they share.

(:test)
function setNamesArePluralAndSingularSpa(logger as Logger) as Boolean {
    return TextPins.setNames(logger, I18n.SPA, "Gozosos,Dolorosos,Gloriosos,Luminosos", "Gozoso,Doloroso,Glorioso,Luminoso");
}

(:test)
function mysteryNamesCoverEverySetSpa(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, I18n.SPA, ["La Anunciación del Ángel a María", "La Crucifixión y Muerte de Jesús",
        "La Venida del Espíritu Santo", "Las Bodas de Caná"]);
}

(:test)
function lastMysteryOfEachSetIsCorrectSpa(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, I18n.SPA, ["El Niño Jesús perdido y hallado en el Templo", "La Oración de Jesús en el Huerto",
        "La Coronación de María como Reina", "La Institución de la Eucaristía"]);
}

(:test)
function subtitleShowsTheMysteryOrTheDaySetSpa(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, I18n.SPA, ["Misterios Dolorosos", "La Flagelación del Señor", "Misterios Luminosos"]);
}

(:test)
function prayerLabelNamesTheCurrentBeadSpa(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger, I18n.SPA, "Credo,Padre Nuestro,Avemaría 2,Gloria,Avemaría 7,Avemaría 10,Gloria,Oh Jesús mío,Salve");
}

// Every Spanish label fits the large font, so the main screen draws them as it always has.
(:test)
function prayerLabelStepsDownOnlyForLongNamesSpa(logger as Logger) as Boolean {
    return TextPins.prayerFonts(logger, I18n.SPA, "large,large,large,large,large,large,large,large,large");
}

(:test)
function decadeTitleUsesTheOrdinalsSpa(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, I18n.SPA, ["Inicio", "1er Misterio Gozoso", "2do Misterio Doloroso", "3er Misterio Glorioso",
        "4to Misterio Luminoso", "5to Misterio Luminoso", "Final"]);
}

(:test)
function glanceShowsTheDaySetAndProgressSpa(logger as Logger) as Boolean {
    return TextPins.glance(logger, I18n.SPA, "Gozosos",
        "Sin empezar,En progreso,En progreso,Misterio 1/5,Misterio 2/5,Misterio 5/5,Salve,Completado");
}

(:test)
function resetPromptIsTranslatedSpa(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, I18n.SPA, "¿Reiniciar el rosario?");
}

(:test)
function readingFollowsTheCurrentMysterySpa(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, I18n.SPA, ["1er Misterio Gozoso", "3er Misterio Doloroso", "5to Misterio Luminoso"]);
}

(:test)
function menuOffersReadingTheMysteryAndRestartingSpa(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, I18n.SPA, ["1er Misterio Gozoso", "2do Misterio Glorioso", "5to Misterio Doloroso"],
        ["1er", "Misterio", "Gozoso"]);
}

(:test)
function everyMysteryHasItsBibleQuoteSpa(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, I18n.SPA, [
            "Lc 1, 28", "Lc 1, 42", "Lc 2, 7", "Lc 2, 30-31", "Lc 2, 49",
            "Lc 22, 42", "Jn 19, 1", "Jn 19, 2", "Jn 19, 17", "Lc 23, 46",
            "Lc 24, 5-6", "Hch 1, 9", "Hch 2, 4", "Lc 1, 48", "Ap 12, 1",
            "Mt 3, 17", "Jn 2, 5", "Mc 1, 15", "Mc 9, 7", "Lc 22, 19"],
        "El Angel entró en su casa y la saludó, diciendo: «¡Alégrate!, llena de gracia, el Señor está contigo».",
        "Esto es mi Cuerpo, que se entrega por ustedes. Hagan esto en memoria mía.");
}
