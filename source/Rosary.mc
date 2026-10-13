import Toybox.Lang;
import Toybox.WatchUi;

// Rosary logic shared by the widget, the glance and the unit tests. It is pure and device-independent,
// except for the texts, which come from the string resources (see "Text" below). The labels only the
// full-screen widget shows continue this module in RosaryLabels.mc, outside the glance.
//
// The Rosary is a sequence of 72 steps (beads), indexed 0..71:
//   0..5    opening: Credo, Padre Nuestro, 3 Avemarías, Gloria
//   6..70   5 decades of 13 steps: Padre Nuestro, 10 Avemarías, Gloria, Oh Jesús mío
//   71      closing: Salve
// Decades are numbered 0 (opening), 1..5 (mysteries) and 6 (closing).
(:glance)
module Rosary {

    enum Prayer {
        CREED,
        OUR_FATHER,
        HAIL_MARY,
        GLORY_BE,
        FATIMA,
        SALVE
    }

    enum MysterySet {
        JOYFUL,
        SORROWFUL,
        GLORIOUS,
        LUMINOUS
    }

    // Vibration a move produces: nothing, a short pulse, the multi-pulse that marks each Gloria (after
    // the 3 opening Avemarías and after the 10 of each decade), and the long one when the Salve is
    // prayed (the end).
    enum Vibe {
        VIBE_NONE,
        VIBE_SHORT,
        VIBE_GLORIA,
        VIBE_END
    }

    const STEP_COUNT = 72;
    const LAST_STEP = 71;
    // Position once the Salve is prayed: the rosary is finished. Saved positions run 0..DONE, and the
    // screen shows DONE as the Salve with every progress box filled.
    const DONE = 72;
    // Position of a day with no saved progress.
    const NOT_STARTED = -1;
    const OPENING_STEPS = 6;
    const DECADE_STEPS = 13;
    const DECADES = 5;
    const CLOSING_DECADE = 6;
    const HAIL_MARYS_PER_DECADE = 10;
    const OPENING_HAIL_MARYS = 3;

    // --- Navigation ---

    function clampStep(step as Number) as Number {
        if (step < 0) {
            return 0;
        }
        if (step > LAST_STEP) {
            return LAST_STEP;
        }
        return step;
    }

    // Positions add DONE past the Salve: next on the Salve prays it, prev from DONE goes back to it.
    function next(position as Number) as Number {
        return clampPosition(position + 1);
    }

    function prev(position as Number) as Number {
        return clampPosition(position - 1);
    }

    function clampPosition(position as Number) as Number {
        if (position < 0) {
            return 0;
        }
        if (position > DONE) {
            return DONE;
        }
        return position;
    }

    // --- Step metadata ---

    function decadeAt(step as Number) as Number {
        step = clampStep(step);
        if (step < OPENING_STEPS) {
            return 0;
        }
        if (step == LAST_STEP) {
            return CLOSING_DECADE;
        }
        return 1 + (step - OPENING_STEPS) / DECADE_STEPS;
    }

    function prayerAt(step as Number) as Prayer {
        step = clampStep(step);
        if (step == LAST_STEP) {
            return SALVE;
        }
        if (step < OPENING_STEPS) {
            if (step == 0) {
                return CREED;
            }
            if (step == 1) {
                return OUR_FATHER;
            }
            if (step == OPENING_STEPS - 1) {
                return GLORY_BE;
            }
            return HAIL_MARY;
        }
        var offset = (step - OPENING_STEPS) % DECADE_STEPS;
        if (offset == 0) {
            return OUR_FATHER;
        }
        if (offset <= HAIL_MARYS_PER_DECADE) {
            return HAIL_MARY;
        }
        if (offset == HAIL_MARYS_PER_DECADE + 1) {
            return GLORY_BE;
        }
        return FATIMA;
    }

    // 1-based number of the Avemaría within its group (3 in the opening, 10 per decade);
    // 0 when the step is not an Avemaría.
    function hailMaryIndex(step as Number) as Number {
        step = clampStep(step);
        if (prayerAt(step) != HAIL_MARY) {
            return 0;
        }
        if (step < OPENING_STEPS) {
            return step - 1;
        }
        return (step - OPENING_STEPS) % DECADE_STEPS;
    }

    // Avemarías reached in the current group, the current one included (0..10), so the ring in
    // the subscreen matches the number in its center. The Gloria and Oh Jesús mío keep the group full.
    function ringFill(step as Number) as Number {
        var index = hailMaryIndex(step);
        if (index > 0) {
            return index;
        }
        var prayer = prayerAt(step);
        if (prayer == GLORY_BE || prayer == FATIMA) {
            return decadeAt(step) == 0 ? OPENING_HAIL_MARYS : HAIL_MARYS_PER_DECADE;
        }
        return 0;
    }

    // Progress boxes filled (0..7): the parts of the rosary before the current one (opening,
    // 5 mysteries, Salve), or all 7 once the Salve is prayed.
    function partsDone(position as Number) as Number {
        if (position >= DONE) {
            return CLOSING_DECADE + 1;
        }
        return decadeAt(position);
    }

    // --- Mysteries ---

    // Gregorian day_of_week (1 = Sunday .. 7 = Saturday) to the mysteries prayed that day:
    // Monday/Saturday Gozosos, Tuesday/Friday Dolorosos, Wednesday/Sunday Gloriosos, Thursday Luminosos.
    function mysterySetForWeekday(dayOfWeek as Number) as MysterySet {
        if (dayOfWeek == 2 || dayOfWeek == 7) {
            return JOYFUL;
        }
        if (dayOfWeek == 3 || dayOfWeek == 6) {
            return SORROWFUL;
        }
        if (dayOfWeek == 5) {
            return LUMINOUS;
        }
        return GLORIOUS;
    }

    // "Gozosos": the set's name as the glance and "Misterios Gozosos" use it. Glance-scoped.
    function setNamePlural(set as MysterySet) as String {
        var ids = [Rez.Strings.SetPluralJoyful, Rez.Strings.SetPluralSorrowful, Rez.Strings.SetPluralGlorious,
            Rez.Strings.SetPluralLuminous] as Array<ResourceId>;
        return loadText(ids[set as Number]);
    }

    // Index 0..19 of mystery 1..5 of a set, in MysterySet order. Resource N = index + 1 holds the mystery's
    // name (MysteryN, resources/strings/mysteries.xml) and its Bible quote (QuoteN and RefN, quotes.xml).
    function mysteryIndex(set as MysterySet, decade as Number) as Number {
        return (set as Number) * DECADES + decade - 1;
    }

    // Mystery (1..5) to read at a position: the current one in a decade; the first, the one coming
    // next, during the opening; the fifth on the Salve and once the rosary is done.
    function readingDecade(position as Number) as Number {
        if (position >= DONE) {
            return DECADES;
        }
        var decade = decadeAt(position);
        if (decade < 1) {
            return 1;
        }
        return decade > DECADES ? DECADES : decade;
    }

    // --- Text ---
    //
    // Every text the app shows is a string resource (resources/strings), so it follows the device's
    // language. A text made of parts is a template whose $1$, $2$ Lang.format fills in, so each language
    // can order its words. Views load a text once and keep it, never on every frame.
    //
    // The glance has only the strings marked scope="glance": the set names in plural, the glance summaries
    // and the Salve. Looking up any other one there crashes with "Symbol Not Found", and the compiler does
    // not warn. So this file, which the glance loads, looks up only those; each lookup table is built inside
    // its function (a module constant would be built in the glance too); and the other labels live in
    // RosaryLabels.mc, outside the glance.

    function loadText(id as ResourceId) as String {
        return WatchUi.loadResource(id) as String;
    }

    // --- Feedback ---

    // Moves are between positions (0..DONE). Arriving at the Salve is an ordinary bead; praying it
    // (into DONE) ends the rosary.
    function vibeForMove(from as Number, to as Number) as Vibe {
        from = clampPosition(from);
        to = clampPosition(to);
        if (from == to) {
            return VIBE_NONE;
        }
        if (to == DONE) {
            return VIBE_END;
        }
        // Forward into any Gloria: after the 3rd opening Avemaría or the 10th of a decade.
        if (to == from + 1 && prayerAt(to) == GLORY_BE) {
            return VIBE_GLORIA;
        }
        return VIBE_SHORT;
    }

    // The vibration as [duty %, ms] steps played in order; duty 0 is a silence. The delegate turns them
    // into Attention.VibeProfiles: Attention.vibrate takes at most 8 per call (the SDK documents no
    // maximum length). Built on each call, so the glance keeps no copy in memory.
    //   bead:   one soft 100ms tap
    //   Gloria: 3 full-strength 350ms pulses, 200ms apart (1.45s), unlike any bead
    //   end:    one unbroken 1s pulse
    function vibePattern(vibe as Vibe) as Array<Array<Number>> {
        if (vibe == VIBE_SHORT) {
            return [[50, 100]] as Array<Array<Number>>;
        }
        if (vibe == VIBE_GLORIA) {
            return [[100, 350], [0, 200], [100, 350], [0, 200], [100, 350]] as Array<Array<Number>>;
        }
        if (vibe == VIBE_END) {
            return [[100, 1000]] as Array<Array<Number>>;
        }
        return [] as Array<Array<Number>>;
    }

    // --- Glance ---

    // The day's mysteries ("Gozosos"). A "Rosario · " prefix does not fit beside the subscreen.
    function glanceTitle(set as MysterySet) as String {
        return setNamePlural(set);
    }

    // Today's progress from the saved position: "Sin empezar" (NOT_STARTED), "En progreso" (opening, also
    // a day moved back to the Credo; "Inicio" read as not started), "Misterio 2/5" (the GlanceMystery
    // template), "Salve" until it is prayed, "Completado" (DONE). Only glance-scoped strings.
    function glanceSummary(position as Number) as String {
        if (position < 0) {
            return loadText(Rez.Strings.GlanceNotStarted);
        }
        if (position >= DONE) {
            return loadText(Rez.Strings.GlanceDone);
        }
        if (position == LAST_STEP) {
            return loadText(Rez.Strings.PrayerSalve);
        }
        var decade = decadeAt(position);
        if (decade == 0) {
            return loadText(Rez.Strings.GlanceInProgress);
        }
        return Lang.format(loadText(Rez.Strings.GlanceMystery), [decade, DECADES]);
    }

    // --- Persistence ---

    // Application.Storage key of the day's progress.
    const PROGRESS_KEY = "progress";

    // Local date as YYYYMMDD.
    function dateKey(year as Number, month as Number, day as Number) as Number {
        return year * 10000 + month * 100 + day;
    }

    // The day's progress as one stored value, [YYYYMMDD, position], so a single write keeps the
    // position and its day together.
    function encodeProgress(today as Number, position as Number) as Array<Number> {
        return [today, position] as Array<Number>;
    }

    // The position saved for today (0..DONE), or NOT_STARTED when the value belongs to another day,
    // is missing or is malformed.
    function decodeProgress(stored, today as Number) as Number {
        if (!(stored instanceof Array) || stored.size() != 2) {
            return NOT_STARTED;
        }
        var date = stored[0];
        var position = stored[1];
        if (date instanceof Number && position instanceof Number && date == today && position >= 0 && position <= DONE) {
            return position;
        }
        return NOT_STARTED;
    }

    // Splits text on "\n" (as Graphics.fitTextToArea returns it), so each line can be drawn with a
    // tighter pitch than the font's own line spacing.
    function splitLines(text as String) as Array<String> {
        var lines = [] as Array<String>;
        var rest = text;
        var cut = rest.find("\n");
        while (cut != null) {
            lines.add(rest.substring(0, cut) as String);
            rest = rest.substring(cut + 1, rest.length()) as String;
            cut = rest.find("\n");
        }
        lines.add(rest);
        return lines;
    }

    // --- Clock ---

    // "HH:MM" honoring the device 12/24h setting; both modes keep the leading zero (08:05).
    function formatClock(hour as Number, minute as Number, is24Hour as Boolean) as String {
        if (!is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        return hour.format("%02d") + ":" + minute.format("%02d");
    }

    // --- Subscreen ring geometry ---

    // Ring segment i (0..9), clockwise from 12 o'clock: 30 degree arcs with 6 degree gaps,
    // in Dc.drawArc degrees (0 = 3 o'clock, counter-clockwise positive).
    function ringSegmentStart(i as Number) as Number {
        return (90 - i * 36 - 3 + 360) % 360;
    }

    function ringSegmentEnd(i as Number) as Number {
        return (ringSegmentStart(i) - 30 + 360) % 360;
    }
}
