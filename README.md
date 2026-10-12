# Rosario for Garmin Instinct 2

A fast Connect IQ widget that guides the Rosary bead by bead on the Garmin Instinct 2. It picks the mysteries of the day for you, and it is two presses away from the watch face. The text on the watch is in Spanish.

## Features

- **Full Rosary in 72 beads**: Credo, Padre Nuestro, 3 Avemarías and Gloria; then 5 mysteries, each with Padre Nuestro, 10 Avemarías, Gloria and Oh Jesús mío; then the Salve.
- **Mysteries of the day**: Gozosos on Monday and Saturday, Dolorosos on Tuesday and Friday, Gloriosos on Wednesday and Sunday, Luminosos on Thursday.
- **Screen**: a small clock (follows the 12/24-hour setting), the decade title ("1er Misterio Gozoso"), the mystery name, the current prayer in large type ("Avemaría 7"), and 7 progress boxes (opening, 5 mysteries, closing).
- **Subscreen ring**: 10 segments that fill as you pray the Avemarías of the decade, with the current Avemaría number in the center.
- **Vibration**: a short pulse on each bead. Three pulses when the 10 Avemarías end and the Gloria starts, so you can feel it without looking. A long pulse at the final Salve.
- **Progress saved for the day**: leave and come back and you continue where you were. A new day starts from the beginning.
- **Glance**: the day's mysteries and today's progress ("Rosario · Gozosos" over "Misterio 2/5", "Sin empezar" or "Completado").

## Controls

| Button | Action |
|--------|--------|
| START or DOWN | Next bead |
| UP | Previous bead |
| BACK | Exit (progress is already saved) |

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

The rosary logic in `source/Rosary.mc` is pure and covered by Run No Evil tests in `source/RosaryTests.mc`. Tests are excluded from regular builds.

```sh
monkeyc -f monkey.jungle -d instinct2 -o bin/RosarioTest.prg -y /path/to/developer_key -w -t
connectiq &
monkeydo bin/RosarioTest.prg instinct2 -t
```

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
| `source/RosaryTests.mc` | Unit tests for `Rosary` |
| `source/RosaryView.mc` | Main screen layout |
| `source/RosaryDelegate.mc` | Buttons, vibration and saving |
| `source/RosaryGlanceView.mc` | Glance |
| `source/RosarioApp.mc` | App entry point and saved progress |
