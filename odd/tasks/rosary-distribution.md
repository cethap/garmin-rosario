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
| D1 | `refactor(i18n)`: move every user-facing string to string resources (base English placeholders, Spanish in `resources-spa`), with glance-scoped strings where the glance needs them; behavior and Spanish output unchanged; tests stay green | delegated writer (2+ non-trivial files) | [ ] |
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

## Next step

D1 delegated. The user chooses the Bible translations for English and French.
