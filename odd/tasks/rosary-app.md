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
| R1 | `chore`: project skeleton (manifest as a widget for instinct2, jungle, Spanish strings, launcher icon, app class, empty view and glance) that builds with 0 warnings | delegated writer (2+ non-trivial new files; parent context past the backstop) | [x] 40dad91 (0 warnings) |
| R2 | `feat`: pure `Rosary` module: the 72-step sequence, mysteries by weekday with their Spanish names, step metadata (prayer, decade, bead), clamped next/prev, glance summary, with `(:test)` unit tests first (RED -> GREEN) | delegated writer | [x] a999c42 (RED: 177 undefined symbols -> GREEN 19/19) |
| R3 | `feat`: main view and delegate: small time, mystery title and name, current prayer, 10-bead ring in the subscreen, overall progress, buttons, vibration, per-day progress in Application.Storage | delegated writer | [x] 2b827da (RED formatClock/splitLines -> GREEN 22/22; harness rendered all 72 steps, 18.5KB, 3ms per render) |
| R4 | `feat`: glance view ("Gozosos · 2/5" or "Sin empezar") | delegated writer | [x] bec9a8d (glance 13.3KB of 28.5KB, reads Storage) |
| R5 | `docs`: README with features, build, test and sideload steps | delegated writer | [x] 45d8366 |
| R6 | `fix`: atomic per-day progress (one composite Storage value) with an encode/decode/restore round-trip test; glance labels for a started day reset to step 0 and for the Salve bead (review findings `R3-delegate-untested`, `R3-nonatomic-save`, `R3-glance-summary-edges`) | delegated writer, batched with the user's visual feedback | [x] 01ac3b3. RED at compile time (27 errors: `DONE`, `NOT_STARTED`, `PROGRESS_KEY`, `encodeProgress`, `decodeProgress`, `partsDone`, `loadProgress` undefined) -> GREEN 28/28; builds 0 warnings |
| R7a | `fix(glance)`: keep the glance text inside the visible area: `Layout.glancePlan` (pure) plus visible-area geometry, tests over every set name and progress label measured with a real Dc | delegated writer (2+ non-trivial files) | [x] 68744fb. RED: the pre-fix binary fails `glanceTextStaysInsideTheVisibleArea` and `glanceShowsTheDaySetAndProgress` (22 passed, 2 failed) -> GREEN 28/28; builds 0 warnings |
| R7b | `fix(view)`: prove every main-screen text fits for all 72 steps (and every clock time), fix what does not | delegated writer (2+ non-trivial files) | [x] 8f808e3. RED: the pre-fix binary fails `mainScreenTextStaysInsideTheVisibleArea` and `mainScreenClockStaysInsideTheVisibleArea` (24 passed, 2 failed) -> GREEN 28/28; builds 0 warnings |

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

- Writer deviations (accepted): the glance reads "Rosario · <set>" over "Sin empezar" / "Inicio" / "Misterio n/5" / "Completado"; the ring fill includes the current Avemaría; wrapped text is cached per step (fitTextToArea for ~20 screens in one onUpdate tripped the watchdog); progress keeps the date the screen was opened, so a rosary prayed across midnight keeps that day's mysteries; added `formatClock` and `splitLines` with tests. App UUID `88956777-ab95-491a-a90a-85aedd95a9c1`.
- Review over `f2652af..445b0b3`: **approved**, acknowledged. Advisory findings queued as R6.
- Parent spot check: app build 0 warnings; `monkeydo -t` PASSED 22/22; clean runtime log. The simulator opens the widget in glance mode; START opens the main view.
- User feedback in the simulator (triggered R7): in the selected glance slot the title "Rosario · Gozosos" ran under the subscreen and read "Rosario · Goz"; in a lower slot of the glance loop the round edge cut the "R".
- Visible area, measured from the SDK's simulator image of the watch (`Devices/instinct2/instinct2.png`, screen at 99,164): the 176x176 screen clipped by a disk of radius 98 around (88,88), and the subscreen lens: window radius 31 around (144,31) plus an opaque ring out to radius 44. The ring explains "Rosario · Goz" (the text is hidden from x of about 100, not 113). The inscribed circle (radius 88) is used for the glance only: under it the main screen cannot fit its clock, title and progress boxes without a redesign. Fonts measured with a real Dc in tests (`new Graphics.BufferedBitmap(...).getDc()` works): tiny 23px (Gozosos 62, Dolorosos 73, Gloriosos 70, Luminosos 79, "Sin empezar" 90, "Misterio 2/5" 90, "Completado" 87), pixel clock 60x12, large 31px ("Padre Nuestro" 130), number mild 35px.
- R7a: the glance shows the set name ("Gozosos") over the progress, both tiny, indent 7, bottom-aligned (dc y 22 and 39). By the measured widths every label keeps the 2px margin inside the inscribed circle and clear of the subscreen ring (the tightest, "Luminosos", has under 1px to spare beyond it); the test run that confirms it is pending.
- R7b: clock 2px lower; the title wraps at 76px in up to 3 lines ("1er" / "Misterio" / "Gozoso", center y 48); mystery center y 101, prayer top 123 (top-aligned), progress boxes y 160. The blocks stack without overlapping. The Avemaría number keeps VCENTER on the subscreen center; whether the digits look optically centered cannot be checked without pixel access (no Dc pixel reads, no screen capture permission here).
- R6: progress is one value `"progress" = [YYYYMMDD, position]`; positions add `DONE` (72) past the Salve. START/DOWN on the Salve prays it (long vibration once, `DONE` saved); arriving at the Salve is a short pulse. Glance: "Sin empezar" (nothing saved today), "Inicio" (also a day moved back to the Credo), "Salve" until prayed, "Completado" at `DONE`. The old `step`/`date` keys are no longer read.
- Blocked check: the simulator stopped answering `monkeydo` during R7a (connection accepted, 0% CPU, no output, also for HEAD's own tests); restarting it was not permitted in the writer session. RED and GREEN test binaries for each task were archived in the scratch build folder.
- Resolved: the user restarted the simulator. Parent run: `monkeydo RosarioTest.prg instinct2 -t` PASSED 28/28; the archived R7a and R7b RED binaries fail exactly their new layout tests; release build 0 warnings, relaunched in the simulator.

## Next step

The user checks the glance and the main view in the simulator and on the watch.
