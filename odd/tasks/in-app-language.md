# In-app language

## Objective

By default the Rosario widget uses the watch's own language. Add an option inside the app to override it with English, Spanish or French.

## Problem

Connect IQ picks one `resources-<lang>` folder at build time per device language. At run time an app can load only the strings of the device's language. No API loads a string in another language. So a user whose watch is set to English cannot pray the rosary in Spanish, and the reverse.

## Why

The user asked for it after the multilingual release: "que además de que lo identifique automático, lo pueda cambiar desde una opción de la app".

## Scope

Authorized by the user in the message above.

- A new item in the hold-UP menu opens a language picker with four choices:
  - Automatic, which follows the watch and is the default;
  - English;
  - Español;
  - Français.

  Each language is named in that language. The choice is saved and survives restarts.
- Every screen follows the chosen language: the main view, the menu, the reading view, the reset prompt and the glance.
- Automatic keeps today's behavior: Spanish or French when the watch is set to that language, English otherwise.
- The tests cover every language. Every text stays inside the visible area, and the memory budgets still hold.
- The README and the store listings document the option.

Out of scope: a phone-side setting in Garmin Connect, other languages, other devices.

## Constraints

- Instinct 2 only, minApiLevel 3.4.0. The glance runs under a 32KB memory limit (28,488 bytes usable in the simulator).
- The glance runs in its own process and can read only glance-scoped resources and code.
- The Spanish, English and French outputs stay exactly as they are today. The pins prove it.
- Quotes stay verbatim, with the sources already recorded in `odd/tasks/rosary-distribution.md`.
- Code, comments and docs are in English. Conventional commits with no AI attribution.

## Delivery

- Strategy: `single-pr` (the user's standing preference for these repos). Branch `feat/in-app-language` from `main` at 1f88434.
- Forecast: about 900 authored changed lines (L1 0, L2 ~500, L3 ~250, L4 ~100). Most of it is the strings moving out of the language folders.

## Tasks

| ID | Task | Route | Status |
|----|------|-------|--------|
| L1 | Research: how to load any language's strings at run time, measured in a scratch copy only. Compare per-language string ids in the base resources with per-language JSON resources, by memory in the widget and the glance, speed and test cost. Also confirm the glance can read the saved choice | delegated research worker (more than 5 lookups plus a prototype) | [x] No commit, research only; prototypes under the session scratchpad. Result: Design B, per-language `jsonData` arrays (see Progress) |
| L2 | `refactor(i18n)`: load every text through a language-aware lookup that follows the watch language (Automatic); outputs unchanged; tests cover all three languages | delegated writer (2+ non-trivial files) | [x] 077c042 (see Progress) |
| L3 | `feat(menu)`: language item in the hold-UP menu, a picker view, the saved choice, the glance honoring it | delegated writer (2+ non-trivial files) | [x] 67a727f (see Progress) |
| L4 | `docs`: README, store listings and release notes for the option | delegated writer (5 files) | [x] e9e1784 (see Progress) |

## Acceptance criteria

- Builds with 0 warnings, and every test passes in every language.
- With Automatic, the app reads exactly as today on a Spanish, English or French watch.
- Choosing a language changes every screen, including the glance at its next refresh, and the choice survives leaving and reopening the app.
- The glance and widget memory stay within budget.

## Checks

- TDD where a runnable test can fail first. The picker and the lookup get unit tests.
- Layout tests for every language.
- On-device check by the user.

## Progress

- Feature document created.
- L1 research, measured in scratch copies of the repo at 1f88434:
  - **No API loads another language's strings.** `loadResource` takes only a resource id (`doc/Toybox/WatchUi.html`, `doc/Toybox/Application.html`). Folder qualifiers alone pick the language (`doc/docs/Core_Topics/Resources.html`). `<string>` has only `id`, `scope` and `translatable` (`bin/resources.xsd`).
  - **Design A fails.** Putting every language's string ids in the base resources needs 283 members in `Rez.Strings`, and the compiler stops at 254 ("exceeding the limit of 254"). More than 255 members per module are allowed only from API 5.0.0 (`doc/docs/Readme/History.html`).
  - **Design B, per-language `jsonData` arrays, is chosen.** Measurements:

    | | Today | Hybrid A | B |
    |---|---|---|---|
    | Release PRG | 35,756 | 46,732 | 33,148 |
    | Glance used, release (of 28,488) | 10,968 | 12,352 | 11,208 |
    | Widget at start | 23,824 | 32,008 | 23,688 |
    | Widget, main + largest reading view | 27,264 | 37,808 | 26,272 (+≤3,472 while a quote table loads) |

    A lookup loads its whole table and frees it on return: about 400 bytes for the glance table, 1 KB for the UI or mysteries table, 3.2–3.5 KB for the quotes, each in 1 ms or less in the simulator. Arrays cost about 2.4 times less than JSON objects keyed by id. The existing pins passed in all three languages under B.
  - **`jsonData` honors `scope="glance"`.** A glance that loads a foreground table crashes with "Symbol Not Found Error", and the compiler gives no warning.
  - **The glance reads `Application.Storage`** values written by the widget (verified in the simulator). It shows a new choice at its next refresh, up to about 30 s later (Background UI Update, `Glances.html`).
  - **Automatic:** `systemLanguage` is `LANGUAGE_SPA` → Spanish, `LANGUAGE_FRE` → French, anything else → English. The enum has no regional variants (`doc/Toybox/System.html`).
  - **Tests:** one test build can cover all three languages by switching the active language in code, which makes the per-language jungles unnecessary (prototype: 164 passed). Once the folder qualifiers are gone, a script must check every language's completeness, since the compiler no longer warns about missing strings. `scripts/check-glance-strings.py` must learn about `Rez.JsonData`.
  - **Risks:**
    - Positional arrays hide swapped entries. So translations are written keyed by id outside `resources/`, and a script generates the arrays and the key constants, with a staleness check.
    - Splitting the quotes table per mystery set keeps every load small.
    - The cached language must be reset when the user picks a new one.

- L2 done in 077c042 (delegated writer):
  - **Sources:** `i18n/<lang>.json`, keyed by table and id; keys starting with `//` are translator notes. `scripts/gen-i18n.py` writes `resources/i18n/<lang>.xml`, with inline `jsonData` arrays and a "do not edit" comment (a JSON file cannot hold one), and `source/I18nKeys.mc`. Its `--check` fails on a missing or empty text, an extra id, an added placeholder or a stale generated file. Seven tables per language: glance (`scope="glance"`), ui, mysteries and one quotes table per mystery set.
  - **Lookup:** `source/I18n.mc`. `resolve(choice, systemLanguage)` is the pure function. The language is cached until `reset()`, which the glance calls on each refresh. `glanceText` is the only lookup the glance makes. `text` loads any table, and `saveChoice` writes Storage key `language`. Only `AppName` stays a string resource. `resources-spa/`, `resources-fre/` and the `test-<lang>.jungle` files are gone, and `NOTICE` names the new quote files.
  - **Tests:** one test build. The pins are named `<test>Eng`, `<test>Spa` and `<test>Fre`. Every test that reads a text loops over the languages (`TestLanguage.use`). A probe ran the three heaviest tests three times inside one test and passed, so the loops stay clear of the watchdog (120,000 in `simulator.json`). Tests that read no text run once.
  - **Evidence:**
    - `resolve()` went RED against a stub that always answers English (every choice read `[0, 0, 0, 0, 0]`), then GREEN.
    - `scripts/test-all.sh`: translations OK, glance OK, PASSED 84, failed 0.
    - All 282 texts are byte-identical to HEAD's XML.
    - Mutations: 4 caught by the glance check, 5 by the translations check, and two Spanish set names swapped were caught by `setNamesArePluralAndSingularSpa` and `glanceShowsTheDaySetAndProgressSpa`.
    - Debug `-w`, release `-r -w` (34,204 bytes; 35,756 before) and the test build: 0 warnings.
  - **Memory:**
    - Each table loads in 360 bytes (glance) and 784 to 1,200 bytes (the others). Budgets: 512 and 1,536.
    - Glance used 11,496 of 28,488 with Automatic in English, and 11,512 with Spanish, French or English forced on the English watch. Before: 10,968.
    - Widget, main view plus the largest reading view: at most 25,408 (Spanish). Before: 27,264. A lookup adds at most 1,200 while it runs.
    - The largest reading view held 880 bytes (`MEMORY_BUDGET` 3,072).
  - **Size:** 1,377 authored lines of code, tests and scripts (`git diff -w`), 777 lines of translations moved out of the XML, and 514 generated lines.

- L3 done in 67a727f (delegated writer):
  - **Menu:** "Read mystery", "Language", "Restart". Three large-font bars do not fit: the second already ends at row 149, where the bezel leaves the 2px margin, and a third would end at row 187, past the screen's 176 rows. So the menu keeps the large font and shows two items at a time. The window follows the selection, and a thin scroll bar sits right of the bars: a 1px track at x 166, rows 85..141, with a 3px thumb.
  - **Picker** (`LanguageView`, `LanguageDelegate`): its title, "Language", sits beside the lens. The items are Automatic in the current language, then "English", "Español" and "Français", each in its own language. The saved choice carries a filled dot at the left of its bar and is selected first. UP and DOWN stop at the ends. START saves the choice, closes the picker and reloads the rosary's texts on the same bead. BACK changes nothing. Both lists share `BarListView` and `MenuLayout`.
  - **Evidence:**
    - TDD: with the picker's delegate an empty stub, its 3 tests failed, then passed once it was written. The same RED run found the scroll thumb 1px short of the margin at row 143, so the track ends at row 141.
    - `scripts/test-all.sh`: translations OK, glance OK, PASSED 89, failed 0.
    - Glyphs ñ, ç and á exist in the large font (11 to 12px).
    - Debug `-w` and release `-r -w` (36,332 bytes): 0 warnings.
  - **Memory:**
    - The menu holds 648 to 656 bytes and the picker 512 to 568, against `MEMORY_BUDGET` 3,072.
    - Widget, the main view plus the open picker: at most 27,216. Plus the largest reading view: at most 27,584 (Spanish). That includes the 2,128 bytes of new code, which stays resident. Before the feature: 27,264.
  - **Size:** 826 authored lines and 16 generated.

- L4 done in e9e1784 (delegated writer):
  - **README:** the Language item in the features, a Languages section on Automatic and the picker, the picker's controls, a Translations section, the single test build with its three steps, the Project Layout tables, and the Spanish and French summaries.
  - **Store listings:** the option, in each language.
  - **`docs/RELEASE.md`:** the test step's new output; a missing translation is caught by the translations check, not by compiler warnings; the language picker added to the screenshots; the package is now about 28 KB.
- Final checks on the code of e9e1784, which the commit recording them does not change:
  - Debug `-w` and release `-r -w` (36,332 bytes): 0 warnings.
  - `monkeyc -e -r -w`: BUILD SUCCESSFUL, 28,710 bytes, with only the known warning about part 006-B4071-00. The package declares eng, fre and spa, and no permissions.
  - Glance: 11,568 of 28,488 with Automatic on the English watch, and the same with Spanish, French or English forced. The glance read in the saved language each time.
  - Widget at its peak, the main view plus the largest reading view: 27,584 (Spanish).
  - `scripts/test-all.sh`: see the last commit's report.

## Next step

The user checks the language option on the watch. Then push and open the pull request, the user's decision under the `single-pr` strategy.
