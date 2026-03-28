x# Installation Guide — TestingCadence (Garmin Forerunner 165 / 165 Music)

This guide covers two topics:

1. [How to build the `.prg` file from source](#part-1-building-the-prg-file)
2. [How to install the `.prg` file onto your Garmin watch](#part-2-installing-the-prg-file-sideloading)

---

## Part 1: Building the .prg File

> **Skip this section if you already have `bin/app.prg`** — a pre-built binary is included in the repository.

### Prerequisites

| Requirement | Details |
|---|---|
| Garmin Connect IQ SDK | Version 8.3.0 or later — [download here](https://developer.garmin.com/connect-iq/sdk/) |
| VS Code + Connect IQ Extension | Recommended for development; extension available in the VS Code marketplace |
| Developer Key (`.der` file) | Generated once per machine; required to sign the `.prg` |
| Device / Simulator | Garmin Forerunner 165 or the fr165 simulator target in the SDK |

---

### Step 1: Generate a Developer Key

You only need to do this once. Your developer key signs the `.prg` file so it can be loaded onto your watch.

**In VS Code:**
1. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Run: `Monkey C: Generate Developer Key`
3. Save the resulting `.der` file somewhere safe (e.g. adjacent to the project or in a dedicated `keys/` folder)

**Via command line:**
```bash
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

> ⚠️ Keep your `.der` file private. Do **not** commit it to source control.

---

### Step 2: Build the Project

**Option A — VS Code (recommended):**
1. Open the `w:\Github\garmin-smartwatch` folder in VS Code
2. Open the Command Palette and run: `Monkey C: Build for Device`
3. Select **fr165** (Forerunner 165) or **fr165m** (Forerunner 165 Music) as the target
4. The output file will be placed at `bin/app.prg`

**Option B — Command line:**
```bash
cd w:\Github\garmin-smartwatch
monkeyc -o bin/app.prg -f monkey.jungle -y path\to\developer_key.der -w
```

Replace `path\to\developer_key.der` with the actual path to your key file.

**Flags explained:**
- `-o bin/app.prg` — output file location
- `-f monkey.jungle` — project configuration file
- `-y developer_key.der` — signs the build with your developer key
- `-w` — enables compiler warnings

---

### Step 3: Test in the Simulator (Optional but Recommended)

Before copying to the physical watch, you can run the app in the Garmin simulator:

```bash
monkeydo bin/app.prg fr165
```

The simulator opens a virtual Forerunner 165 and allows you to test the UI, cadence monitoring logic, and settings menus without touching the physical device.

---

## Part 2: Installing the .prg File (Sideloading)

Sideloading lets you install a development `.prg` directly onto your Garmin watch over USB — no Garmin Connect IQ Store required.

### What You Need

- `bin/app.prg` (pre-built or built by you in Part 1)
- Garmin Forerunner 165 or 165 Music
- USB charging/data cable (**must be a data cable**, not charge-only)
- Windows, macOS, or Linux computer

---

### Step 1: Connect the Watch

1. Connect your Forerunner 165 to your computer using the USB cable
2. The watch should mount as a removable drive:
   - **Windows**: Appears in File Explorer, typically as `D:\`, `E:\`, or `F:\` labelled `GARMIN`
   - **macOS**: Appears in Finder under Locations as `GARMIN`
   - **Linux**: Automounts at `/media/<username>/GARMIN/`

**Troubleshooting:**
- The cable must support data transfer — many charging-only cables will not mount the watch as a drive
- Try a different USB port if the watch does not appear
- Restart the watch if it does not mount after 30 seconds

---

### Step 2: Navigate to the APPS Folder

Open the mounted drive and navigate to:

| OS | Path |
|---|---|
| Windows | `E:\GARMIN\APPS\` *(drive letter may vary)* |
| macOS | `/Volumes/GARMIN/GARMIN/APPS/` |
| Linux | `/media/<username>/GARMIN/GARMIN/APPS/` |

> If the `APPS` folder does not exist, create it manually inside the `GARMIN` folder.

---

### Step 3: Copy the .prg File

1. Locate `bin/app.prg` in your project folder:
   ```
   w:\Github\garmin-smartwatch\bin\app.prg
   ```
2. Copy (do **not** move) the file into the `APPS` folder on the watch
3. Optionally rename it for clarity:
   ```
   CadenceMonitor.prg
   CadenceMonitor_v1.0.prg
   ```
   Use descriptive names with no spaces.

---

### Step 4: Safely Eject the Watch

**Always safely eject before unplugging** to prevent file corruption.

| OS | How to eject |
|---|---|
| Windows | Right-click the GARMIN drive in File Explorer → **Eject** → wait for "Safe to Remove Hardware" |
| macOS | Click the eject icon next to GARMIN in Finder, or drag to Trash → wait until it disappears |
| Linux | Right-click → Unmount/Eject in file manager, or run `umount /media/<username>/GARMIN` in terminal |

Disconnect the USB cable after ejecting.

---

### Step 5: Launch the App on the Watch

1. On the watch, press the **Up** button to open the app list
2. Scroll to find **TestingCadence** (or whatever name you gave the `.prg`)
   - Sideloaded apps appear with a **wrench icon** 🔧
3. Press **Start** to launch



---

## Using the App

### First Run — Configure Your Profile

On first launch, open the settings menu (press the **Menu button** during the main screen):

1. **Set Profile** → enter your height, typical speed, experience level, and gender  
   The app uses these to calculate your ideal cadence zone automatically

2. **Cadence Range** → optionally override min/max cadence manually

3. **Feedback Options** → set haptic and/or audible alert intensity (Low / Medium / High)

4. **Customisable Options** → set the histogram chart duration (15 min, 30 min, 1 hr, 2 hr)

### Starting a Cadence Session

1. From the main screen, press **Start** to begin cadence monitoring
2. A recording indicator appears on screen when monitoring is active
3. The app begins collecting cadence data; CQ displays `--` during the warm-up window (~30 seconds)
4. Run as normal — alerts fire when cadence drifts outside your zone

### Stopping

1. Press **Stop** or the designated stop button to end the session
2. The final Cadence Quality (CQ) score is frozen and displayed
3. The session data (including CQ) is written to a FIT activity file and will sync to Garmin Connect

### Swipe Between Views

| View | Contents |
|---|---|
| Simple View | Cadence, heart rate, distance, time, in/out zone label, CQ score |
| Advanced View | Cadence histogram bar chart with colour-coded zone bands |
| Summary View | Post-session totals and frozen CQ score |
| Time View | Current clock display |

---

## Uninstalling the App

**Method A — Via the Watch:**
1. Navigate to the app in the app list
2. Hold the **Menu** button
3. Select **Remove** or **Delete**

**Method B — Via USB:**
1. Connect the watch via USB
2. Navigate to `GARMIN/APPS/`
3. Delete the `.prg` file
4. Safely eject

---

## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| App not visible after copying | File not properly ejected; transfer incomplete | Reconnect, verify the file is present and correct size, re-copy and eject properly |
| App crashes on launch | Code error, wrong device target, or memory issue | Test in simulator first: `monkeydo bin/app.prg fr165`; verify `monkey.jungle` targets `fr165` |
| "Invalid PRG file" error | File corrupted or wrong developer key | Rebuild with the correct `.der` key; regenerate key if needed |
| Watch shows empty APPS folder | Wrong path | Confirm the path is `GARMIN/APPS/`, not `APPS/` at the root; some devices use `PRIMARY/GARMIN/APPS/` |
| "App limit reached" | Too many sideloaded apps | Remove unused `.prg` files from `GARMIN/APPS/` |
| CQ shows `--` throughout run | Warm-up window not yet elapsed | Wait ~30 seconds from the start of monitoring; CQ only appears after enough samples are collected |
| No haptic alerts | Monitoring not started, or device in silent mode | Ensure monitoring is active (recording indicator visible); check watch vibration/silent settings |

---

## Build Output Reference

| File | Description |
|---|---|
| `bin/app.prg` | Compiled app binary — copy this to the watch |
| `bin/app.prg.debug.xml` | Debug symbol file — only needed for simulator debugging |
| `manifest.xml` | App metadata, target devices, and permissions |
| `monkey.jungle` | Project configuration and source paths |
