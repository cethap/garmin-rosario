import Toybox.Lang;
import Toybox.Test;

// The Spanish texts the tests pin, word for word. test-spa.jungle builds them over the Spanish strings; every
// other build leaves out :spa. The other languages' pins define the same tests, and TextPins.mc holds the
// checks they share.

// Also names the suite in its log, so scripts/test-all.sh can tell this suite's output from another's.
(:test :spa)
function setNamesArePluralAndSingular(logger as Logger) as Boolean {
    logger.debug("suite=spa");
    return TextPins.setNames(logger, "Gozosos,Dolorosos,Gloriosos,Luminosos", "Gozoso,Doloroso,Glorioso,Luminoso");
}

(:test :spa)
function mysteryNamesCoverEverySet(logger as Logger) as Boolean {
    return TextPins.mysteryNames(logger, ["La Anunciación del Ángel a María", "La Crucifixión y Muerte de Jesús",
        "La Venida del Espíritu Santo", "Las Bodas de Caná"]);
}

(:test :spa)
function lastMysteryOfEachSetIsCorrect(logger as Logger) as Boolean {
    return TextPins.lastMysteries(logger, ["El Niño Jesús perdido y hallado en el Templo", "La Oración de Jesús en el Huerto",
        "La Coronación de María como Reina", "La Institución de la Eucaristía"]);
}

(:test :spa)
function subtitleShowsTheMysteryOrTheDaySet(logger as Logger) as Boolean {
    return TextPins.subtitles(logger, ["Misterios Dolorosos", "La Flagelación del Señor", "Misterios Luminosos"]);
}

(:test :spa)
function prayerLabelNamesTheCurrentBead(logger as Logger) as Boolean {
    return TextPins.prayerLabels(logger, "Credo,Padre Nuestro,Avemaría 2,Gloria,Avemaría 7,Avemaría 10,Gloria,Oh Jesús mío,Salve");
}

(:test :spa)
function decadeTitleUsesTheOrdinals(logger as Logger) as Boolean {
    return TextPins.decadeTitles(logger, ["Inicio", "1er Misterio Gozoso", "2do Misterio Doloroso", "3er Misterio Glorioso",
        "4to Misterio Luminoso", "5to Misterio Luminoso", "Final"]);
}

(:test :spa)
function glanceShowsTheDaySetAndProgress(logger as Logger) as Boolean {
    return TextPins.glance(logger, "Gozosos",
        "Sin empezar,En progreso,En progreso,Misterio 1/5,Misterio 2/5,Misterio 5/5,Salve,Completado");
}

(:test :spa)
function resetPromptIsTranslated(logger as Logger) as Boolean {
    return TextPins.resetPrompt(logger, "¿Reiniciar el rosario?");
}

(:test :spa)
function readingFollowsTheCurrentMystery(logger as Logger) as Boolean {
    return TextPins.readingTitles(logger, ["1er Misterio Gozoso", "3er Misterio Doloroso", "5to Misterio Luminoso"]);
}

(:test :spa)
function menuOffersReadingTheMysteryAndRestarting(logger as Logger) as Boolean {
    return TextPins.menuTitles(logger, ["1er Misterio Gozoso", "2do Misterio Glorioso", "5to Misterio Doloroso"],
        ["1er", "Misterio", "Gozoso"]);
}

(:test :spa)
function everyMysteryHasItsBibleQuote(logger as Logger) as Boolean {
    return TextPins.bibleQuotes(logger, [
            "Lc 1, 28", "Lc 1, 42", "Lc 2, 7", "Lc 2, 30-31", "Lc 2, 49",
            "Lc 22, 42", "Jn 19, 1", "Jn 19, 2", "Jn 19, 17", "Lc 23, 46",
            "Lc 24, 5-6", "Hch 1, 9", "Hch 2, 4", "Lc 1, 48", "Ap 12, 1",
            "Mt 3, 17", "Jn 2, 5", "Mc 1, 15", "Mc 9, 7", "Lc 22, 19"],
        "El Angel entró en su casa y la saludó, diciendo: «¡Alégrate!, llena de gracia, el Señor está contigo».",
        "Esto es mi Cuerpo, que se entrega por ustedes. Hagan esto en memoria mía.");
}
