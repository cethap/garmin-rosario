import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;
import Toybox.WatchUi;

// Run No Evil unit tests for the Rosary module. They are excluded from debug and release
// executables; scripts/test-all.sh builds and runs them once per language in the simulator.
// A test about a text itself (a label, a title, a name) pins it in each language: those tests live in
// Pins<Lang>.mc, with their checks in TextPins.mc. A test where a text only shows which item is on screen
// compares it with its string resource (Rosary.loadText), so it holds in every language.

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
// Every Gloria reached forward vibrates as a Gloria, the opening one included.
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
        && openingGloria == Rosary.VIBE_GLORIA && firstGloria == Rosary.VIBE_GLORIA && lastGloria == Rosary.VIBE_GLORIA
        && back == Rosary.VIBE_SHORT && ninth == Rosary.VIBE_SHORT && salve == Rosary.VIBE_SHORT
        && end == Rosary.VIBE_END && leaveSalve == Rosary.VIBE_SHORT && leaveEnd == Rosary.VIBE_SHORT;
}

// The Gloria after the 3 opening Avemarías (step 5) plays the same pattern as a decade's Gloria (user
// report: "el primer gloria que es luego de los tres avemarías no tiene zumbido"). Coming back to it
// from the first decade, and the beads around it, stay a short pulse.
(:test)
function openingGloriaVibratesLikeTheDecadeGlorias(logger as Logger) as Boolean {
    var opening = Rosary.vibeForMove(4, 5);
    var decade = Rosary.vibeForMove(16, 17);
    var back = Rosary.vibeForMove(6, 5);
    var thirdHailMary = Rosary.vibeForMove(3, 4);
    var nextOurFather = Rosary.vibeForMove(5, 6);
    var openingPattern = Rosary.vibePattern(opening).toString();
    var decadePattern = Rosary.vibePattern(decade).toString();
    logger.debug("prayer(5)=" + Rosary.prayerAt(5) + " opening=" + opening + " decade=" + decade + " back=" + back
        + " thirdHailMary=" + thirdHailMary + " nextOurFather=" + nextOurFather + " pattern=" + openingPattern);
    return Rosary.prayerAt(5) == Rosary.GLORY_BE && opening == Rosary.VIBE_GLORIA && openingPattern.equals(decadePattern)
        && back == Rosary.VIBE_SHORT && thirdHailMary == Rosary.VIBE_SHORT && nextOurFather == Rosary.VIBE_SHORT;
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

// The Gloria after the Avemarías is felt without looking: at least 3 pulses, all at full strength,
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

// Holding UP asks "¿Reiniciar el rosario?". NO changes nothing. YES forgets today's progress, so the
// glance reads "Sin empezar" again, and shows the Credo; the next move saves as usual. Uses the real
// Storage and puts back what was there.
(:test)
function resetStartsTodayOverOnlyWhenConfirmed(logger as Logger) as Boolean {
    var app = getApp();
    var today = 20261012;
    var before = Application.Storage.getValue(Rosary.PROGRESS_KEY);
    var ok = false;
    try {
        Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        var view = new RosaryView(30, Rosary.JOYFUL);
        var delegate = new RosaryDelegate(view, today);
        delegate.onSelect();
        var saved = app.loadProgress(today);
        var confirmation = new ResetDelegate(delegate);
        var answeredNo = confirmation.onResponse(WatchUi.CONFIRM_NO);
        var kept = app.loadProgress(today);
        var keptStep = view.step;
        var answeredYes = confirmation.onResponse(WatchUi.CONFIRM_YES);
        var cleared = app.loadProgress(today);
        var clearedStep = view.step;
        var glance = Rosary.glanceSummary(cleared);
        delegate.onNextPage();
        var again = app.loadProgress(today);
        logger.debug("saved=" + saved + " kept=" + kept + " keptStep=" + keptStep + " cleared=" + cleared
            + " clearedStep=" + clearedStep + " glance=" + glance + " again=" + again);
        ok = answeredNo && answeredYes && saved == 31 && kept == 31 && keptStep == 31
            && cleared == Rosary.NOT_STARTED && clearedStep == 0 && glance.equals(Rosary.loadText(Rez.Strings.GlanceNotStarted))
            && again == 1;
    } finally {
        if (before == null) {
            Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        } else {
            Application.Storage.setValue(Rosary.PROGRESS_KEY, before as Application.PropertyValueType);
        }
    }
    return ok;
}

// In the menu DOWN and UP move the selection and stop at either end (no wrap-around), and hold UP does
// nothing; none of them opens anything. BACK closes the menu and nothing else, so the rosary is back on
// the same bead.
(:test)
function menuSelectionStopsAtBothEndsAndBackCloses(logger as Logger) as Boolean {
    var rosaryView = new RosaryView(31, Rosary.JOYFUL);
    var rosary = new MenuFake.RecordingRosary(rosaryView);
    var menu = new RosaryMenuView(rosaryView.mysterySet, Rosary.readingDecade(rosaryView.step));
    var delegate = new RosaryMenuDelegate(menu, rosary);
    var trail = [menu.selected];
    var handled = delegate.onPreviousPage();
    trail.add(menu.selected);
    handled = delegate.onNextPage() && handled;
    trail.add(menu.selected);
    var resetSelected = menu.selectedId() == :reset;
    handled = delegate.onNextPage() && handled;
    trail.add(menu.selected);
    handled = delegate.onMenu() && handled;
    trail.add(menu.selected);
    handled = delegate.onPreviousPage() && handled;
    trail.add(menu.selected);
    var readSelected = menu.selectedId() == :read;
    var quiet = rosary.calls.size() == 0;
    var back = delegate.onBack();
    logger.debug("trail=" + trail + " handled=" + handled + " quiet=" + quiet + " back=" + back
        + " calls=" + rosary.calls + " step=" + rosaryView.step);
    return handled && quiet && back && resetSelected && readSelected
        && trail.toString().equals([0, 0, 1, 1, 1, 0].toString())
        && rosary.calls.toString().equals(["close"].toString()) && rosaryView.step == 31;
}

// START closes the menu, then opens the selected item over the rosary, so BACK from it lands on the
// rosary: "Leer misterio" the reading view (RosaryDelegate.readMystery), "Reiniciar" the confirmation
// "¿Reiniciar el rosario?" (RosaryDelegate.confirmRestart). A recording rosary delegate stands in for
// the real one, which would push those views.
(:test)
function menuSelectOpensTheChosenItemOverTheRosary(logger as Logger) as Boolean {
    var rosaryView = new RosaryView(31, Rosary.JOYFUL);
    var reading = MenuFake.select(rosaryView, 0);
    var restarting = MenuFake.select(rosaryView, 1);
    logger.debug("read: " + reading + " restart: " + restarting + " step=" + rosaryView.step);
    var read = Rosary.loadText(Rez.Strings.MenuRead);
    var reset = Rosary.loadText(Rez.Strings.MenuReset);
    return reading.toString().equals([true, read, ["close", "read"]].toString())
        && restarting.toString().equals([true, reset, ["close", "restart"]].toString())
        && rosaryView.step == 31;
}

(:test)
module MenuFake {

    // A rosary delegate that records what the menu asks of it instead of pushing and popping views.
    class RecordingRosary extends RosaryDelegate {
        var calls as Array<String>;

        function initialize(view as RosaryView) {
            RosaryDelegate.initialize(view, 20261012);
            calls = [] as Array<String>;
        }

        function closeMenu() as Void {
            calls.add("close");
        }

        function readMystery() as Void {
            calls.add("read");
        }

        function confirmRestart() as Void {
            calls.add("restart");
        }
    }

    // Opens the menu over the rosary, presses DOWN downs times and START: [START handled, the label of
    // the selected item, what the rosary was asked to do].
    function select(rosaryView as RosaryView, downs as Number) as Array {
        var rosary = new RecordingRosary(rosaryView);
        var menu = new RosaryMenuView(rosaryView.mysterySet, Rosary.readingDecade(rosaryView.step));
        var delegate = new RosaryMenuDelegate(menu, rosary);
        for (var i = 0; i < downs; i++) {
            delegate.onNextPage();
        }
        var label = menu.labels()[menu.selected];
        var handled = delegate.onSelect();
        return [handled, label, rosary.calls];
    }
}

// In the reading view DOWN and UP scroll a window of lines at a time. UP on the first line and DOWN on
// the last window do nothing; going down shows every line of the text; hold UP does nothing. Every
// mystery reads in 3 screens at most.
(:test)
function readingScrollsBetweenBothEndsAndShowsEveryLine(logger as Logger) as Boolean {
    var dc = ScreenArea.measuringDc();
    var ok = true;
    for (var set = 0; set < 4; set++) {
        for (var decade = 1; decade <= Rosary.DECADES; decade++) {
            var view = new MysteryView(set as Rosary.MysterySet, decade);
            view.onLayout(dc);
            var delegate = new MysteryDelegate(view);
            var count = view.bodyLines().size();
            var shown = new [count];
            ScrollCheck.mark(shown, view.offset);
            var handled = delegate.onPreviousPage();
            var stuckAtTop = view.offset == 0;
            var screens = 1;
            while (screens <= count) {
                var before = view.offset;
                delegate.onNextPage();
                if (view.offset == before) {
                    break;
                }
                screens++;
                ScrollCheck.mark(shown, view.offset);
            }
            var bottom = view.offset;
            delegate.onNextPage();
            var stuckAtBottom = view.offset == bottom && bottom == ReadingLayout.maxOffset(count);
            var menu = delegate.onMenu();
            var menuKept = view.offset == bottom;
            while (view.offset > 0 && screens > 0) {
                delegate.onPreviousPage();
                screens--;
            }
            var backToTop = view.offset == 0;
            var all = ScrollCheck.all(shown);
            var screenCount = ScrollCheck.screens(count);
            logger.debug(Quotes.reference(Rosary.mysteryIndex(set as Rosary.MysterySet, decade)) + ": " + count + " lines, "
                + screenCount + " screens, last offset " + bottom + " all=" + all + " stuckAtTop=" + stuckAtTop
                + " stuckAtBottom=" + stuckAtBottom + " menu=" + menu + " menuKept=" + menuKept + " backToTop=" + backToTop);
            ok = ok && handled && stuckAtTop && stuckAtBottom && menu && menuKept && backToTop && all && screenCount <= 3;
        }
    }
    return ok;
}

// UP goes back through the very pages DOWN showed. With 10 lines DOWN shows the lines from 0, from 4 and,
// as the last window, from 6; UP from there shows the lines from 4 and then from 0 (not from 2). For every
// mystery DOWN stops at each whole window (0, 4, 8, ...) and then at the last window, and UP retraces
// those pages in reverse.
(:test)
function readingScrollsBackThroughTheSamePages(logger as Logger) as Boolean {
    var down = ScrollCheck.pages(0, 10, true);
    var up = ScrollCheck.pages(down[down.size() - 1], 10, false);
    logger.debug("10 lines: down " + down + " up " + up);
    var ok = down.toString().equals([0, 4, 6].toString()) && up.toString().equals([6, 4, 0].toString());
    var dc = ScreenArea.measuringDc();
    for (var set = 0; set < 4; set++) {
        for (var decade = 1; decade <= Rosary.DECADES; decade++) {
            var view = new MysteryView(set as Rosary.MysterySet, decade);
            view.onLayout(dc);
            var delegate = new MysteryDelegate(view);
            var count = view.bodyLines().size();
            var shownDown = [view.offset];
            for (var i = 0; i < count && delegate.onNextPage() && view.offset != shownDown[shownDown.size() - 1]; i++) {
                shownDown.add(view.offset);
            }
            var shownUp = [view.offset];
            for (var i = 0; i < count && delegate.onPreviousPage() && view.offset != shownUp[shownUp.size() - 1]; i++) {
                shownUp.add(view.offset);
            }
            var expected = ScrollCheck.expectedPages(count);
            var same = shownDown.toString().equals(expected.toString())
                && shownUp.toString().equals(ScrollCheck.reversed(expected).toString());
            logger.debug((same ? "same " : "DIFFERENT ") + Quotes.reference(Rosary.mysteryIndex(set as Rosary.MysterySet, decade))
                + ": " + count + " lines, down " + shownDown + " up " + shownUp + " expected " + expected);
            ok = ok && same;
        }
    }
    return ok;
}

// Reading neither saves nor moves the rosary: the saved progress and the bead on the main screen stay
// as they were while the mystery is read and scrolled. Uses the real Storage and puts back what was there.
(:test)
function readingLeavesTheProgressAndTheBeadAlone(logger as Logger) as Boolean {
    var app = getApp();
    var today = 20261012;
    var before = Application.Storage.getValue(Rosary.PROGRESS_KEY);
    var ok = false;
    try {
        Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        var rosary = new RosaryView(30, Rosary.JOYFUL);
        new RosaryDelegate(rosary, today).onSelect();
        var saved = app.loadProgress(today);
        var view = new MysteryView(rosary.mysterySet, Rosary.readingDecade(rosary.step));
        view.onLayout(ScreenArea.measuringDc());
        var reading = new MysteryDelegate(view);
        reading.onNextPage();
        reading.onNextPage();
        reading.onPreviousPage();
        reading.onMenu();
        var after = app.loadProgress(today);
        logger.debug("saved=" + saved + " after=" + after + " step=" + rosary.step + " title=" + view.titleLines());
        ok = saved == 31 && after == 31 && rosary.step == 31
            && view.titleLines().toString().equals(MainLayout.wrapTitle(Rosary.mysteryTitle(Rosary.JOYFUL, 2)).toString())
            && Rosary.mysteryName(Rosary.JOYFUL, 2).find(view.bodyLines()[0]) == 0;
    } finally {
        if (before == null) {
            Application.Storage.deleteValue(Rosary.PROGRESS_KEY);
        } else {
            Application.Storage.setValue(Rosary.PROGRESS_KEY, before as Application.PropertyValueType);
        }
    }
    return ok;
}

(:test)
module ScrollCheck {

    // Marks the lines the window shows from this first line.
    function mark(shown as Array, offset as Number) as Void {
        for (var i = offset; i < offset + ReadingLayout.visibleLines() && i < shown.size(); i++) {
            shown[i] = true;
        }
    }

    function all(shown as Array) as Boolean {
        for (var i = 0; i < shown.size(); i++) {
            if (shown[i] != true) {
                return false;
            }
        }
        return true;
    }

    // Windows needed to read count lines.
    function screens(count as Number) as Number {
        var lines = ReadingLayout.visibleLines();
        return (count + lines - 1) / lines;
    }

    // First lines shown while pressing DOWN (or UP) from the given one over count lines, until it stops.
    function pages(from as Number, count as Number, down as Boolean) as Array<Number> {
        var shown = [from] as Array<Number>;
        for (var i = 0; i < count; i++) {
            var next = down ? ReadingLayout.nextOffset(from, count) : ReadingLayout.prevOffset(from);
            if (next == from) {
                break;
            }
            shown.add(next);
            from = next;
        }
        return shown;
    }

    // The pages of count lines, top to bottom: each whole window below the last one (0, 4, 8, ...), then
    // the last window.
    function expectedPages(count as Number) as Array<Number> {
        var last = ReadingLayout.maxOffset(count);
        var pages = [] as Array<Number>;
        for (var offset = 0; offset < last; offset += ReadingLayout.visibleLines()) {
            pages.add(offset);
        }
        pages.add(last);
        return pages;
    }

    function reversed(values as Array<Number>) as Array<Number> {
        var result = [] as Array<Number>;
        for (var i = values.size() - 1; i >= 0; i--) {
            result.add(values[i]);
        }
        return result;
    }
}
