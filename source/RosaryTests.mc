import Toybox.Lang;
import Toybox.Test;

// Run No Evil unit tests for the Rosary module. They are excluded from debug and release
// executables; run them with a unit-test build in the simulator (monkeydo <prg> instinct2 -t).

(:test)
function sequenceHasSeventyTwoStepsEndingInSalve(logger as Logger) as Boolean {
    var last = Rosary.prayerAt(Rosary.LAST_STEP);
    logger.debug("count=" + Rosary.STEP_COUNT + " last=" + Rosary.LAST_STEP + " prayer=" + last);
    return Rosary.STEP_COUNT == 72 && Rosary.LAST_STEP == 71 && last == Rosary.SALVE;
}

(:test)
function openingIsCreedOurFatherThreeHailMarysAndGlory(logger as Logger) as Boolean {
    var expected = [Rosary.CREED, Rosary.OUR_FATHER, Rosary.HAIL_MARY, Rosary.HAIL_MARY, Rosary.HAIL_MARY, Rosary.GLORY_BE];
    var actual = [];
    for (var i = 0; i < expected.size(); i++) {
        actual.add(Rosary.prayerAt(i));
    }
    logger.debug("opening=" + actual);
    return actual.toString().equals(expected.toString());
}

(:test)
function everyDecadeIsOurFatherTenHailMarysGloryAndFatima(logger as Logger) as Boolean {
    var ok = true;
    for (var decade = 0; decade < 5; decade++) {
        var first = 6 + decade * 13;
        var actual = new [13];
        for (var i = 0; i < 13; i++) {
            actual[i] = Rosary.prayerAt(first + i);
        }
        logger.debug("decade " + (decade + 1) + "=" + actual);
        ok = ok && actual[0] == Rosary.OUR_FATHER && actual[11] == Rosary.GLORY_BE && actual[12] == Rosary.FATIMA;
        for (var j = 1; j <= 10; j++) {
            ok = ok && actual[j] == Rosary.HAIL_MARY;
        }
    }
    return ok;
}

(:test)
function sequenceCountsEachPrayer(logger as Logger) as Boolean {
    var counts = [0, 0, 0, 0, 0, 0];
    for (var step = 0; step < Rosary.STEP_COUNT; step++) {
        var prayer = Rosary.prayerAt(step) as Number;
        counts[prayer] += 1;
    }
    logger.debug("credo,padre,ave,gloria,fatima,salve=" + counts);
    return counts[Rosary.CREED] == 1 && counts[Rosary.OUR_FATHER] == 6 && counts[Rosary.HAIL_MARY] == 53
        && counts[Rosary.GLORY_BE] == 6 && counts[Rosary.FATIMA] == 5 && counts[Rosary.SALVE] == 1;
}

(:test)
function decadeAtSplitsOpeningMysteriesAndClosing(logger as Logger) as Boolean {
    var steps = [0, 5, 6, 18, 19, 57, 58, 70, 71];
    var actual = [];
    for (var i = 0; i < steps.size(); i++) {
        actual.add(Rosary.decadeAt(steps[i]));
    }
    logger.debug("decades=" + actual);
    return actual.toString().equals([0, 0, 1, 1, 2, 4, 5, 5, 6].toString());
}

(:test)
function hailMaryIndexCountsWithinTheGroup(logger as Logger) as Boolean {
    var steps = [0, 1, 2, 4, 5, 6, 7, 16, 17, 18, 59, 68, 71];
    var actual = [];
    for (var i = 0; i < steps.size(); i++) {
        actual.add(Rosary.hailMaryIndex(steps[i]));
    }
    logger.debug("indexes=" + actual);
    return actual.toString().equals([0, 0, 1, 3, 0, 0, 1, 10, 0, 0, 1, 10, 0].toString());
}

(:test)
function ringFillCountsHailMarysReachedInTheGroup(logger as Logger) as Boolean {
    var steps = [0, 1, 3, 5, 6, 12, 16, 17, 18, 19, 71];
    var actual = [];
    for (var i = 0; i < steps.size(); i++) {
        actual.add(Rosary.ringFill(steps[i]));
    }
    logger.debug("fill=" + actual);
    return actual.toString().equals([0, 0, 2, 3, 0, 6, 10, 10, 10, 0, 0].toString());
}

(:test)
function mysterySetFollowsTheWeekday(logger as Logger) as Boolean {
    // Gregorian day_of_week: 1 = Sunday .. 7 = Saturday.
    var actual = [];
    for (var day = 1; day <= 7; day++) {
        actual.add(Rosary.mysterySetForWeekday(day));
    }
    logger.debug("sets=" + actual);
    var expected = [Rosary.GLORIOUS, Rosary.JOYFUL, Rosary.SORROWFUL, Rosary.GLORIOUS, Rosary.LUMINOUS, Rosary.SORROWFUL, Rosary.JOYFUL];
    return actual.toString().equals(expected.toString());
}

(:test)
function setNamesArePluralAndSingular(logger as Logger) as Boolean {
    var plural = Rosary.setNamePlural(Rosary.JOYFUL) + "," + Rosary.setNamePlural(Rosary.SORROWFUL) + ","
        + Rosary.setNamePlural(Rosary.GLORIOUS) + "," + Rosary.setNamePlural(Rosary.LUMINOUS);
    var singular = Rosary.setNameSingular(Rosary.JOYFUL) + "," + Rosary.setNameSingular(Rosary.SORROWFUL) + ","
        + Rosary.setNameSingular(Rosary.GLORIOUS) + "," + Rosary.setNameSingular(Rosary.LUMINOUS);
    logger.debug("plural=" + plural + " singular=" + singular);
    return plural.equals("Gozosos,Dolorosos,Gloriosos,Luminosos") && singular.equals("Gozoso,Doloroso,Glorioso,Luminoso");
}

(:test)
function mysteryNamesCoverEverySet(logger as Logger) as Boolean {
    var joyful = Rosary.mysteryName(Rosary.JOYFUL, 1);
    var sorrowful = Rosary.mysteryName(Rosary.SORROWFUL, 5);
    var glorious = Rosary.mysteryName(Rosary.GLORIOUS, 3);
    var luminous = Rosary.mysteryName(Rosary.LUMINOUS, 2);
    var opening = Rosary.mysteryName(Rosary.JOYFUL, 0);
    var closing = Rosary.mysteryName(Rosary.JOYFUL, 6);
    logger.debug(joyful + " | " + sorrowful + " | " + glorious + " | " + luminous + " | '" + opening + "' | '" + closing + "'");
    return joyful.equals("La Anunciación del Ángel a María")
        && sorrowful.equals("La Crucifixión y Muerte de Jesús")
        && glorious.equals("La Venida del Espíritu Santo")
        && luminous.equals("Las Bodas de Caná")
        && opening.equals("") && closing.equals("");
}

(:test)
function lastMysteryOfEachSetIsCorrect(logger as Logger) as Boolean {
    var joyful = Rosary.mysteryName(Rosary.JOYFUL, 5);
    var sorrowful = Rosary.mysteryName(Rosary.SORROWFUL, 1);
    var glorious = Rosary.mysteryName(Rosary.GLORIOUS, 5);
    var luminous = Rosary.mysteryName(Rosary.LUMINOUS, 5);
    logger.debug(joyful + " | " + sorrowful + " | " + glorious + " | " + luminous);
    return joyful.equals("El Niño Jesús perdido y hallado en el Templo")
        && sorrowful.equals("La Oración de Jesús en el Huerto")
        && glorious.equals("La Coronación de María como Reina")
        && luminous.equals("La Institución de la Eucaristía");
}

(:test)
function subtitleShowsTheMysteryOrTheDaySet(logger as Logger) as Boolean {
    var opening = Rosary.subtitle(0, Rosary.SORROWFUL);
    var second = Rosary.subtitle(20, Rosary.SORROWFUL);
    var closing = Rosary.subtitle(71, Rosary.LUMINOUS);
    logger.debug(opening + " | " + second + " | " + closing);
    return opening.equals("Misterios Dolorosos")
        && second.equals("La Flagelación del Señor")
        && closing.equals("Misterios Luminosos");
}

(:test)
function prayerLabelNamesTheCurrentBead(logger as Logger) as Boolean {
    var steps = [0, 1, 3, 5, 13, 16, 17, 18, 71];
    var actual = "";
    for (var i = 0; i < steps.size(); i++) {
        actual += (i > 0 ? "," : "") + Rosary.prayerLabel(steps[i]);
    }
    logger.debug("labels=" + actual);
    return actual.equals("Credo,Padre Nuestro,Avemaría 2,Gloria,Avemaría 7,Avemaría 10,Gloria,Oh Jesús mío,Salve");
}

(:test)
function decadeTitleUsesSpanishOrdinals(logger as Logger) as Boolean {
    var opening = Rosary.decadeTitle(3, Rosary.JOYFUL);
    var first = Rosary.decadeTitle(6, Rosary.JOYFUL);
    var second = Rosary.decadeTitle(19, Rosary.SORROWFUL);
    var third = Rosary.decadeTitle(32, Rosary.GLORIOUS);
    var fourth = Rosary.decadeTitle(45, Rosary.LUMINOUS);
    var fifth = Rosary.decadeTitle(70, Rosary.LUMINOUS);
    var closing = Rosary.decadeTitle(71, Rosary.LUMINOUS);
    logger.debug(opening + " | " + first + " | " + second + " | " + third + " | " + fourth + " | " + fifth + " | " + closing);
    return opening.equals("Inicio")
        && first.equals("1er Misterio Gozoso")
        && second.equals("2do Misterio Doloroso")
        && third.equals("3er Misterio Glorioso")
        && fourth.equals("4to Misterio Luminoso")
        && fifth.equals("5to Misterio Luminoso")
        && closing.equals("Final");
}

(:test)
function nextAndPrevClampToTheSequence(logger as Logger) as Boolean {
    var actual = [Rosary.next(0), Rosary.next(70), Rosary.next(71), Rosary.prev(0), Rosary.prev(1), Rosary.prev(71),
        Rosary.clampStep(-3), Rosary.clampStep(99), Rosary.clampStep(40)];
    logger.debug("moves=" + actual);
    return actual.toString().equals([1, 71, 71, 0, 0, 70, 0, 71, 40].toString());
}

(:test)
function vibrationMarksGloriaAfterTenHailMarysAndTheEnd(logger as Logger) as Boolean {
    var none = Rosary.vibeForMove(71, 71);
    var still = Rosary.vibeForMove(0, 0);
    var bead = Rosary.vibeForMove(0, 1);
    var openingGloria = Rosary.vibeForMove(4, 5);
    var firstGloria = Rosary.vibeForMove(16, 17);
    var lastGloria = Rosary.vibeForMove(68, 69);
    var back = Rosary.vibeForMove(17, 16);
    var ninth = Rosary.vibeForMove(15, 16);
    var end = Rosary.vibeForMove(70, 71);
    var leaveEnd = Rosary.vibeForMove(71, 70);
    logger.debug("none=" + none + " still=" + still + " bead=" + bead + " openingGloria=" + openingGloria
        + " firstGloria=" + firstGloria + " lastGloria=" + lastGloria + " back=" + back + " ninth=" + ninth
        + " end=" + end + " leaveEnd=" + leaveEnd);
    return none == Rosary.VIBE_NONE && still == Rosary.VIBE_NONE && bead == Rosary.VIBE_SHORT
        && openingGloria == Rosary.VIBE_SHORT && firstGloria == Rosary.VIBE_GLORIA && lastGloria == Rosary.VIBE_GLORIA
        && back == Rosary.VIBE_SHORT && ninth == Rosary.VIBE_SHORT && end == Rosary.VIBE_END && leaveEnd == Rosary.VIBE_SHORT;
}

(:test)
function glanceShowsTheDaySetAndProgress(logger as Logger) as Boolean {
    var title = Rosary.glanceTitle(Rosary.JOYFUL);
    var steps = [0, 3, 6, 20, 70, 71];
    var actual = "";
    for (var i = 0; i < steps.size(); i++) {
        actual += (i > 0 ? "," : "") + Rosary.glanceSummary(steps[i]);
    }
    logger.debug("title=" + title + " summaries=" + actual);
    return title.equals("Rosario · Gozosos")
        && actual.equals("Sin empezar,Inicio,Misterio 1/5,Misterio 2/5,Misterio 5/5,Completado");
}

(:test)
function restoreStepKeepsOnlyTodaysProgress(logger as Logger) as Boolean {
    var today = Rosary.dateKey(2026, 10, 12);
    var sameDay = Rosary.restoreStep(30, today, today);
    var otherDay = Rosary.restoreStep(30, 20261011, today);
    var missing = Rosary.restoreStep(null, null, today);
    var outOfRange = Rosary.restoreStep(99, today, today);
    var wrongType = Rosary.restoreStep("30", today, today);
    logger.debug("today=" + today + " same=" + sameDay + " other=" + otherDay + " missing=" + missing
        + " range=" + outOfRange + " type=" + wrongType);
    return today == 20261012 && sameDay == 30 && otherDay == 0 && missing == 0 && outOfRange == 71 && wrongType == 0;
}

(:test)
function ringSegmentsStartAtNoonClockwise(logger as Logger) as Boolean {
    var first = [Rosary.ringSegmentStart(0), Rosary.ringSegmentEnd(0)];
    var wrap = [Rosary.ringSegmentStart(3), Rosary.ringSegmentEnd(3)];
    var last = [Rosary.ringSegmentStart(9), Rosary.ringSegmentEnd(9)];
    logger.debug("0=" + first + " 3=" + wrap + " 9=" + last);
    return first[0] == 87 && first[1] == 57
        && wrap[0] == 339 && wrap[1] == 309
        && last[0] == 123 && last[1] == 93;
}
