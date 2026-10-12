import Toybox.Application;
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

// Next goes one past the Salve, to the finished rosary (DONE), and stops there; prev from DONE goes
// back to the Salve.
(:test)
function nextAndPrevClampToTheSequence(logger as Logger) as Boolean {
    var actual = [Rosary.next(0), Rosary.next(70), Rosary.next(71), Rosary.next(72), Rosary.prev(0), Rosary.prev(1),
        Rosary.prev(71), Rosary.prev(72), Rosary.clampStep(-3), Rosary.clampStep(99), Rosary.clampStep(40)];
    logger.debug("moves=" + actual + " done=" + Rosary.DONE);
    return Rosary.DONE == 72 && actual.toString().equals([1, 71, 72, 72, 0, 0, 70, 71, 0, 71, 40].toString());
}

// The long vibration marks the end of the Rosary: praying the Salve (71 -> DONE), not arriving at it.
(:test)
function vibrationMarksGloriaAfterTenHailMarysAndTheEnd(logger as Logger) as Boolean {
    var none = Rosary.vibeForMove(72, 72);
    var still = Rosary.vibeForMove(0, 0);
    var bead = Rosary.vibeForMove(0, 1);
    var openingGloria = Rosary.vibeForMove(4, 5);
    var firstGloria = Rosary.vibeForMove(16, 17);
    var lastGloria = Rosary.vibeForMove(68, 69);
    var back = Rosary.vibeForMove(17, 16);
    var ninth = Rosary.vibeForMove(15, 16);
    var salve = Rosary.vibeForMove(70, 71);
    var end = Rosary.vibeForMove(71, 72);
    var leaveSalve = Rosary.vibeForMove(71, 70);
    var leaveEnd = Rosary.vibeForMove(72, 71);
    logger.debug("none=" + none + " still=" + still + " bead=" + bead + " openingGloria=" + openingGloria
        + " firstGloria=" + firstGloria + " lastGloria=" + lastGloria + " back=" + back + " ninth=" + ninth
        + " salve=" + salve + " end=" + end + " leaveSalve=" + leaveSalve + " leaveEnd=" + leaveEnd);
    return none == Rosary.VIBE_NONE && still == Rosary.VIBE_NONE && bead == Rosary.VIBE_SHORT
        && openingGloria == Rosary.VIBE_SHORT && firstGloria == Rosary.VIBE_GLORIA && lastGloria == Rosary.VIBE_GLORIA
        && back == Rosary.VIBE_SHORT && ninth == Rosary.VIBE_SHORT && salve == Rosary.VIBE_SHORT
        && end == Rosary.VIBE_END && leaveSalve == Rosary.VIBE_SHORT && leaveEnd == Rosary.VIBE_SHORT;
}

// Reads the [duty %, ms] steps of Rosary.vibePattern.
(:test)
module VibeCheck {
    // Attention.vibrate plays at most 8 VibeProfiles per call.
    const PROFILE_LIMIT = 8;

    // Steps that vibrate (duty above 0).
    function pulses(pattern as Array<Array<Number>>) as Array<Array<Number>> {
        var found = [] as Array<Array<Number>>;
        for (var i = 0; i < pattern.size(); i++) {
            if (pattern[i][0] > 0) {
                found.add(pattern[i]);
            }
        }
        return found;
    }

    // Lengths of the silences (duty 0), in ms.
    function silences(pattern as Array<Array<Number>>) as Array<Number> {
        var found = [] as Array<Number>;
        for (var i = 0; i < pattern.size(); i++) {
            if (pattern[i][0] == 0) {
                found.add(pattern[i][1]);
            }
        }
        return found;
    }

    function totalMs(pattern as Array<Array<Number>>) as Number {
        var total = 0;
        for (var i = 0; i < pattern.size(); i++) {
            total += pattern[i][1];
        }
        return total;
    }

    // Fits one Attention.vibrate call: up to PROFILE_LIMIT steps, each with a duty of 0..100 and a
    // positive length.
    function playable(pattern as Array<Array<Number>>) as Boolean {
        var ok = pattern.size() <= PROFILE_LIMIT;
        for (var i = 0; i < pattern.size(); i++) {
            ok = ok && pattern[i].size() == 2 && pattern[i][0] >= 0 && pattern[i][0] <= 100 && pattern[i][1] > 0;
        }
        return ok;
    }
}

// The Gloria after the 10 Avemarías is felt without looking: at least 3 pulses, all at full strength,
// in one Attention.vibrate call.
(:test)
function gloriaVibrationIsThreeFullStrengthPulses(logger as Logger) as Boolean {
    var gloria = Rosary.vibePattern(Rosary.VIBE_GLORIA);
    var pulses = VibeCheck.pulses(gloria);
    var strong = true;
    for (var i = 0; i < pulses.size(); i++) {
        strong = strong && pulses[i][0] == 100;
    }
    logger.debug("gloria=" + gloria + " pulses=" + pulses.size());
    return pulses.size() >= 3 && strong && VibeCheck.playable(gloria);
}

(:test)
function gloriaVibrationLastsOverASecond(logger as Logger) as Boolean {
    var total = VibeCheck.totalMs(Rosary.vibePattern(Rosary.VIBE_GLORIA));
    logger.debug("gloria total ms=" + total);
    return total >= 1200;
}

// The bead and the end are one pulse each. Each Gloria pulse is at least 3 times the bead's length and
// shorter than the end's, and the pulses are apart by at least 150ms of silence, so the Gloria reads
// neither as quick beads nor as the one unbroken end pulse.
(:test)
function gloriaVibrationStandsApartFromTheBeadAndTheEnd(logger as Logger) as Boolean {
    var bead = VibeCheck.pulses(Rosary.vibePattern(Rosary.VIBE_SHORT));
    var end = VibeCheck.pulses(Rosary.vibePattern(Rosary.VIBE_END));
    var gloria = Rosary.vibePattern(Rosary.VIBE_GLORIA);
    var pulses = VibeCheck.pulses(gloria);
    var silences = VibeCheck.silences(gloria);
    var ok = bead.size() == 1 && end.size() == 1 && pulses.size() >= 3 && silences.size() == pulses.size() - 1;
    for (var i = 0; ok && i < pulses.size(); i++) {
        ok = pulses[i][1] >= 3 * bead[0][1] && pulses[i][1] < end[0][1] && pulses[i][0] >= bead[0][0];
    }
    for (var i = 0; ok && i < silences.size(); i++) {
        ok = silences[i] >= 150;
    }
    logger.debug("bead=" + bead + " end=" + end + " gloria=" + gloria);
    return ok;
}

// The bead pulse and the end pulse stay as the user knows them; no move plays nothing.
(:test)
function beadAndEndVibrationsKeepTheirPulse(logger as Logger) as Boolean {
    var none = Rosary.vibePattern(Rosary.VIBE_NONE);
    var bead = Rosary.vibePattern(Rosary.VIBE_SHORT);
    var end = Rosary.vibePattern(Rosary.VIBE_END);
    logger.debug("none=" + none + " bead=" + bead + " end=" + end);
    return none.size() == 0 && bead.toString().equals("[[50, 100]]") && end.toString().equals("[[100, 1000]]")
        && VibeCheck.playable(bead) && VibeCheck.playable(end);
}

// A day not started (-1) differs from one started and moved back to the Credo (0); the Salve reads
// "Salve" until it is prayed, and only the finished rosary (DONE) reads "Completado".
(:test)
function glanceShowsTheDaySetAndProgress(logger as Logger) as Boolean {
    var title = Rosary.glanceTitle(Rosary.JOYFUL);
    var positions = [Rosary.NOT_STARTED, 0, 3, 6, 20, 70, 71, Rosary.DONE];
    var actual = "";
    for (var i = 0; i < positions.size(); i++) {
        actual += (i > 0 ? "," : "") + Rosary.glanceSummary(positions[i]);
    }
    logger.debug("title=" + title + " summaries=" + actual);
    return title.equals("Gozosos") && Rosary.NOT_STARTED == -1
        && actual.equals("Sin empezar,Inicio,Inicio,Misterio 1/5,Misterio 2/5,Misterio 5/5,Salve,Completado");
}

// The day's progress is one stored value, [YYYYMMDD, position], that decodes back to the position
// for the same day only. Anything else reads as a day not started.
(:test)
function progressRoundTripsForTodayOnly(logger as Logger) as Boolean {
    var today = Rosary.dateKey(2026, 10, 12);
    var positions = [0, 30, Rosary.LAST_STEP, Rosary.DONE];
    var roundTrips = true;
    for (var i = 0; i < positions.size(); i++) {
        var stored = Rosary.encodeProgress(today, positions[i]);
        roundTrips = roundTrips && stored.size() == 2 && Rosary.decodeProgress(stored, today) == positions[i];
    }
    var newDay = Rosary.decodeProgress(Rosary.encodeProgress(20261011, 30), today);
    var malformed = [null, 30, "30", [today], [today, "30"], ["20261012", 30], [today, 30, 1], [today, -1], [today, 73],
        {"date" => today, "position" => 30}];
    var rejected = "";
    var allRejected = true;
    for (var i = 0; i < malformed.size(); i++) {
        var position = Rosary.decodeProgress(malformed[i], today);
        rejected += position + " ";
        allRejected = allRejected && position == Rosary.NOT_STARTED;
    }
    logger.debug("today=" + today + " roundTrips=" + roundTrips + " newDay=" + newDay + " malformed=" + rejected);
    return today == 20261012 && roundTrips && newDay == Rosary.NOT_STARTED && allRejected;
}

// Progress boxes done: every part before the current one, and all 7 once the Salve is prayed.
(:test)
function progressBoxesFillWhenTheRosaryIsDone(logger as Logger) as Boolean {
    var positions = [0, 5, 6, 70, 71, Rosary.DONE];
    var actual = [];
    for (var i = 0; i < positions.size(); i++) {
        actual.add(Rosary.partsDone(positions[i]));
    }
    logger.debug("partsDone=" + actual);
    return actual.toString().equals([0, 0, 1, 5, 6, 7].toString());
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

(:test)
function formatClockKeepsLeadingZeroIn24h(logger as Logger) as Boolean {
    var midnight = Rosary.formatClock(0, 5, true);
    var morning = Rosary.formatClock(9, 7, true);
    var afternoon = Rosary.formatClock(13, 30, true);
    logger.debug("0:05=" + midnight + " 9:07=" + morning + " 13:30=" + afternoon);
    return midnight.equals("00:05") && morning.equals("09:07") && afternoon.equals("13:30");
}

(:test)
function formatClockWrapsTo12WithLeadingZeroIn12h(logger as Logger) as Boolean {
    var midnight = Rosary.formatClock(0, 0, false);
    var morning = Rosary.formatClock(8, 5, false);
    var noon = Rosary.formatClock(12, 0, false);
    var afternoon = Rosary.formatClock(13, 30, false);
    var night = Rosary.formatClock(23, 59, false);
    logger.debug("0:00=" + midnight + " 8:05=" + morning + " 12:00=" + noon + " 13:30=" + afternoon + " 23:59=" + night);
    return midnight.equals("12:00") && morning.equals("08:05") && noon.equals("12:00")
        && afternoon.equals("01:30") && night.equals("11:59");
}

(:test)
function splitLinesBreaksWrappedText(logger as Logger) as Boolean {
    var two = Rosary.splitLines("1er Misterio\nGozoso");
    var one = Rosary.splitLines("Inicio");
    var three = Rosary.splitLines("a\nb\nc");
    logger.debug("two=" + two + " one=" + one + " three=" + three);
    return two.size() == 2 && two[0].equals("1er Misterio") && two[1].equals("Gozoso")
        && one.size() == 1 && one[0].equals("Inicio")
        && three.size() == 3 && three[2].equals("c");
}

// The buttons save every move at once, as one value. START or DOWN on the Salve prays it and finishes
// the rosary; pressing on past the end changes nothing, and UP goes back to the Salve. Opening the
// screen saves nothing, so a day only counts as started once a bead moves. Uses the real Storage and
// puts back what was there.
(:test)
function delegateSavesEachMoveAndFinishesOnTheSalve(logger as Logger) as Boolean {
    var app = getApp();
    var today = 20261012;
    var before = Application.Storage.getValue(Rosary.PROGRESS_KEY);
    var ok = false;
    try {
        Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        var view = new RosaryView(70, Rosary.JOYFUL);
        var delegate = new RosaryDelegate(view, today);
        var opened = app.loadProgress(today);
        delegate.onSelect();
        var atSalve = app.loadProgress(today);
        delegate.onNextPage();
        var done = app.loadProgress(today);
        delegate.onSelect();
        var stillDone = app.loadProgress(today);
        delegate.onPreviousPage();
        var back = app.loadProgress(today);
        logger.debug("opened=" + opened + " atSalve=" + atSalve + " done=" + done + " stillDone=" + stillDone
            + " back=" + back + " viewStep=" + view.step + " stored=" + Application.Storage.getValue(Rosary.PROGRESS_KEY));
        ok = opened == Rosary.NOT_STARTED && atSalve == Rosary.LAST_STEP && done == Rosary.DONE
            && stillDone == Rosary.DONE && back == Rosary.LAST_STEP && view.step == Rosary.LAST_STEP;
    } finally {
        if (before == null) {
            Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        } else {
            Application.Storage.setValue(Rosary.PROGRESS_KEY, before as Application.PropertyValueType);
        }
    }
    return ok;
}
