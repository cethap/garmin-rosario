import Toybox.Lang;

// The labels of the full-screen widget: its main screen, the menu and the reading view. The Rosary module
// continues here without the glance annotation, so this code stays out of the glance's 32KB, and so do the
// strings it looks up, which are not glance-scoped. The glance must not call anything here (see "Text" in
// Rosary.mc).
module Rosary {
    // A prayer's name. The glance, which cannot call it, loads PrayerSalve itself.
    function prayerName(prayer as Prayer) as String {
        var ids = [Rez.Strings.PrayerCreed, Rez.Strings.PrayerOurFather, Rez.Strings.PrayerHailMary,
            Rez.Strings.PrayerGloryBe, Rez.Strings.PrayerFatima, Rez.Strings.PrayerSalve] as Array<ResourceId>;
        return loadText(ids[prayer as Number]);
    }

    // The bead being prayed, for example "Avemaría 7" (the PrayerNumber template), "Padre Nuestro" or
    // "Oh Jesús mío".
    function prayerLabel(step as Number) as String {
        var index = hailMaryIndex(step);
        if (index > 0) {
            return Lang.format(loadText(Rez.Strings.PrayerNumber), [prayerName(HAIL_MARY), index]);
        }
        return prayerName(prayerAt(step));
    }

    // "1er Misterio Gozoso" .. "5to Misterio Luminoso"; "Inicio" for the opening, "Final" for the Salve.
    function decadeTitle(step as Number, set as MysterySet) as String {
        var decade = decadeAt(step);
        if (decade == 0) {
            return loadText(Rez.Strings.OpeningTitle);
        }
        if (decade == CLOSING_DECADE) {
            return loadText(Rez.Strings.ClosingTitle);
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
        var ids = [Rez.Strings.SetTitleJoyful, Rez.Strings.SetTitleSorrowful, Rez.Strings.SetTitleGlorious,
            Rez.Strings.SetTitleLuminous] as Array<ResourceId>;
        return loadText(ids[set as Number]);
    }

    // "1er Misterio Gozoso" .. "5to Misterio Luminoso" for mystery 1..5 of a set: the MysteryTitle template
    // with the ordinal and the set's name in singular.
    function mysteryTitle(set as MysterySet, decade as Number) as String {
        var ordinals = [Rez.Strings.Ordinal1, Rez.Strings.Ordinal2, Rez.Strings.Ordinal3, Rez.Strings.Ordinal4,
            Rez.Strings.Ordinal5] as Array<ResourceId>;
        return Lang.format(loadText(Rez.Strings.MysteryTitle), [loadText(ordinals[decade - 1]), setNameSingular(set)]);
    }

    // "Gozoso": the set's name as "1er Misterio Gozoso" uses it.
    function setNameSingular(set as MysterySet) as String {
        var ids = [Rez.Strings.SetSingularJoyful, Rez.Strings.SetSingularSorrowful, Rez.Strings.SetSingularGlorious,
            Rez.Strings.SetSingularLuminous] as Array<ResourceId>;
        return loadText(ids[set as Number]);
    }

    // Name of mystery 1..5 of a set; "" for the opening (0) and the closing (6).
    function mysteryName(set as MysterySet, decade as Number) as String {
        if (decade < 1 || decade > DECADES) {
            return "";
        }
        var ids = [
            Rez.Strings.Mystery1, Rez.Strings.Mystery2, Rez.Strings.Mystery3, Rez.Strings.Mystery4, Rez.Strings.Mystery5,
            Rez.Strings.Mystery6, Rez.Strings.Mystery7, Rez.Strings.Mystery8, Rez.Strings.Mystery9, Rez.Strings.Mystery10,
            Rez.Strings.Mystery11, Rez.Strings.Mystery12, Rez.Strings.Mystery13, Rez.Strings.Mystery14, Rez.Strings.Mystery15,
            Rez.Strings.Mystery16, Rez.Strings.Mystery17, Rez.Strings.Mystery18, Rez.Strings.Mystery19, Rez.Strings.Mystery20
        ] as Array<ResourceId>;
        return loadText(ids[mysteryIndex(set, decade)]);
    }
}
