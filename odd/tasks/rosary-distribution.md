# Rosary distribution

## Objective

Make the Rosario widget ready to distribute: Spanish, English and French, published in a GitHub repository, and packaged so the user can submit it to the Connect IQ Store.

## Problem

The widget is Spanish only. Its user-facing text lives partly in code (`source/Rosary.mc`: prayer names, mystery names, glance labels) and partly in `resources/strings`. It has no remote repository, no license, and no store package or metadata.

## Why

The user tested every feature on the watch and wants other people to use it ("ahora quiero que podamos distribuirlo, y para eso mínimo debe estar no solo en español sino también en inglés y francés, y obviamente en un repo de GitHub").

## Scope

Authorized by the user in the message above.

- Every user-facing string comes from Connect IQ string resources. The base `resources` folder is English, so devices in any other language fall back to English. `resources-spa` holds Spanish and `resources-fre` holds French.
- Translations of the UI, the prayer names, the mystery names and the glance labels. Bible quotes in each language, from translations the user approves.
- Layout tests cover every language's strings against the visible area.
- Release files: manifest languages, store description texts, an English README with a Spanish and French summary, a license, and a `.gitignore` that keeps build output and signing keys out of the repo.
- A GitHub repository under the user's account, with the code pushed and one pull request.

Out of scope: submitting to the Connect IQ Store, which needs the user's Garmin developer account; I prepare the `.iq` package and a checklist. Out of scope as well: other devices and other languages.

## Constraints

- Instinct 2 only (176x176 MIP, CIQ 3.4.2). The glance memory limit is 32KB and the widget limit is 64KB.
- The store package must be signed with a persistent developer key that the user keeps. The throwaway key in the session scratchpad must not sign a store release.
- Quotes must be verbatim from a named source, never written from memory. For public distribution, prefer public-domain translations or the user's explicit choice.
- Code, comments and docs in English. Conventional commits, no AI attribution.
- Creating the repository, its visibility, pushing and the pull request follow the user's explicit go-ahead.

## Delivery

- Strategy: `single-pr` (the user's standing preference for these repos).
- Forecast: about 1,300 authored changed lines (D1 ~300, D2 ~400, D3 ~400, D4 ~200).
- Branch: continue on `feat/rosary-mvp`.

## Tasks

| ID | Task | Route | Status |
|----|------|-------|--------|
| D1 | `refactor(i18n)`: move every user-facing string to string resources, Spanish still in the base `resources` (D2 makes the base English and moves Spanish to `resources-spa`), with glance-scoped strings where the glance needs them; behavior and Spanish output unchanged; tests stay green | delegated writer (2+ non-trivial files) | [x] 6e1eb8c (+228/-117). 48 new string ids (52 in all). Pure refactor, so no RED step: the 50 existing tests were the safety net, and two mutation rounds showed that the reworked tests still catch errors (swapped menu labels and swapped mystery names: 47 passed, 3 failed; wrong mystery in the reading view: 48 passed, 2 failed). A one-off script compared all 48 moved or composed strings with the old constants: 0 differences. Debug and release `-w`: 0 warnings. Tests 50/50. Release 26,316 bytes (was 24,060). Glance in the simulator: 15720 -> 12504 bytes used of 28488 |
| D2 | `feat(i18n)`: English strings and quotes; layout tests for every language | delegated writer | [x] d41f949 `test(i18n)` per-language suites (D2a, +382/-165); 1cdbde8 `feat(i18n)` English base, Spanish in `resources-spa` (D2b, +484/-125, mostly strings and quotes); review follow-ups 790e3d0 (glance check) and 47437c2 (reading first line). `scripts/test-all.sh`: eng PASSED 54/54, spa PASSED 54/54 (Spanish pins unchanged; every Spanish prayer label in the large font). Debug and release `-w`: 0 warnings. Reviewed: approved (`review-ae887318be97c6b6`, over `c5aa1b5..a21e9c8`) |
| D3 | `feat(i18n)`: French strings and quotes | delegated writer | [x] 0179880 (+433/-15, mostly strings and quotes); d9669b1 `fix(i18n)` mystery names wrap at spaces, never after an apostrophe. RED on the first French run: `mainScreenTextStaysInsideTheVisibleArea` (fre 54 passed, 1 failed: "Le Couronnement d’" / "épines", "L’Institution de l’" / "Eucharistie") -> GREEN fre PASSED 56/56 (55 planned plus the new pin `mysteryNameKeepsItsElisionsWhole`). Debug and release `-w`: 0 warnings. Reviewed: approved (`review-ae887318be97c6b6`, over `c5aa1b5..a21e9c8`) |
| D4 | `chore(release)`: manifest languages, store texts, README, license, `.gitignore`, `.iq` export steps | delegated writer (2+ non-trivial files) | [x] 1726ec9 `docs(readme)` (+187/-51); 010da8f `chore(release)` (+288/-1): LICENSE (MIT), NOTICE, `store/listing-{eng,spa,fre}.md`, `docs/RELEASE.md`, `.gitignore`. Manifest languages were already eng/spa/fre (D2/D3). Checks: `.iq` export BUILD SUCCESSFUL, 27,003 bytes, 0 compiler warnings, but 1 package-tool WARNING (part number 006-B4071-00 left out, see Progress), so not checked off until the user decides; `git check-ignore` ignores all 5 sample paths; links and Project layout readback pass; tree clean. Passive docs: no RED test Parent decision: the package tool's single warning (part 006-B4071-00, Connect IQ 3.2.7, an Instinct 2 variant the SDK lists with English and Asian languages only) is accepted. Keeping minApiLevel 3.4.0 leaves that part out; the compiler itself reports 0 warnings. The repository URL placeholders in the three listings were filled in by the parent |
| D5 | `chore`: create the GitHub repository, push, open the pull request | parent (user-authorized remote operation) | [ ] |

## Acceptance criteria

- Builds with 0 warnings, and every test passes.
- With the device in Spanish, the app reads exactly as today. In English and French every screen is translated, and every text fits the visible area.
- No signing key or build output in the repository.

## Checks

- TDD where a runnable test can fail first.
- Layout tests for all three languages.
- On-device check by the user in at least one non-Spanish language.

## Progress

- Feature document created.
- D1 (6e1eb8c): every user-facing string is a resource. `strings.xml` holds the UI and `mysteries.xml` the 20 mystery names (`MysteryN`, N = `Rosary.mysteryIndex` + 1, like `QuoteN`). Composed texts are `Lang.format` templates: `PrayerNumber` "$1$ $2$" (Avemaría 7), `MysteryTitle` "$1$ Misterio $2$" (ordinal, set name in singular), `SetTitle` "Misterios $1$", `GlanceMystery` "Misterio $1$/$2$". `RosaryView` loads its prayer label once per step, as it already did for the title and the mystery name.
- D1 glance: the glance strings (4 set names in plural, the 4 glance summaries, `PrayerSalve`) are `scope="glance"` (`doc/docs/Core_Topics/Resources.html`, "Resource Scopes", API 3.1.0). Measured in the simulator: when glance code looks up a foreground-only string, the glance crashes with "Symbol Not Found Error", and the compiler does not warn, even with `-w`. So `Rosary.mc` (the `(:glance)` module) looks up only glance strings and builds each lookup table inside its function. The labels only the full-screen widget shows continue the `Rosary` module in `source/RosaryLabels.mc`, which has no glance annotation (`:glance` marks code blocks, `doc/docs/Monkey_C/Annotations.html`), so their code stays out of the glance. The callers did not change.
- D1 glance memory: instrumented copies printed `System.getSystemStats().usedMemory` in the glance's `onUpdate`; nothing instrumented was committed. Results: 15720 bytes at 32e97cf; 14456 with the strings moved but the labels still in the glance module; 12504 after the split, out of 28488. Debug `--build-stats` for the glance: data 2987 -> 2152 bytes, code 4406 -> 3730 bytes. The same instrumented glance loaded every text for the 4 sets at positions -1..72 with no crash, all in Spanish.
- D1 tests: a test about a text itself pins the Spanish text, as before. That covers set names, mystery names, prayer labels, decade titles and ordinals, subtitles, glance summaries, menu titles and their wrap, the reset prompt and the quotes. A test where a text only shows which item is on screen now compares it with its resource: the glance after a reset, the menu labels, and the reading view's title and first line. The layout tests measure the loaded strings, including the real prayer label; the clock test now uses the real opening texts.
- Finding for D2: the simulator runs in English (`systemLanguage == LANGUAGE_ENG`). Once the base is English, every Spanish-pinned test above fails in a plain test run.
- Multi-language test strategy (research, measured in a scratch copy):
  - No CLI control of the language. `monkeydo` and MonkeyDoDeux take only `-a/-d/-f/-n/-s/-t`. The simulator `shell` commands (`help`) have no language command. The language is only the simulator's Settings > Language menu (`setLanguageMenu` in the simulator binary). `monkeyc --help` has no language option.
  - What works: a test-only jungle per language that appends the language folder to the base resources, `base.resourcePath = $(base.resourcePath);resources-spa` (`doc/docs/Reference_Guides/Jungle_Reference.html`: `resourcePath`, `lang`, `excludeAnnotations`). The later path wins: `resources;resources-spa` loaded "Inicio" and `resources-spa;resources` loaded "Start". `resources-fre` loaded "Début". So the whole suite, layout tests included, runs against each language's real strings on an English simulator.
  - Per-language pins: annotate them `(:test :spa)` or `(:test :fre)` and exclude the other languages in each jungle (`base.excludeAnnotations = $(base.excludeAnnotations);fre`). Verified: the French build compiled out `spanishPin`, ran 52 tests, and `frenchPin` passed. The default English test build would need `spa;fre` excluded too.
  - Bonus: with `-w`, the compiler warns for each string a language leaves out ("String id 'X' undefined for language 'spa'"). A 0-warnings build therefore proves every translation is complete.
  - Alternatives:
    - A generated test-only table of every language's strings, plus a sync check. One run covers every language, but it needs a generator script, the strings exist twice, and the views would have to take injected strings instead of loading resources.
    - Switching the simulator language by hand before each run. Not scriptable.
    - Gating on `DeviceSettings.systemLanguage` (API 3.1.0). Only useful with the manual switch, since the jungle override does not change it.
  - Recommendation: per-language test jungles plus per-language pin annotations. Cost: one test build and one test run per language.
- Follow-up for D4: README's Project Layout table does not list `source/RosaryLabels.mc` or `resources/strings/mysteries.xml` (README is outside D1's edit surface).

- Review over `a4f3a9d..c5aa1b5` (R16, R17, D1): **approved**, acknowledged (lineage `review-be386e188f75fd8f`). Two advisory findings, fixed in this batch:
  - `R3-glance-scope-unguarded` (WARNING): 790e3d0 adds `scripts/check-glance-strings.py`, which `scripts/test-all.sh` runs before the builds. It reads the `(:glance)` code (less `getInitialView`, which the system calls only for the full app) and fails when it looks up a string that the base or a language does not mark `scope="glance"` or leaves out, when it calls code defined only outside the glance (such as `RosaryLabels.mc`), or when a glance-scoped string goes unused. Mutations, each reverted: `glanceSummary` looking up `OpeningTitle` fails (and reports `GlanceInProgress` unused); `glanceSummary` calling `prayerName(SALVE)` fails ("defined only outside the glance (source/RosaryLabels.mc:9)"); `GlanceDone` without its scope fails. Clean tree: "the glance looks up 9 strings, each glance-scoped in resources, resources-fre, resources-spa".
  - `R3-reading-body-prefix-weak` (SUGGESTION): 47437c2 also checks that the reading view's first body line is not empty and equals the first line of `ReadingLayout.wrapWords` over the mystery's name. With an empty first line forced into `MysteryView`, the old test passed (48 passed, 2 failed, the two being other tests) and the new one fails (47 passed, 3 failed); without the mutation 50/50 ("La Visitación de").
- User choices for D2/D3: English is the base language (any other device language falls back to it); Spanish reads exactly as before; quotes "Mixto": English Douay-Rheims (Challoner), French Crampon 1923, Spanish unchanged.
- D2a (d41f949), the multi-language test strategy above:
  - `test-<lang>.jungle` appends `resources-<lang>` to `base.resourcePath` and excludes the other languages' annotations. A test that pins a text word for word lives in `source/Pins<Lang>.mc` as `(:test :<lang>)`; the three files define the same test names (the 11 Spanish pin tests moved out of `RosaryTests.mc`, two renamed: `decadeTitleUsesTheOrdinals`, `resetPromptIsTranslated`), and their checks are shared in `source/TextPins.mc`. A script check confirmed all 74 string literals of the removed tests are in the new files. `monkey.jungle` excludes `spa;fre` since D2b, so a plain `-t` build (the VS Code extension's) is the English suite.
  - Each language's jungle and pins arrive with its strings (`test-spa.jungle` in D2a, `test-eng.jungle` in D2b, `test-fre.jungle` in D3): before D2b an English suite would only have rerun the language-neutral tests over the Spanish strings. A missing resource folder is silently ignored by `monkeyc`.
  - `scripts/test-all.sh` builds every `test-*.jungle` with `-w -t` (a warning fails the language), runs it with MonkeyDoDeux started directly in its own process group under a perl alarm (`TEST_TIMEOUT`, default 180s; on timeout the whole group is killed, so no client stays connected), retries a run with no result once, and counts a result only when the log holds `suite=<lang>` (logged by each language's first pin test). It finds the SDK from `current-sdk.cfg` (the SDK Manager's choice) or `CIQ_SDK`, and needs `DEVELOPER_KEY`.
  - Evidence: `spa PASSED (passed=50, failed=0, errors=0)`; a mutated Spanish pin ("Gozosas"): `spa FAILED (passed=49, failed=1, errors=0)`; `TEST_TIMEOUT=2`: "no result from the simulator after 2 runs", and the MonkeyDoDeux count stayed at the 3 idle clients from earlier sessions.
  - `-w` does flag a missing translation: with `MenuReset` removed from `resources-spa`, "WARNING: instinct2: String id 'MenuReset' undefined for language 'spa'."
- Widths measured with the real Dc (probe in a scratch copy; px, tiny/small/medium/large): "Apostles' Creed" 115/120/131/144, "Hail Holy Queen" 117/116/129/143, "Hail Mary 10" 91/94/104/120, "Je crois en Dieu" 117/118/130/146, "Je vous salue Marie" 145/150/161/186, "Je vous salue Marie 7" 158/164/177/205, "Gloire au Père" 104/104/117/131, "Lire le mystère" (large) 141, "Recommencer" 131, "Non commencé" (medium) 124, tiny "douloureux" 82, "1er mystère" 87, "1st Joyful" 73. Every glyph French needs (é è ê à ç ô Ô É « » ’ … œ) is in every system font, and the no-break spaces U+00A0 and U+202F measure 4px, like a space (a missing glyph: tiny 18, small 20, medium 23, large 26).
- D2b (1cdbde8): the Spanish strings moved unchanged (`git mv`; byte-identical to `c5aa1b5`). English: Apostles' Creed, Our Father, Hail Mary, Glory Be, O My Jesus, Hail Holy Queen; Joyful/Sorrowful/Glorious/Luminous; "1st Joyful Mystery"; "Opening Prayers" and "Closing Prayer" for the main screen's first and last titles; glance "Not started", "In progress", "Mystery 3/5", "Completed", "Hail Holy Queen"; menu "Read mystery", "Restart"; prompt "Restart the rosary?". Mystery names as the USCCB lists them ("The Agony in the Garden", "The Descent of the Holy Spirit", "The Institution of the Eucharist"...). `AppName` stays "Rosario" in every language.
- D2b layout: the prayer's line holds 136px in the large font, 146 in the medium and 152 in the small and tiny (a taller font reaches lower rows, which the bezel narrows). `MainLayout.prayerFont(dc, label)` picks the largest that holds the label, measured once per step on the view's first draw. English "Apostles' Creed" and "Hail Holy Queen" take the medium font; every Spanish label takes the large one, so no Spanish screen changes (pinned: `prayerLabelStepsDownOnlyForLongNames`). The new neutral test `prayerLabelUsesTheLargestFontThatFits` checks every label fits and that no larger font would.
- D3 (0179880): French: Je crois en Dieu, Notre Père, Je vous salue Marie, Gloire au Père, Ô mon Jésus, Salve Regina; joyeux/douloureux/glorieux/lumineux ("Joyeux" in the glance); "1er mystère joyeux"; "Début" and "Fin"; glance "Non commencé", "En cours", "Mystère 3/5", "Terminé", "Salve Regina"; menu "Lire le mystère", "Recommencer"; prompt "Recommencer le chapelet ?" with a no-break space. Mystery names: L’Annonciation, La Visitation, La Nativité, La Présentation au Temple, Le Recouvrement de Jésus au Temple, L’Agonie au jardin, La Flagellation, Le Couronnement d’épines, Le Portement de la Croix, La Crucifixion et la mort de Jésus, La Résurrection, L’Ascension, La Pentecôte, L’Assomption, Le Couronnement de Marie, Le Baptême de Jésus au Jourdain, Les Noces de Cana, L’Annonce du Royaume de Dieu, La Transfiguration, L’Institution de l’Eucharistie.
- D3 layout, none of it changing a Spanish screen:
  - The subtitle at the opening and the Salve is a string per set (`SetTitleJoyful`...) instead of the `SetTitle` template over the glance's set name, so French writes "Mystères joyeux" in lower case while the glance shows "Joyeux". Spanish keeps "Misterios Gozosos".
  - `MainLayout.wrap` (titles and mystery names) keeps `fitTextToArea`'s wrap when it breaks only at spaces and cuts no word (every Spanish and English text, unchanged); otherwise it wraps at spaces only. Titles: "2e" / "mystère" / "douloureux" (82px on the last line, where the rows leave about 94px) instead of "doulour…". Names (d9669b1, found by the first French run): `fitTextToArea` also breaks after an apostrophe, so "Le Couronnement d’épines" now reads "Le Couronnement" / "d’épines" and "L’Institution de l’Eucharistie" "L’Institution de" / "l’Eucharistie".
  - "Je vous salue Marie 7" fits no font on the prayer's line (158px in the tiny font; the line holds 152), and no two-line layout fits between a two-line mystery name and the progress boxes. So the French `PrayerNumber` template is "$1$": the label is "Je vous salue Marie" (small font, 150px) and the number shows in the subscreen ring as in every language. ("Ave Maria 7" would fit the large font, if the user prefers it.)
  - New neutral tests: `screenFontsHaveEveryGlyph` (every non-ASCII character of the glance, titles, names, prayer labels, menu labels in its own font, and of the reset prompt in every font) and `readingNeverBreaksAtPunctuation` (no reading line starts with : ; ? ! » , . or ends with «). French-only: `sorrowfulTitleKeepsItsLongWordWhole`.
- Quotes: each page was downloaded into its own folder, its verses extracted by script, and a script checked that every quote in each `quotes.xml` is an exact excerpt of the cited verses ("ALL VERBATIM" for English and French). The French quotes were cut from the extracted verses by script, so they keep the page's no-break spaces (U+00A0 inside « », U+202F before : ; ? !, as the source mixes them). "…" follows the Spanish rule; English Acts 2:4 opens with "…" because Acts 2:3 ends with a colon.

| # | English (Douay-Rheims) | Source | French (Crampon 1923) | Source |
|---|------------------------|--------|-----------------------|--------|
| 1 | Lk 1:28 | https://www.drbo.org/chapter/49001.htm | Lc 1, 28 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#1-28 |
| 2 | Lk 1:42 (Elizabeth's words) | https://www.drbo.org/chapter/49001.htm | Lc 1, 42 (Élisabeth's words) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#1-42 |
| 3 | Lk 2:7 (to "manger…") | https://www.drbo.org/chapter/49002.htm | Lc 2, 7 (to "crèche…") | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#2-7 |
| 4 | Lk 2:30-31 | https://www.drbo.org/chapter/49002.htm | Lc 2, 30-31 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#2-30 |
| 5 | Lk 2:49 | https://www.drbo.org/chapter/49002.htm | Lc 2, 49 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#2-49 |
| 6 | Lk 22:42 (the words of Jesus) | https://www.drbo.org/chapter/49022.htm | Lc 22, 42 (the words of Jesus) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#22-42 |
| 7 | Jn 19:1 | https://www.drbo.org/chapter/50019.htm | Jn 19, 1 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Jean#19-1 |
| 8 | Jn 19:2 | https://www.drbo.org/chapter/50019.htm | Jn 19, 2 (to "sur sa tête…") | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Jean#19-2 |
| 9 | Jn 19:17 | https://www.drbo.org/chapter/50019.htm | Jn 19, 17 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Jean#19-17 |
| 10 | Lk 23:46 | https://www.drbo.org/chapter/49023.htm | Lc 23, 46 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#23-46 |
| 11 | Lk 24:5-6 (the angels' words) | https://www.drbo.org/chapter/49024.htm | Lc 24, 5-6 (the angels' words) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#24-5 |
| 12 | Acts 1:9 | https://www.drbo.org/chapter/51001.htm | Ac 1, 9 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Actes#1-9 |
| 13 | Acts 2:4 | https://www.drbo.org/chapter/51002.htm | Ac 2, 4 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Actes#2-4 |
| 14 | Lk 1:48 | https://www.drbo.org/chapter/49001.htm | Lc 1, 48 (from "Voici, en effet") | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#1-48 |
| 15 | Apoc 12:1 | https://www.drbo.org/chapter/73012.htm | Ap 12, 1 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Apocalypse#12-1 |
| 16 | Mt 3:17 | https://www.drbo.org/chapter/47003.htm | Mt 3, 17 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Matthieu#3-17 |
| 17 | Jn 2:5 | https://www.drbo.org/chapter/50002.htm | Jn 2, 5 | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Jean#2-5 |
| 18 | Mk 1:15 (the words of Jesus) | https://www.drbo.org/chapter/48001.htm | Mc 1, 15 (the words of Jesus) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Marc#1-15 |
| 19 | Mk 9:6 (Vulgate numbering; Mc 9, 7 in the Spanish Bible) | https://www.drbo.org/chapter/48009.htm | Mc 9, 6 (same numbering) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Marc#9-6 |
| 20 | Lk 22:19 (the words of Jesus) | https://www.drbo.org/chapter/49022.htm | Lc 22, 19 (the words of Jesus) | https://fr.wikisource.org/wiki/Bible_Crampon_1923/Luc#22-19 |

- Sizes: release `Rosario.prg` 35,756 bytes, 0 warnings (26,316 after D1; the English and French strings and quotes). Debug `--build-stats` for the glance: data 2152 bytes, code 3730 bytes, the same as after D1, so the translations add no glance code or data. Glance at run time, measured as in D1 (uncommitted instrumented copy printing `System.getSystemStats().usedMemory` in `onUpdate`, each language's strings over the base ones, run in the simulator): 12560 of 28488 bytes in English ("Glorious" / "Not started"), Spanish ("Gloriosos" / "Sin empezar") and French ("Glorieux" / "Non commencé"), against 12504 after D1; each glance drew its language's labels with no error, so its glance-scoped strings resolve in all three.
- Blocked check: the simulator stopped answering at 22:52 (its system log shows no activity after the last successful run at 22:52:17; it sits at 0% CPU and accepts connections without answering), during D2b. Every run since timed out, including a known-good build; the timeout left no client behind. Restarting it was not permitted in the writer session (`connectiq`, which only activates the running app, did not help). So D2b's English and Spanish suites and D3's French suite have not run, nor has any RED step for D2b and D3; all builds are 0 warnings. The longest quotes (English Acts 2:4, Apoc 12:1, Lk 23:46; French Lc 1, 28, Ap 12, 1, Ac 2, 4, about 140 characters) are the most likely to exceed 3 reading screens. Resolved: the user quit the simulator and the coordinator relaunched it; every run since answered normally.
- Follow-ups for D4: README line 3 still says the text on the watch is in Spanish, and its feature list uses the Spanish UI names; the Project Layout table lacks `source/RosaryLabels.mc`, `source/TextPins.mc`, `source/Pins*.mc`, `resources-spa`, `resources-fre`, the `test-*.jungle` files and `scripts/`.
- Test run after the restart: `eng PASSED (passed=54, failed=0, errors=0)`, `spa PASSED (passed=54, failed=0, errors=0)`, `fre PASSED (passed=56, failed=0, errors=0)`, each identified by its `suite=<lang>` line. Reading screens, from the logs: every mystery reads in 2 or 3 screens (11 or 12 lines at most) in every language, so no quote needed trimming.
- User decisions after D3: French keeps "Je vous salue Marie" in the small font without the number on the main screen (the ring shows it); `AppName` stays "Rosario" in every language.
- Review over `c5aa1b5..a21e9c8` (D2, D3 and the follow-ups): **approved**, acknowledged (lineage `review-ae887318be97c6b6`, authority burned). The reviewed boundary is now `a21e9c8`. Nine non-blocking advisory findings, kept as later follow-ups (outside D4's surface, not fixed):
  - `R2-pinsfre-invisible-nbsp` (WARNING), `source/PinsFre.mc:4-6`: the literal U+00A0/U+202F in the pins cannot be seen; build them from named constants made from the code point.
  - `R3-wrap-fallback-unbounded` and `R4-wrap-fallback-unbounded`, `source/RosaryView.mc:84-103`: the space-only wrap fallback ignores the height, so only the tests guarantee the line count. The shipped strings are safe.
  - `R2-lastmysteries-misnamed`, `source/TextPins.mc:35-36`.
  - `R2-prayerfont-magic-widths`, `source/RosaryView.mc:115-121`.
  - `R2-textpins-spanish-ui-comments`, `source/TextPins.mc:100-126`.
  - `R2-textpins-steps-duplicated`, `source/TextPins.mc:52-67`.
  - `R3-glance-check-name-collision`, `scripts/check-glance-strings.py:158`.
  - `R3-punctuation-test-empty-line`, `source/LayoutTests.mc:447-449`.
- D4 (1726ec9 `docs(readme)`, 010da8f `chore(release)`):
  - README in English: what the app does, controls (Connect IQ button names, with each button's place from the simulator's `simulator.json` key coordinates), a languages table, device support, build and per-language test instructions with `DEVELOPER_KEY`, sideloading to `GARMIN/APPS`, a Project layout table split into app code, tests, resources and project files, the Bible text sources, and Spanish and French summaries. The UI names come from each language's `strings.xml`.
  - Spanish copyright line, from the footer of https://www.vatican.va/archive/ESL0506/_INDEX.HTM (under "Créditos"; page downloaded with curl on 2026-10-21): "Copyright © Libreria Editrice Vaticana". The page's title block reads "EL LIBRO DEL PUEBLO DE DIOS / La Biblia / (Traducción argentina) / 1990", and its publication details read "Puede imprimerse de la Conferencia Episcopal Argentina".
  - The other two sources do not state the translations' public-domain status: the source of https://www.drbo.org/chapter/49001.htm holds the HTML comment "© Copyright drbo.org 2001-2023. All rights reserved.", and the French Wikisource footer offers its texts under CC BY-SA 4.0 ("d’autres conditions peuvent s’appliquer"). Wikisource's talk page gives the edition: "La Sainte Bible, traduction d'après les textes originaux par l'abbé A. Crampon, chanoine d'Amiens, Desclée, 1923."
  - LICENSE is the plain MIT text (Cesar Tapasco, 2026), so GitHub can still detect the license. The README's "Bible text sources" and "License" sections and `NOTICE` state that the quotes are not covered and keep their own terms.
  - Store listing limits: the SDK 9.2.0 docs give none (`doc/docs/Core_Topics/Publishing_to_the_Store.html` only says to add "a description, screen shots, and other details"; `doc/docs/App_Review_Guidelines/Overview.html` gives no lengths). The listings follow the guidelines' content rules instead: every feature, minimum requirements (Connect IQ 3.4), payment status, a support contact, and the quote sources. `manifest.xml` and the packaged manifest declare no permissions.
  - `monkeyc -e` checked: `-e` "Specifies that output is an IQ file for uploading to the app store" (`doc/docs/Monkey_C/Compiler_Options.html`); the key commands are the ones in `doc/docs/Core_Topics/Security.html`. Into an empty folder, the export wrote only `Rosario.iq` (27,003 bytes; 27,004 in an earlier run). Its intermediates went to a temporary folder, and `git status --short --ignored` stayed empty. The `.iq` is a 7-Zip archive: `manifest.xml`, `manifest.sig2`, `dev_key.pub`, `006-B3888-00/Rosario.prg` (35,756 bytes) and `006-B3888-00/debug.xml`. Its manifest lists eng, fre and spa and no permissions.
  - Export warning: "Part number: '006-B4071-00' CIQ ver: '3.2.7' is being ignored by the package tool because it does not support the minimum API Level set for this project". The device's `compiler.json` lists two part numbers: 006-B3888-00 (Connect IQ 3.4.2, 28 languages including eng, spa and fre) and 006-B4071-00 (Connect IQ 3.2.7; eng, ind, zsm, zhs, zht, jpn, kor, tha, vie). The manifest's `minApiLevel` is 3.4.0. This is a package-tool warning, not a compiler warning; the release build still reports 0 compiler warnings.
  - `.gitignore` adds `*.der` and `*.pem`. No tracked file matches them.
  - Decisions for the user before a store submission: (1) accept leaving out 006-B4071-00, or lower `minApiLevel` and check every API against Connect IQ 3.2 (it would show only English); (2) the rights to the Spanish quotes, since Garmin's guidelines (3a) require owning or licensing all IP in the app: ask the publisher, or switch to a public-domain Spanish translation; (3) the listings say the app is free; (4) the repository URL placeholder in each listing, filled after D5.

## Next step

The user decides on part number 006-B4071-00 (then D4 can be checked off) and on the Spanish quotes' rights before any store submission. Then D5 (GitHub repository, push, pull request), and the user checks the widget in English or French on the watch.
