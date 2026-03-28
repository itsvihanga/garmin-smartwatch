# Release Notes — TestingCadence (Garmin Connect IQ Watch App)

**App Name**: TestingCadence  
**Compatible Devices**: Garmin Forerunner 165 / 165 Music  
**App Type**: Watch App  
**Build Date**: 26 March 2026  
**PRG File**: `bin/app.prg` (153 KB)  
**Minimum API Level**: 5.2.0  

---

## v1.0.0 — Initial Release (26 March 2026)

### Overview

TestingCadence is a cadence-based running feedback app for the Garmin Forerunner 165 and 165 Music.  
It turns the watch's built-in cadence sensor into a real-time running coach — showing live metrics, visualising cadence consistency, and alerting you when you drift outside your ideal zone.

---

### What's Included

#### Core Cadence Monitoring
- **Real-time cadence feedback** — live steps-per-minute reading updated every second
- **Configurable cadence zone** — set your own minimum and maximum cadence via the on-watch settings menu
- **In-zone / Out-of-zone indicator** — clear visual label showing your current zone status
- **Zone colour coding** — text and indicators change to reflect whether you are within your target range

#### User Interface Views
- **Simple View** — clean display of cadence, heart rate, distance, elapsed time, and CQ score
- **Advanced View** — histogram bar chart visualising cadence history with configurable time windows (15 min, 30 min, 1 hr, 2 hr)
- **Summary View** — post-session overview of run metrics and final Cadence Quality score
- **Time View** — current time display

#### Cadence Quality (CQ) — Experimental Feature
- **Composite score (0–100)** evaluating cadence consistency over time
- **Two-component formula**:
  - Time-in-Zone (70% weight) — proportion of samples within the target cadence range
  - Cadence Smoothness (30% weight) — stability between consecutive cadence samples
- **Warm-up window** — CQ is withheld for the first ~30 seconds to avoid noisy early-run values; displayed as `CQ: --` during this phase
- **Frozen final score** — when cadence monitoring stops, the CQ score is locked and displayed as the session result
- **Confidence levels**: High / Medium / Low based on data completeness
- **Trend indicator**: Improving / Stable / Declining using a rolling window of recent CQ values

#### Haptic & Audible Feedback
- **Smart haptic alerts** — vibration when cadence drops below or rises above the target zone
- **Configurable alert intensity**: Low / Medium / High for both haptic and audible feedback
- **Alert interval** — repeated vibration pattern (double-pulse) when out-of-zone; no continuous vibration
- **Alert duration window** — alerts active for up to 3 minutes per out-of-zone event, at 30-second intervals

#### Profile & Personalisation (Settings)
- **Height** — used to calculate personalised cadence zones
- **Speed** — typical running speed in km/h
- **Experience level**: Beginner / Intermediate / Advanced
- **Gender**: Male / Female / Other
- Cadence zone is automatically calculated from profile, or can be overridden manually

#### Cadence Zone Manual Override
- **Set Min Cadence** — picker-based input for the lower cadence bound
- **Set Max Cadence** — picker-based input for the upper cadence bound
- **Reset Zones** — restores calculated defaults from your profile

#### Customisable Display Options
- Chart duration: 15 minutes, 30 minutes, 1 hour, or 2 hours
- Settings are persisted across sessions using on-device storage

#### Activity Recording
- **FIT file integration** — cadence session data (including the final CQ score) is written to a Garmin FIT activity file, making it visible in Garmin Connect after the run

---

### Platform & Permissions

| Permission | Purpose |
|---|---|
| `Fit` | Writing run data and CQ score to FIT activity file |
| `Sensor` / `SensorHistory` / `SensorLogging` | Reading live cadence and heart rate |
| `Positioning` | Distance and speed tracking |
| `Notifications` | On-watch alert delivery |
| `UserProfile` | Reading user profile for cadence zone calculation |
| `PersistedLocations` | Storing settings across sessions |

---

### Known Limitations & Notes

- **Developer/sideload build only** — this app is not published on the Garmin Connect IQ Store; it must be sideloaded via USB (see `INSTALLATION_GUIDE.md`)
- **Forerunner 165 / 165 Music only** — not tested on other devices
- **CQ is experimental** — weightings and thresholds are configurable and subject to change in future versions
- **No background execution** — cadence monitoring only runs when explicitly started by the user
- **Audible feedback** — intensity settings are present in the menu; hardware tone output depends on device capabilities
- **Hardcore Mode** was explored and abandoned — the feature required switching to an Activity App type which has broader system implications; it has been removed from this build

---

### Development Validation

| Test | Result |
|---|---|
| Timer accuracy (1-second tick) | Confirmed via simulator logs |
| Memory stress (200+ timer cycles) | Stable at ~5–6% heap usage; no leaks detected |
| Application lifecycle (start / pause / stop) | Confirmed clean shutdown, no residual timer activity |
| Cadence Quality warm-up phase | Correct `CQ: --` display during warm-up window |
| CQ score freeze on monitoring stop | Confirmed frozen final score behaviour |

---

### Credits

Concept by **Dr Jason Bonacci** and **Dr Joel Fuller**.  
Developed as a research-aligned running efficiency tool for rehabilitation and performance training.
