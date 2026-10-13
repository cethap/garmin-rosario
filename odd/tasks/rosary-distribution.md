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
| D2 | `feat(i18n)`: English strings and quotes; layout tests for every language | delegated writer | [ ] |
| D3 | `feat(i18n)`: French strings and quotes | delegated writer | [ ] |
| D4 | `chore(release)`: manifest languages, store texts, README, license, `.gitignore`, `.iq` export steps | delegated writer | [ ] |
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

## Next step

D2: English base strings and Spanish in `resources-spa`, with the per-language test jungles above. The user chooses the Bible translations for English and French.
