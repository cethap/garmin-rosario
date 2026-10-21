# Latin language

## Objective

Add Latin as a fifth choice in the in-app language picker, so the whole rosary can be prayed in Latin.

## Problem

The widget speaks English, Spanish and French. Latin is the official language of the Holy See and has its own traditional texts for the rosary prayers. Connect IQ has no Latin device language (`System.LANGUAGE_*`), so the watch can never ask for Latin. Only the in-app choice can select it.

## Why

The user asked for it after the in-app language option: "luego de esta ponela en latín, que es como creo que lo rezan en el Vaticano".

## Scope

Authorized by the user in the message above.

- A fifth picker item, "Latina", always shown in Latin like the other language names. Automatic never resolves to Latin.
- Latin texts for every screen: prayer labels, mystery names, set names, titles, glance labels, menu, picker and reset prompt.
- Bible quotes from the Vulgata Clementina, chosen by the user ("Vulgata Clementina (Recomendado)"). It is public domain and numbers its verses like the Douay-Rheims. Each quote is verbatim and carries its source URL.
- Tests: Latin pins, fit and glyph checks, and the translation completeness check.
- The README, the store listings and NOTICE mention Latin and its source.

Out of scope: Latin as a device language, the Nova Vulgata.

## Constraints

- The constraints of `odd/tasks/in-app-language.md` still hold: Instinct 2, minApiLevel 3.4.0, glance memory budget, the glance reads only glance-scoped tables.
- The English, Spanish and French outputs stay exactly as they are, and their pins stay green.
- Prayer and mystery names follow the Church's Latin usage, sourced from vatican.va texts, for example the Compendium of the Catechism's Latin prayers and *Rosarium Virginis Mariae*, never written from memory. UI phrases are plain ecclesiastical Latin.
- Code, comments and docs in English. Conventional commits with no AI attribution.

## Delivery

- Strategy: `single-pr`, on the same branch as the language option (`feat/in-app-language`), which is not pushed yet.
- Forecast: about 500 authored changed lines (LA1 ~400, LA2 ~100).

## Tasks

| ID | Task | Route | Status |
|----|------|-------|--------|
| LA1 | `feat(i18n)`: Latin texts and Vulgata Clementina quotes, the fifth picker item, tests | delegated writer (2+ non-trivial files, research for sources) | [ ] |
| LA2 | `docs`: README, store listings, NOTICE | delegated writer | [ ] |

## Acceptance criteria

- Builds with 0 warnings, and every test passes in all four languages.
- Choosing Latina turns every screen to Latin, the glance included at its next refresh, and every text fits the visible area.
- Automatic behaves exactly as before.

## Checks

- TDD: the Latin pins and the picker test fail before the texts and the item exist.
- Layout and glyph tests in Latin.
- On-device check by the user.

## Sources

Pages downloaded on 2026-10-21 into the writer's scratchpad (`latin_sources/`).

| Texts | Source |
|-------|--------|
| Prayer titles: "Pater Noster", "Ave Maria", "Gloria Patri", "Salve Regina"; the Creed's title "Symbolum Apostolicum" and first word "Credo" | *Compendium of the Catechism*, appendix of common prayers with their Latin text: https://www.vatican.va/archive/compendium_ccc/documents/archive_2005_compendium-ccc_en.html (same Latin in the French and Italian editions) |
| The 15 joyful, sorrowful and glorious mysteries | The same appendix, "Rosarium". It prints "Agonía in Hortu", a misprint for "in Horto" (hortus, ablative horto), in all three editions checked. The app writes "Agonia in Horto" |
| The luminous mysteries and the set names (gaudiosa, dolorosa, gloriosa, luminosa) | *Rosarium Virginis Mariae*, Latin text, sections 19 to 23: https://www.vatican.va/content/john-paul-ii/la/apost_letters/2002/documents/hf_jp-ii_apl_20021016_rosarium-virginis-mariae.html |
| Fatima prayer, "Domine Iesu" | EWTN, "Oratio Fatima(e)": https://www.ewtn.com/catholicism/teachings/prayers-of-the-rosary-in-english-and-latin-164 and https://www.ewtn.com/catholicism/library/latin-prayers-9125. No official Latin text exists |
| Reference abbreviations: Lc, Io, Act, Mt, Mc | *Rosarium Virginis Mariae*, above |
| Reference abbreviation: Apc | *Ecclesia de Eucharistia*, Latin: https://www.vatican.va/content/john-paul-ii/la/encyclicals/documents/hf_jp-ii_enc_20030417_eccl-de-euch.html |
| Bible quotes | Vulgata Clementina, Clementine Text Project, on Bible Gateway: https://www.biblegateway.com/versions/Biblia-Sacra-Vulgata-VULGATE/. It names its base: Colunga and Turrado, 1946. drbo.org's Latin Vulgate (https://www.drbo.org/lvb/) has the same words, but it does not name its edition |

Notes on the sources, and deliberate changes the parent accepted:

- "Ave Maria" and "Salve Regina" are written without the commas the Compendium prints ("Ave, Maria", "Salve, Regina"), as the prayers' titles usually are; French already writes "Salve Regina".
- "Agonia in Horto" corrects the Compendium's misprint "Hortu".
- Names are written without the stress accents the Compendium prints, and with ae for æ, as *Rosarium Virginis Mariae* and the Vulgate text write them.
- The luminous names are *Rosarium Virginis Mariae*'s list (section 21), put in the nominative:
  - "Baptisma apud Iordanem";
  - "Autorevelatio apud Canense matrimonium". The Compendium has "Cananense";
  - "Regni Dei proclamatio", without "coniuncta cum invitamento ad conversionem", as the English name leaves out the call to conversion;
  - "Transfiguratio";
  - "Eucharistiae institutio".

## Quotes

Each quote takes the clauses of its English (Douay-Rheims) quote, with these deliberate differences:

- Where the Latin sentence goes on past the English quote's full stop, the Latin quote ends in "…" (Lc 1, 48; Io 19, 17; Lc 24, 6).
- Words the source writes in lower case stay so: "non est hic" (Lc 24, 6), "…et repleti" (Act 2, 4).
- Lc 22, 19 stops at "datur…", before "hoc facite in meam commemorationem". The reading window is 132px wide, "commemorationem." measures 144px in its font, and the wrap never splits a word.

Each chapter is on Bible Gateway at `https://www.biblegateway.com/passage/?search=<Book>%20<chapter>&version=VULGATE`.

| Quote | Reference | Chapter page | drbo.org |
|-------|-----------|--------------|----------|
| 1, 2, 14 | Lc 1, 28; 1, 42; 1, 48 | [Luke 1](https://www.biblegateway.com/passage/?search=Luke%201&version=VULGATE) | https://www.drbo.org/lvb/chapter/49001.htm |
| 3, 4, 5 | Lc 2, 7; 2, 30-31; 2, 49 | [Luke 2](https://www.biblegateway.com/passage/?search=Luke%202&version=VULGATE) | https://www.drbo.org/lvb/chapter/49002.htm |
| 6, 20 | Lc 22, 42; 22, 19 | [Luke 22](https://www.biblegateway.com/passage/?search=Luke%2022&version=VULGATE) | https://www.drbo.org/lvb/chapter/49022.htm |
| 10 | Lc 23, 46 | [Luke 23](https://www.biblegateway.com/passage/?search=Luke%2023&version=VULGATE) | https://www.drbo.org/lvb/chapter/49023.htm |
| 11 | Lc 24, 5-6 | [Luke 24](https://www.biblegateway.com/passage/?search=Luke%2024&version=VULGATE) | https://www.drbo.org/lvb/chapter/49024.htm |
| 7, 8, 9 | Io 19, 1; 19, 2; 19, 17 | [John 19](https://www.biblegateway.com/passage/?search=John%2019&version=VULGATE) | https://www.drbo.org/lvb/chapter/50019.htm |
| 17 | Io 2, 5 | [John 2](https://www.biblegateway.com/passage/?search=John%202&version=VULGATE) | https://www.drbo.org/lvb/chapter/50002.htm |
| 12 | Act 1, 9 | [Acts 1](https://www.biblegateway.com/passage/?search=Acts%201&version=VULGATE) | https://www.drbo.org/lvb/chapter/51001.htm |
| 13 | Act 2, 4 | [Acts 2](https://www.biblegateway.com/passage/?search=Acts%202&version=VULGATE) | https://www.drbo.org/lvb/chapter/51002.htm |
| 15 | Apc 12, 1 | [Revelation 12](https://www.biblegateway.com/passage/?search=Revelation%2012&version=VULGATE) | https://www.drbo.org/lvb/chapter/73012.htm |
| 16 | Mt 3, 17 | [Matthew 3](https://www.biblegateway.com/passage/?search=Matthew%203&version=VULGATE) | https://www.drbo.org/lvb/chapter/47003.htm |
| 18 | Mc 1, 15 | [Mark 1](https://www.biblegateway.com/passage/?search=Mark%201&version=VULGATE) | https://www.drbo.org/lvb/chapter/48001.htm |
| 19 | Mc 9, 6 | [Mark 9](https://www.biblegateway.com/passage/?search=Mark%209&version=VULGATE) | https://www.drbo.org/lvb/chapter/48009.htm |

## Latin UI texts

The parent approved them. "Secundum" (76px) gave way to "Alterum" (59px): the first title line of the reading view and the menu holds at most 72px there, where the bezel cuts the top left corner.

| Id | Latin | English meaning |
|----|-------|-----------------|
| GlanceNotStarted | Nondum coeptum | Not yet begun |
| GlanceInProgress | In cursu | In progress |
| GlanceMystery | Mysterium 2/5 | Mystery 2/5 |
| GlanceDone | Peractum | Completed |
| OpeningTitle | Initium | Beginning |
| ClosingTitle | Conclusio | Conclusion |
| MysteryTitle | Primum mysterium gaudiosum | First joyful mystery |
| Ordinal1..5 | Primum, Alterum, Tertium, Quartum, Quintum | First … fifth ("Alterum" is Latin's other ordinal for second) |
| SetSingular… | gaudiosum, dolorosum, gloriosum, luminosum | joyful, sorrowful, glorious, luminous |
| ResetPrompt | Rosarium denuo incipere? | Begin the rosary anew? |
| MenuRead | Lectio mysterii | Reading of the mystery |
| MenuLanguage | Lingua | Language |
| MenuReset | Incipe denuo | Begin anew |
| LanguageAutomatic | Automatica | Automatic (feminine, for lingua) |
| Picker item | Latina | Latin (lingua Latina) |

## Progress

- Feature document created.

## Next step

LA1.
