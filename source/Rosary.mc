import Toybox.Lang;

// Pure, device-independent rosary logic shared by the widget, the glance and the unit tests.
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

    // Vibration a move produces: nothing, a short pulse, the multi-pulse that marks the Gloria
    // after the 10 Avemarías of a decade, and the long one at the final Salve.
    enum Vibe {
        VIBE_NONE,
        VIBE_SHORT,
        VIBE_GLORIA,
        VIBE_END
    }

    const STEP_COUNT = 72;
    const LAST_STEP = 71;
    const OPENING_STEPS = 6;
    const DECADE_STEPS = 13;
    const DECADES = 5;
    const CLOSING_DECADE = 6;
    const HAIL_MARYS_PER_DECADE = 10;
    const OPENING_HAIL_MARYS = 3;

    // Indexed by Prayer.
    const PRAYER_NAMES = ["Credo", "Padre Nuestro", "Avemaría", "Gloria", "Oh Jesús mío", "Salve"];

    // Indexed by MysterySet.
    const SET_PLURAL = ["Gozosos", "Dolorosos", "Gloriosos", "Luminosos"];
    const SET_SINGULAR = ["Gozoso", "Doloroso", "Glorioso", "Luminoso"];

    // Indexed by decade - 1.
    const ORDINALS = ["1er", "2do", "3er", "4to", "5to"];

    // Five mysteries per set, in MysterySet order.
    const MYSTERIES = [
        "La Anunciación del Ángel a María",
        "La Visitación de María a su prima Isabel",
        "El Nacimiento de Jesús en Belén",
        "La Presentación de Jesús en el Templo",
        "El Niño Jesús perdido y hallado en el Templo",

        "La Oración de Jesús en el Huerto",
        "La Flagelación del Señor",
        "La Coronación de espinas",
        "Jesús con la Cruz a cuestas",
        "La Crucifixión y Muerte de Jesús",

        "La Resurrección del Señor",
        "La Ascensión del Señor a los Cielos",
        "La Venida del Espíritu Santo",
        "La Asunción de María a los Cielos",
        "La Coronación de María como Reina",

        "El Bautismo de Jesús en el Jordán",
        "Las Bodas de Caná",
        "El Anuncio del Reino de Dios",
        "La Transfiguración del Señor",
        "La Institución de la Eucaristía"
    ];

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

    function next(step as Number) as Number {
        return clampStep(step + 1);
    }

    function prev(step as Number) as Number {
        return clampStep(step - 1);
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

    function setNamePlural(set as MysterySet) as String {
        return SET_PLURAL[set as Number];
    }

    function setNameSingular(set as MysterySet) as String {
        return SET_SINGULAR[set as Number];
    }

    // Name of mystery 1..5 of a set; "" for the opening (0) and the closing (6).
    function mysteryName(set as MysterySet, decade as Number) as String {
        if (decade < 1 || decade > DECADES) {
            return "";
        }
        return MYSTERIES[(set as Number) * DECADES + decade - 1];
    }

    // --- Labels ---

    function prayerName(prayer as Prayer) as String {
        return PRAYER_NAMES[prayer as Number];
    }

    // The bead being prayed, for example "Avemaría 7", "Padre Nuestro" or "Oh Jesús mío".
    function prayerLabel(step as Number) as String {
        var index = hailMaryIndex(step);
        if (index > 0) {
            return PRAYER_NAMES[HAIL_MARY as Number] + " " + index.format("%d");
        }
        return prayerName(prayerAt(step));
    }

    // "1er Misterio Gozoso" .. "5to Misterio Luminoso"; "Inicio" for the opening, "Final" for the Salve.
    function decadeTitle(step as Number, set as MysterySet) as String {
        var decade = decadeAt(step);
        if (decade == 0) {
            return "Inicio";
        }
        if (decade == CLOSING_DECADE) {
            return "Final";
        }
        return ORDINALS[decade - 1] + " Misterio " + setNameSingular(set);
    }

    // Line under the title: the current mystery, or the day's set at the opening and the Salve.
    function subtitle(step as Number, set as MysterySet) as String {
        var decade = decadeAt(step);
        if (decade >= 1 && decade <= DECADES) {
            return mysteryName(set, decade);
        }
        return "Misterios " + setNamePlural(set);
    }

    // --- Feedback ---

    function vibeForMove(from as Number, to as Number) as Vibe {
        from = clampStep(from);
        to = clampStep(to);
        if (from == to) {
            return VIBE_NONE;
        }
        if (to == LAST_STEP) {
            return VIBE_END;
        }
        // Forward from the 10th Avemaría into a decade's Gloria. The opening Gloria stays a short pulse.
        if (to == from + 1 && decadeAt(to) != 0 && prayerAt(to) == GLORY_BE) {
            return VIBE_GLORIA;
        }
        return VIBE_SHORT;
    }

    // --- Glance ---

    function glanceTitle(set as MysterySet) as String {
        return "Rosario · " + setNamePlural(set);
    }

    function glanceSummary(step as Number) as String {
        if (step <= 0) {
            return "Sin empezar";
        }
        if (step >= LAST_STEP) {
            return "Completado";
        }
        var decade = decadeAt(step);
        if (decade == 0) {
            return "Inicio";
        }
        return "Misterio " + decade.format("%d") + "/" + DECADES.format("%d");
    }

    // --- Persistence ---

    // Local date as YYYYMMDD.
    function dateKey(year as Number, month as Number, day as Number) as Number {
        return year * 10000 + month * 100 + day;
    }

    // Today's saved step, or 0 when nothing valid was saved today.
    function restoreStep(storedStep, storedDate, today as Number) as Number {
        if (storedStep instanceof Number && storedDate instanceof Number && storedDate == today) {
            return clampStep(storedStep);
        }
        return 0;
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
