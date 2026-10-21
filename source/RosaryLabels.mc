import Toybox.Lang;

// The labels of the full-screen widget: its main screen, the menu and the reading view. The Rosary module
// continues here without the glance annotation, so this code stays out of the glance's 32KB, and so do the
// tables it loads, which the glance cannot load. The glance must not call anything here (see "Text" in
// Rosary.mc).
module Rosary {
    // A prayer's name. The glance, which cannot call it, looks PrayerSalve up itself.
    function prayerName(prayer as Prayer) as String {
        var keys = [I18n.PrayerCreed, I18n.PrayerOurFather, I18n.PrayerHailMary,
            I18n.PrayerGloryBe, I18n.PrayerFatima, I18n.PrayerSalve] as Array<Number>;
        return I18n.text(keys[prayer as Number]);
    }

    // The bead being prayed, for example "Avemaría 7" (the PrayerNumber template), "Padre Nuestro" or
    // "Oh Jesús mío".
    function prayerLabel(step as Number) as String {
        var index = hailMaryIndex(step);
        if (index > 0) {
            return Lang.format(I18n.text(I18n.PrayerNumber), [prayerName(HAIL_MARY), index]);
        }
        return prayerName(prayerAt(step));
    }

    // "1er Misterio Gozoso" .. "5to Misterio Luminoso"; "Inicio" for the opening, "Final" for the Salve.
    function decadeTitle(step as Number, set as MysterySet) as String {
        var decade = decadeAt(step);
        if (decade == 0) {
            return I18n.text(I18n.OpeningTitle);
        }
        if (decade == CLOSING_DECADE) {
            return I18n.text(I18n.ClosingTitle);
        }
        return mysteryTitle(set, decade);
    }

    // Line under the title: the current mystery, or the day's set ("Misterios Gozosos") at the opening and
    // the Salve. Each set's title is a string of its own, not a template over the glance's set name, so each
    // language writes it its own way (French "Mystères joyeux", with the adjective in lower case).
    function subtitle(step as Number, set as MysterySet) as String {
        var decade = decadeAt(step);
        if (decade >= 1 && decade <= DECADES) {
            return mysteryName(set, decade);
        }
        var keys = [I18n.SetTitleJoyful, I18n.SetTitleSorrowful, I18n.SetTitleGlorious,
            I18n.SetTitleLuminous] as Array<Number>;
        return I18n.text(keys[set as Number]);
    }

    // "1er Misterio Gozoso" .. "5to Misterio Luminoso" for mystery 1..5 of a set: the MysteryTitle template
    // with the ordinal and the set's name in singular.
    function mysteryTitle(set as MysterySet, decade as Number) as String {
        var ordinals = [I18n.Ordinal1, I18n.Ordinal2, I18n.Ordinal3, I18n.Ordinal4,
            I18n.Ordinal5] as Array<Number>;
        return Lang.format(I18n.text(I18n.MysteryTitle), [I18n.text(ordinals[decade - 1]), setNameSingular(set)]);
    }

    // "Gozoso": the set's name as "1er Misterio Gozoso" uses it.
    function setNameSingular(set as MysterySet) as String {
        var keys = [I18n.SetSingularJoyful, I18n.SetSingularSorrowful, I18n.SetSingularGlorious,
            I18n.SetSingularLuminous] as Array<Number>;
        return I18n.text(keys[set as Number]);
    }

    // Name of mystery 1..5 of a set; "" for the opening (0) and the closing (6).
    function mysteryName(set as MysterySet, decade as Number) as String {
        if (decade < 1 || decade > DECADES) {
            return "";
        }
        var keys = [
            I18n.Mystery1, I18n.Mystery2, I18n.Mystery3, I18n.Mystery4, I18n.Mystery5,
            I18n.Mystery6, I18n.Mystery7, I18n.Mystery8, I18n.Mystery9, I18n.Mystery10,
            I18n.Mystery11, I18n.Mystery12, I18n.Mystery13, I18n.Mystery14, I18n.Mystery15,
            I18n.Mystery16, I18n.Mystery17, I18n.Mystery18, I18n.Mystery19, I18n.Mystery20
        ] as Array<Number>;
        return I18n.text(keys[mysteryIndex(set, decade)]);
    }
}
