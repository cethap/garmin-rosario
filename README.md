# Rosario for Garmin Instinct 2

A fast Connect IQ widget that guides the Rosary bead by bead on the Garmin Instinct 2. It picks the mysteries of the day for you, and it is two presses away from the watch face. The text on the watch is in Spanish.

## Features

- **Full Rosary in 72 beads**: Credo, Padre Nuestro, 3 Avemarías and Gloria; then 5 mysteries, each with Padre Nuestro, 10 Avemarías, Gloria and Oh Jesús mío; then the Salve.
- **Mysteries of the day**: Gozosos on Monday and Saturday, Dolorosos on Tuesday and Friday, Gloriosos on Wednesday and Sunday, Luminosos on Thursday.
- **Screen**: a small clock (follows the 12/24-hour setting), the decade title ("1er Misterio Gozoso"), the mystery name, the current prayer in large type ("Avemaría 7"), and 7 progress boxes (opening, 5 mysteries, closing).
- **Subscreen ring**: 10 segments that fill as you pray the Avemarías of the decade, with the current Avemaría number in the center.
- **Vibration**: a soft, short tap (100 ms) on each bead. When the Avemarías end and a Gloria starts (after the 3 of the opening and after the 10 of each mystery), three strong pulses (350 ms each, 200 ms apart, about 1.5 s in total), so you can tell it from a bead without looking. One long pulse (1 s) when you pray the Salve: press START or DOWN on the Salve to finish the Rosary.
- **Progress saved for the day**: leave and come back and you continue where you were. A new day starts from the beginning.
- **Menu**: hold UP on the main screen to open the app's own menu, drawn in large type in the retro black-and-white style (the system menu's text was too small). The current mystery's title stays at the top left, beside the subscreen, with its number in the subscreen, as in the reading view. Below the subscreen, two options; the selected one is a white bar with black text:
  - **Leer misterio**: read about the current mystery. During the opening it shows the 1st mystery, the one coming next; during a decade, that decade's mystery; on the Salve and once the Rosary is done, the 5th.
  - **Reiniciar**: start over after the confirmation "¿Reiniciar el rosario?". YES clears today's progress (the glance reads "Sin empezar" again) and goes back to the Credo with one short pulse; NO changes nothing.
- **Reading view**: the mystery's title stays at the top left, beside the subscreen, and its number shows in the subscreen. Below the subscreen, the mystery's name, a short Bible quote and its reference ("Lc 1, 28") scroll in a fixed window, so no text ever runs under the subscreen ring. Every quote reads in three screens at most. Reading changes nothing: no vibration, and the progress and the current bead stay as they were.
- **Bible quotes**: copied word for word, in each language from its own Catholic Bible:
  - English: the Douay-Rheims Bible, Challoner revision (public domain), from https://www.drbo.org/. References follow its numbering, which is the Vulgate's in places (the voice from the cloud at the Transfiguration is Mark 9:6).
  - Spanish: "La Biblia – El Libro del Pueblo de Dios" on the Holy See's site (https://www.vatican.va/archive/ESL0506/_INDEX.HTM).
  - French: "La Sainte Bible" translated by Augustin Crampon, 1923 edition (public domain), from French Wikisource (https://fr.wikisource.org/wiki/Bible_Crampon_1923), with its no-break spaces inside « » and before : ; ? !. Mark 9 follows the Vulgate's numbering there too (Mc 9, 6).

  A "…" marks a quote that starts or ends inside a sentence. The quotes live in `quotes.xml` under each language's strings (`resources/strings` for English, `resources-spa/strings` for Spanish, `resources-fre/strings` for French), and only the one being read is loaded.
- **Glance**: the day's mysteries right above today's progress, as one block ("Gozosos" over "Sin empezar", "En progreso", "Misterio 2/5", "Salve" or "Completado"). "En progreso" covers the opening (Credo to the first Gloria); "Completado" appears once the Salve is prayed. The system's rosary icon stays in the subscreen next to it.

## Controls

| Button | Action |
|--------|--------|
| START or DOWN | Next bead (on the Salve: finish the Rosary) |
| UP | Previous bead |
| Hold UP (MENU) | Menu: "Leer misterio" or "Reiniciar" (start today's Rosary over, after a YES/NO confirmation) |
| BACK | Exit (progress is already saved) |

In the menu:

| Button | Action |
|--------|--------|
| DOWN | Select the option below (does nothing on "Reiniciar") |
| UP | Select the option above (does nothing on "Leer misterio") |
| START | Open the selected option |
| BACK | Back to the Rosary, on the same bead |

From "Leer misterio" or the "Reiniciar" confirmation, BACK also returns to the Rosary.

In the reading view:

| Button | Action |
|--------|--------|
| DOWN | Scroll down one screen (does nothing on the last one) |
| UP | Scroll up one screen (does nothing on the first one) |
| BACK | Back to the Rosary, on the same bead |

From the watch face, press DOWN to reach the Rosario glance, then START to open it.

## Device Support

- Garmin Instinct 2 (Connect IQ widget with a glance)

## Development

This project is built with the Garmin Connect IQ SDK (API level 3.4.0 or later). The SDK tools need a Java 17+ runtime.

### Build

```sh
monkeyc -f monkey.jungle -d instinct2 -o bin/Rosario.prg -y /path/to/developer_key -w
```

### Unit Tests

The rosary logic in `source/Rosary.mc` is pure and covered by Run No Evil tests in `source/RosaryTests.mc`. `source/LayoutTests.mc` measures every text the glance, the main screen, the menu and the reading view draw with the real fonts and checks it against the visible area of the Instinct 2, the same per-row limits the watch face was calibrated with (`source/VisibleArea.mc`). Tests are excluded from regular builds.

The tests run once per language, each suite against that language's own strings:

```sh
connectiq &
DEVELOPER_KEY=/path/to/developer_key.der scripts/test-all.sh
```

The script prints one line per language, `PASSED` or `FAILED` with the simulator's counts (and the log's path when it fails), and exits with 0 only when every suite passes. Pass languages to run only those (`scripts/test-all.sh spa`). It needs Java 17 or later on the `PATH`; it finds the SDK chosen in the SDK Manager, or set `CIQ_SDK`. Builds and logs go to `bin/test` (`TEST_OUT`).

How it works: the simulator runs in English and cannot switch its language from the command line, so each `test-<lang>.jungle` puts that language's strings over the base ones. Tests that pin a text word for word live in `source/Pins<Lang>.mc`, annotated with their language, and each suite leaves out the other languages' pins. Every build uses `-w`, and a warning fails the suite, because a string a translation leaves out shows up as one. A run that hangs is stopped after `TEST_TIMEOUT` seconds (default 180), with the client it started, and tried once more.

Before the builds, the script runs `scripts/check-glance-strings.py`. The glance can load only the strings marked `scope="glance"` and the code annotated `(:glance)`; anything else crashes it on the watch, while the compiler does not warn and the tests, which run as the full app, pass. The check fails when glance code looks up a string that is not glance-scoped in every language, calls code outside the glance (such as `source/RosaryLabels.mc`), or when a glance-scoped string goes unused.

### Run in the Simulator

```sh
connectiq &
monkeydo bin/Rosario.prg instinct2
```

The simulator shows the glance first. Press START in the simulator to open the full screen.

### Sideload to the Watch

1. Build `bin/Rosario.prg` as shown above.
2. Connect the watch to the computer with the USB cable.
3. Copy `Rosario.prg` into the `GARMIN/APPS/` folder on the watch.
4. Unplug the watch. Rosario appears in the glance loop.

## Project Layout

| Path | Purpose |
|------|---------|
| `source/Rosary.mc` | Pure rosary logic: sequence, mysteries, labels, vibration, saved progress |
| `source/RosaryTests.mc` | Unit tests for `Rosary` and the buttons |
| `source/Layout.mc` | Text layout of the glance, shared with the tests |
| `source/LayoutTests.mc` | Layout tests for the glance, the main screen, the menu and the reading view |
| `source/VisibleArea.mc` | Test-only visible area of the Instinct 2, per screen row |
| `source/RosaryView.mc` | Main screen and its layout |
| `source/RosaryDelegate.mc` | Buttons, vibration, saving and starting over |
| `source/RosaryMenuView.mc` | Menu on hold UP ("Leer misterio" and "Reiniciar") and its layout |
| `source/RosaryMenuDelegate.mc` | Buttons of the menu: move, open and back |
| `source/ResetDelegate.mc` | Answer to the start-over confirmation |
| `source/MysteryView.mc` | Reading view of the current mystery, its layout and the quote loader |
| `source/MysteryDelegate.mc` | Buttons of the reading view: scroll and back |
| `resources/strings/quotes.xml` | The 20 Bible quotes and their references |
| `source/RosaryGlanceView.mc` | Glance |
| `source/RosarioApp.mc` | App entry point and saved progress |
