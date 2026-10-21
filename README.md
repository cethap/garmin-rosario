# Rosario for Garmin Instinct 2

Rosario is a Connect IQ widget that guides the full Catholic Rosary bead by bead on the Garmin Instinct 2. It picks the mysteries of the day and saves your place. A vibration tells you where you are, so you can pray without looking at the watch. It is two presses away from the watch face, and it reads in English, Spanish or French, following the watch's language.

[Resumen en español](#resumen-en-español) · [Résumé en français](#résumé-en-français)

## Quick start

1. Set `DEVELOPER_KEY` to your developer key's path and build the app (see [Build](#build)): `monkeyc -f monkey.jungle -d instinct2 -o bin/Rosario.prg -y "$DEVELOPER_KEY" -r -w`.
2. Copy `bin/Rosario.prg` to the `GARMIN/APPS/` folder on the watch (see [Sideload to the watch](#sideload-to-the-watch)).
3. On the watch face, press DOWN to reach the Rosario glance, then START to open it.

## Features

- **Full Rosary in 72 beads**: Apostles' Creed, Our Father, 3 Hail Marys and Glory Be; then 5 mysteries, each with Our Father, 10 Hail Marys, Glory Be and O My Jesus; then the Hail Holy Queen.
- **Mysteries of the day**: Joyful on Monday and Saturday, Sorrowful on Tuesday and Friday, Glorious on Wednesday and Sunday, Luminous on Thursday.
- **Main screen**: a small clock (it follows the 12/24-hour setting), the decade title ("1st Joyful Mystery"), the mystery name, the current prayer in large type ("Hail Mary 7"), and 7 progress boxes (opening, 5 mysteries, closing). A prayer name too wide for the large font, such as "Apostles' Creed", takes the largest font that holds it.
- **Subscreen ring**: 10 segments fill as you pray the Hail Marys of the decade, with the current Hail Mary's number in the center.
- **Vibration**:
  - each bead: a soft, short tap (100 ms);
  - each Glory Be, after the 3 Hail Marys of the opening and after the 10 of each mystery: three strong pulses (350 ms each, 200 ms apart, about 1.5 s in total), so you can tell it from a bead without looking;
  - the end: one long pulse (1 s) when you pray the Hail Holy Queen. Press START or DOWN on it to finish the Rosary.
- **Progress saved for the day**: leave and come back, and you continue where you were. A new day starts from the beginning.
- **Menu**: hold UP on the main screen to open the app's own menu, drawn in large type in a black-and-white retro style (the system menu's text is too small). The current mystery's title stays at the top left, beside the subscreen, with its number in the subscreen. The selected option is a white bar with black text:
  - **Read mystery**: read about the current mystery. During the opening it shows the 1st mystery, the one coming next; during a decade, that decade's mystery; on the Hail Holy Queen and once the Rosary is done, the 5th.
  - **Restart**: start over after the confirmation "Restart the rosary?". YES clears today's progress (the glance reads "Not started" again) and goes back to the Apostles' Creed with one short pulse; NO changes nothing.
- **Reading view**: the mystery's name, a short Bible quote and its reference ("Lk 1:28") scroll in a fixed window below the subscreen, so no text runs under the subscreen ring. Every mystery reads in two or three screens. Reading changes nothing: no vibration, and the progress and the current bead stay as they were.
- **Glance**: the day's mysteries over today's progress, as one block: "Joyful" over "Not started", "In progress", "Mystery 2/5", "Hail Holy Queen" or "Completed". "In progress" covers the opening (Apostles' Creed to the first Glory Be); "Completed" appears once the Hail Holy Queen is prayed.

## Languages

The watch's language picks the app's language. English is the base: a watch set to any other language reads English.

| Language | Strings | Glance example | Main screen example |
|----------|---------|----------------|---------------------|
| English (base) | `resources/strings` | "Joyful" / "Not started" | "1st Joyful Mystery", "Hail Mary 7" |
| Spanish | `resources-spa/strings` | "Gozosos" / "Sin empezar" | "1er Misterio Gozoso", "Avemaría 7" |
| French | `resources-fre/strings` | "Joyeux" / "Non commencé" | "1er mystère joyeux", "Je vous salue Marie" |

The app is named "Rosario" in every language. In French, the main screen shows "Je vous salue Marie" without its number, because "Je vous salue Marie 7" fits no font on that line; the subscreen ring shows the number, as in every language.

## Controls

The buttons are named as Connect IQ names them, with their place on the watch.

On the main screen:

| Button | Action |
|--------|--------|
| START (upper right) or DOWN (lower left) | Next bead (on the Hail Holy Queen: finish the Rosary) |
| UP (middle left) | Previous bead |
| Hold UP (MENU) | Menu: "Read mystery" or "Restart" (start today's Rosary over, after a YES/NO confirmation) |
| BACK (lower right) | Exit (progress is already saved) |

In the menu:

| Button | Action |
|--------|--------|
| DOWN | Select the option below (does nothing on "Restart") |
| UP | Select the option above (does nothing on "Read mystery") |
| START | Open the selected option |
| BACK | Back to the Rosary, on the same bead |

From "Read mystery" or the "Restart" confirmation, BACK also returns to the Rosary.

In the reading view:

| Button | Action |
|--------|--------|
| DOWN | Scroll down one screen (does nothing on the last one) |
| UP | Scroll up one screen (does nothing on the first one) |
| BACK | Back to the Rosary, on the same bead |

## Device support

- Garmin Instinct 2, Connect IQ product `instinct2`, which the SDK names "Instinct® 2 / Solar / Dual Power / dēzl Edition".
- The app needs Connect IQ API level 3.4.0 (`minApiLevel` in `manifest.xml`). The SDK lists two part numbers for the product: 006-B3888-00 (Connect IQ 3.4.2) is supported; 006-B4071-00 (Connect IQ 3.2.7) is left out of the store package. See [docs/RELEASE.md](docs/RELEASE.md).
- The app declares no permissions. It needs no phone, no internet connection and no sensors.

## Development

### Requirements

| Need | Notes |
|------|-------|
| Connect IQ SDK | API level 3.4.0 or later, with the Instinct 2 device installed from the SDK Manager |
| Java 17 or later | On the `PATH`; the SDK tools need it |
| A developer key | An RSA 4096 key in DER format. Any key works for builds and tests; a store release needs your persistent key ([docs/RELEASE.md](docs/RELEASE.md) shows how to create one) |
| `perl` and `python3` | For `scripts/test-all.sh` |

The commands below read the key's path from the `DEVELOPER_KEY` environment variable:

```sh
export DEVELOPER_KEY=/path/to/developer_key.der
```

### Build

```sh
monkeyc -f monkey.jungle -d instinct2 -o bin/Rosario.prg -y "$DEVELOPER_KEY" -r -w
```

`-r` strips the debug information and `-w` shows compiler warnings. The build should report none: a string that a translation leaves out shows up as a warning ("String id 'X' undefined for language 'spa'").

### Unit tests

The rosary logic in `source/Rosary.mc` is pure and covered by Run No Evil tests in `source/RosaryTests.mc`. `source/LayoutTests.mc` measures every text that the glance, the main screen, the menu and the reading view draw with the real fonts, and checks it against the visible area of the Instinct 2 (`source/VisibleArea.mc`). Tests are left out of regular builds.

The tests run once per language, each suite against that language's own strings:

```sh
connectiq &
DEVELOPER_KEY=/path/to/developer_key.der scripts/test-all.sh
```

The script prints one line per language, `PASSED` or `FAILED` with the simulator's counts (and the log's path when it fails). It exits with 0 only when every suite passes. Pass languages to run only those (`scripts/test-all.sh spa`).

| Variable | Meaning | Default |
|----------|---------|---------|
| `DEVELOPER_KEY` | Key that signs the test builds (required) | None |
| `CIQ_SDK` | SDK folder | The SDK chosen in the SDK Manager |
| `TEST_OUT` | Folder for the builds and logs | `bin/test` |
| `TEST_TIMEOUT` | Seconds before a run counts as hung | `180` |

Each suite has its own jungle file:

| Jungle | Builds |
|--------|--------|
| `monkey.jungle` | The app; a plain test build (`-t`) is the English suite |
| `test-eng.jungle` | The English suite, with the English pins (`:eng`) |
| `test-spa.jungle` | The Spanish strings over the base ones, with the Spanish pins (`:spa`) |
| `test-fre.jungle` | The French strings over the base ones, with the French pins (`:fre`) |

How it works:

- The simulator runs in English and cannot switch its language from the command line, so each `test-<lang>.jungle` puts that language's strings over the base ones.
- Tests that pin a text word for word live in `source/Pins<Lang>.mc`, annotated with their language; each suite leaves out the other languages' pins. Their shared checks are in `source/TextPins.mc`.
- Every build uses `-w`, and a warning fails the suite, because a missing translation shows up as one.
- A run that hangs is stopped after `TEST_TIMEOUT` seconds, together with the client it started, and tried once more.

Before the builds, the script runs `scripts/check-glance-strings.py`. The glance can load only the strings marked `scope="glance"` and the code annotated `(:glance)`; anything else crashes it on the watch, while the compiler does not warn and the tests, which run as the full app, pass. The check fails when glance code looks up a string that is not glance-scoped in every language, calls code outside the glance (such as `source/RosaryLabels.mc`), or when a glance-scoped string goes unused.

### Run in the simulator

```sh
connectiq &
monkeydo bin/Rosario.prg instinct2
```

The simulator shows the glance first. Press START in the simulator to open the full screen. To see another language, change it in the simulator's Settings > Language menu.

### Sideload to the watch

1. Build `bin/Rosario.prg` as shown in [Build](#build).
2. Connect the watch to the computer with its USB cable.
3. Copy `Rosario.prg` into the `GARMIN/APPS/` folder on the watch.
4. Unplug the watch. Rosario appears in the glance loop.

A sideloaded app runs at the developer trust level; the Connect IQ Store signs its own copy instead.

### Release

[docs/RELEASE.md](docs/RELEASE.md) has the steps to create the persistent developer key, export the `.iq` package and submit it. The store texts are in [store/](store/), one file per language.

## Project layout

App code:

| Path | Purpose |
|------|---------|
| `source/RosarioApp.mc` | App entry point and saved progress; annotated for the glance |
| `source/Rosary.mc` | Pure rosary logic: sequence, mysteries of the day, vibration, saved progress, the glance's texts |
| `source/RosaryLabels.mc` | Labels of the full-screen widget (prayers, titles, mystery names), kept out of the glance |
| `source/Layout.mc` | Text layout of the glance, shared with the tests |
| `source/RosaryGlanceView.mc` | Glance |
| `source/RosaryView.mc` | Main screen and its layout |
| `source/RosaryDelegate.mc` | Buttons of the main screen, vibration, saving |
| `source/RosaryMenuView.mc` | Menu on hold UP ("Read mystery" and "Restart") and its layout |
| `source/RosaryMenuDelegate.mc` | Buttons of the menu: move, open and back |
| `source/ResetDelegate.mc` | Answer to the "Restart the rosary?" confirmation |
| `source/MysteryView.mc` | Reading view of the current mystery, its layout and the quote loader |
| `source/MysteryDelegate.mc` | Buttons of the reading view: scroll and back |

Tests:

| Path | Purpose |
|------|---------|
| `source/RosaryTests.mc` | Unit tests for `Rosary` and the buttons |
| `source/LayoutTests.mc` | Layout tests for the glance, the main screen, the menu and the reading view |
| `source/VisibleArea.mc` | Test-only visible area of the Instinct 2, per screen row |
| `source/TextPins.mc` | Shared checks behind the tests that pin texts word for word |
| `source/PinsEng.mc`, `source/PinsSpa.mc`, `source/PinsFre.mc` | Each language's pinned texts |
| `test-eng.jungle`, `test-spa.jungle`, `test-fre.jungle` | Per-language test builds |
| `scripts/test-all.sh` | Builds and runs every language's suite |
| `scripts/check-glance-strings.py` | Checks that the glance loads only glance-scoped strings and glance code |

Resources:

| Path | Purpose |
|------|---------|
| `resources/strings/strings.xml` | English UI strings, the base for every language |
| `resources/strings/mysteries.xml` | The 20 mystery names in English |
| `resources/strings/quotes.xml` | The 20 English Bible quotes and their references |
| `resources-spa/strings/` | Spanish `strings.xml`, `mysteries.xml` and `quotes.xml` |
| `resources-fre/strings/` | French `strings.xml`, `mysteries.xml` and `quotes.xml` |
| `resources/drawables/` | Launcher icon (`launcher_icon.svg`, `drawables.xml`) |
| `resources/fonts/` | Pixel font for the clock (digits and the colon) |
| `resources/resources.xml` | Declares the pixel font |

Build, release and project files:

| Path | Purpose |
|------|---------|
| `manifest.xml` | App id, type (widget), device, minimum API level, languages, permissions (none) |
| `monkey.jungle` | Build file of the app |
| `docs/RELEASE.md` | Developer key, `.iq` export and store submission |
| `store/listing-eng.md`, `store/listing-spa.md`, `store/listing-fre.md` | Store texts, one per language |
| `README.md` | This file |
| `LICENSE` | MIT license for the code |
| `NOTICE` | Terms of the Bible quotes, which the MIT license does not cover |
| `.gitignore` | Keeps build output, packages and signing keys out of the repository |

## Bible text sources

Each language quotes its own Catholic Bible, copied word for word from the source below.

| Language | Translation | Source | Terms |
|----------|-------------|--------|-------|
| English | Douay-Rheims Bible, Challoner revision | https://www.drbo.org/ | Public domain |
| French | "La Sainte Bible", translated by Augustin Crampon, Desclée, 1923 edition | https://fr.wikisource.org/wiki/Bible_Crampon_1923 | Public domain |
| Spanish | "El Libro del Pueblo de Dios. La Biblia" (Traducción argentina), 1990 | https://www.vatican.va/archive/ESL0506/_INDEX.HTM | "Copyright © Libreria Editrice Vaticana", as the source page states. Used with attribution; all rights remain with the publisher |

The Bible quotes are not covered by the MIT license of the code; they keep their own terms (see [NOTICE](NOTICE)).

Notes on the quotes:

- A "…" marks a quote that starts or ends inside a sentence.
- References follow each source's numbering. The English and French sources follow the Vulgate in places: the voice from the cloud at the Transfiguration is Mark 9:6 there (Mc 9, 6), and Mc 9, 7 in the Spanish Bible.
- The French quotes keep the source's no-break spaces inside « » and before : ; ? !.
- The quotes live in `quotes.xml` under each language's strings, and the app loads only the one being read.

## License

The code is under the MIT license ([LICENSE](LICENSE)). The Bible quotes keep their own terms ([NOTICE](NOTICE)).

## Resumen en español

Rosario es un widget de Connect IQ que guía el Rosario completo, cuenta por cuenta, en el Garmin Instinct 2. Elige los misterios del día (Gozosos el lunes y el sábado, Dolorosos el martes y el viernes, Gloriosos el miércoles y el domingo, Luminosos el jueves) y guarda el progreso del día. Cada cuenta vibra con un toque suave y cada Gloria con tres pulsos fuertes, para rezar sin mirar el reloj. Desde la esfera del reloj, el botón DOWN muestra Rosario con los misterios del día y el progreso ("Gozosos" sobre "Misterio 2/5"), y START lo abre.

Botones: START o DOWN avanza a la cuenta siguiente y UP vuelve a la anterior. Al mantener pulsado UP se abre el menú, con "Leer misterio" (el nombre del misterio y una cita bíblica) y "Reiniciar". La aplicación se muestra en el idioma del reloj: español, inglés o francés. Las citas en español provienen de "El Libro del Pueblo de Dios", publicado en el sitio de la Santa Sede (Copyright © Libreria Editrice Vaticana).

## Résumé en français

Rosario est un widget Connect IQ qui guide le chapelet complet, grain par grain, sur la Garmin Instinct 2. Il choisit les mystères du jour (joyeux le lundi et le samedi, douloureux le mardi et le vendredi, glorieux le mercredi et le dimanche, lumineux le jeudi) et enregistre la progression du jour. Chaque grain vibre d'une touche légère et chaque Gloire au Père de trois impulsions fortes, pour prier sans regarder la montre. Depuis le cadran, le bouton DOWN affiche Rosario avec les mystères du jour et la progression (« Joyeux » au-dessus de « Mystère 2/5 »), et START l'ouvre.

Boutons : START ou DOWN passe au grain suivant et UP revient au précédent. Un appui long sur UP ouvre le menu, avec « Lire le mystère » (le nom du mystère et une citation biblique) et « Recommencer ». L'application suit la langue de la montre : français, anglais ou espagnol. Les citations en français viennent de la Bible Crampon (édition de 1923, domaine public), transcrite sur Wikisource.
