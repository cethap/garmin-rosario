# Rosary app

## Objective

A fast, retro-styled Connect IQ widget for the Garmin Instinct 2 that guides the full Rosary bead by bead, picks the mysteries of the day automatically, and is reachable in two presses from the watch face.

## Problem

The user's current rosary app is slow and does not sync the mysteries with the current day. A rosary mode inside the watch face is impossible: watch faces do not accept user input and the LIGHT button belongs to the system (verified in the Connect IQ docs).

## Why

The user prays the Rosary daily with the watch and wants quick, low-friction navigation with tactile feedback.

## Scope

Authorized by the user ("dale, arranquemos con la app del rosario en su propio repo"; structure chosen: "Completo con Salve").

- Widget app with a glance in the Instinct 2 glance loop (DOWN from the watch face, then START).
- Sequence (72 beads): Credo, Padre Nuestro, 3 Avemarías, Gloria; then 5 mysteries × (Padre Nuestro, 10 Avemarías, Gloria, Oh Jesús mío); then Salve.
- Mysteries by weekday: Monday/Saturday Gozosos, Tuesday/Friday Dolorosos, Wednesday/Sunday Gloriosos, Thursday Luminosos.
- Buttons: START or DOWN next bead, UP previous bead, BACK exit (progress saved for the day).
- Vibration: short pulse on each bead. When the 10 Avemarías of a decade end and the Gloria starts, a distinct multi-pulse pattern (3 pulses), so the user feels it without looking (user request). A long vibration at the end of the Rosary.
- Small time on screen; the 10 Avemarías of the current decade as a 10-segment ring in the subscreen.

Out of scope for the MVP: liturgical-season variants (Advent or Lent Sundays), full prayer texts, settings, other devices.

## Constraints

- Target: Instinct 2 (176x176 monochrome MIP, subscreen at x=113 y=0 62x62), Connect IQ 3.4.2. Memory limits: widget 64KB, glance 32KB.
- Spanish content (prayer and mystery names). Code, comments and docs in English.
- The pixel font from the watch face has no accented characters or ñ. Spanish text uses the system fonts, which include them.
- Conventional commits, no AI attribution. Push, GitHub repo creation and merges are the user's decisions.

## Delivery

- Strategy: `single-pr` (the user's preference for this owner's repos).
- Repo: local at `~/Documents/garmin-rosario`. The GitHub repo is not created yet; ask before creating it.

## Tasks

| ID | Task | Route | Status |
|----|------|-------|--------|
| R1 | `chore`: project skeleton (manifest as a widget for instinct2, jungle, Spanish strings, launcher icon, app class, empty view and glance) that builds with 0 warnings | delegated writer (2+ non-trivial new files; parent context past the backstop) | [ ] |
| R2 | `feat`: pure `Rosary` module: the 72-step sequence, mysteries by weekday with their Spanish names, step metadata (prayer, decade, bead), clamped next/prev, glance summary, with `(:test)` unit tests first (RED -> GREEN) | delegated writer | [ ] |
| R3 | `feat`: main view and delegate: small time, mystery title and name, current prayer, 10-bead ring in the subscreen, overall progress, buttons, vibration, per-day progress in Application.Storage | delegated writer | [ ] |
| R4 | `feat`: glance view ("Gozosos · 2/5" or "Sin empezar") | delegated writer | [ ] |
| R5 | `docs`: README with features, build, test and sideload steps | delegated writer | [ ] |

## Acceptance criteria

- `monkeyc -d instinct2` builds with 0 warnings. `monkeydo -t` passes every test.
- The sequence has 72 steps in the chosen order. The weekday mapping matches the scope.
- Next and prev never go out of range. Progress survives exiting and reopening the same day, and resets on a new day.
- The glance shows the day's mysteries and progress.

## Checks

- TDD for the pure `Rosary` module (RED observed before GREEN).
- Build with 0 warnings, unit tests in the simulator, a clean simulator runtime log.
- On-device check by the user after sideloading.

## Progress

- Repo initialized (`f2652af`), branch `feat/rosary-mvp`.

## Next step

R1-R5 via one bounded writer.
