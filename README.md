# <img align="center" src="https://play-lh.googleusercontent.com/6M5GsRSPP-TKbwZDoIUGn_9-mYiTtesXjoy5MMWeXGqHBuZZfZQeftOM2EitzIMfQA=w240-h480-rw" height="40" /> NMEA over IP

_Sends NMEA 0183 sentences from your Android phone over UDP / Multicast — for OpenCPN, AvNav, NKE, Expedition and any NMEA listener._

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![Platform Android](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)](https://play.google.com/store/apps/details?id=com.kikimanjaro.nmea_to_network)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GooglePlay](https://img.shields.io/endpoint?color=green&logo=google-play&logoColor=green&url=https%3A%2F%2Fplayshields.herokuapp.com%2Fplay%3Fi%3Dcom.kikimanjaro.nmea_to_network%26l%3DDownloads%26m%3D)](https://play.google.com/store/apps/details?id=com.kikimanjaro.nmea_to_network)
[![Rating](https://img.shields.io/endpoint?color=green&logo=google-play&logoColor=green&url=https%3A%2F%2Fplayshields.herokuapp.com%2Fplay%3Fi%3Dcom.kikimanjaro.nmea_to_network%26l%3DRating%26m%3D)](https://play.google.com/store/apps/details?id=com.kikimanjaro.nmea_to_network)

<p align="center">
<img src="https://play-lh.googleusercontent.com/XFUDt19MHzBcCVMbtAWi6IvkwLS9Z-sU4MQF3zTDPCwVQ1_kGTbCQiydBWlBfMprnqg=w2560-h1440-rw" height="400" /> <img src="https://play-lh.googleusercontent.com/5l9ofEBQcz7s-6A_EEGG3Q2XELl7Nb9skgEqDkvYyDVuArpqcoAuxfrymXmwWoY9tXE=w2560-h1440-rw" height="400" /> <img src="https://play-lh.googleusercontent.com/AbsE-h95R822AvEafM1XvzgpB4yX3PsMk7etbt5PRl4YwdtbXTtctm91FMpy6C3Powk=w2560-h1440-rw" height="400" />
</p>

## Table of Contents

- [What it does](#what-it-does)
- [Features](#features)
- [Screenshots](#screenshots)
- [How it works](#how-it-works)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [NMEA output](#nmea-output)
- [Configuration](#configuration)
- [Project structure](#project-structure)
- [Development](#development)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## What it does

**NMEA over IP** turns your Android phone into a wireless NMEA 0183 GPS source. It reads the phone's GNSS position, formats it as NMEA sentences (e.g. `$GPGGA`, `$GPRMC`), and forwards them in real time over your local network via **UDP unicast** (and Multicast) — so chart plotters, laptops and instruments on the same Wi-Fi can consume your phone's GPS without cables.

Typical use: phone in the cockpit → boat Wi-Fi → OpenCPN / AvNav on a tablet or Raspberry Pi.

## Features

- 📡 Real-time NMEA 0183 forwarding over UDP / Multicast
- 🛰 Live position dashboard (lat/lon, heading, altitude, speed, accuracy)
- 🗺 Map view with current fix and auto-centre
- 🔍 Automatic LAN scan — discovers all hosts on your subnet for one-tap targeting
- 📜 On-device NMEA log (last 200 sentences, live view)
- ⚙️ Multiple UDP targets (add / remove destinations, persisted with SharedPreferences)
- 🔌 USB serial support stub (for external GNSS pucks)
- 🎨 Simple 3-tab UI: Map · Info · Configuration

## Screenshots

| Map | Info / NMEA log | Configuration |
|-----|-----------------|---------------|
| ![Map](https://play-lh.googleusercontent.com/XFUDt19MHzBcCVMbtAWi6IvkwLS9Z-sU4MQF3zTDPCwVQ1_kGTbCQiydBWlBfMprnqg=w2560-h1440-rw) | ![Info](https://play-lh.googleusercontent.com/5l9ofEBQcz7s-6A_EEGG3Q2XELl7Nb9skgEqDkvYyDVuArpqcoAuxfrymXmwWoY9tXE=w2560-h1440-rw) | ![Conf](https://play-lh.googleusercontent.com/AbsE-h95R822AvEafM1XvzgpB4yX3PsMk7etbt5PRl4YwdtbXTtctm91FMpy6C3Powk=w2560-h1440-rw) |

Also on [Google Play](https://play.google.com/store/apps/details?id=com.kikimanjaro.nmea_to_network).

## How it works

```
Phone GNSS (FusedLocationProvider) → Position stream
        ↓
  NMEA formatter (GGA/RMC + checksum)
        ↓
  UDP sender (one socket, multiple targets)  ──→  192.168.x.y:30304 (OpenCPN, etc.)
        ↓                                      ──→  192.168.x.255:30304 (multicast)
  Live UI (Map + Info log)
```

* Permissions are requested at runtime; location service check first.
* LAN discovery uses `lan_scanner` (ICMP scan) + `network_info_plus` to find the Wi-Fi subnet.
* Destinations are persisted as JSON in `SharedPreferences` (`confList`).

## Requirements

- **Android 7.0+** (minSdk 24) — location + Wi-Fi
- **Flutter 3.10+ / Dart 3.0+** for building from source
- Location permission + Wi-Fi on the same LAN as your plotter/PC

## Installation

### From Google Play (recommended)

<a href="https://play.google.com/store/apps/details?id=com.kikimanjaro.nmea_to_network"><img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60"/></a>

### From source

```bash
git clone https://github.com/KikiManjaro/NMEAoverIP.git
cd NMEAoverIP

# Get dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Build a debug APK
flutter build apk --debug

# Build a release APK (needs android/key.properties if you sign)
flutter build apk --release
```

> **Note:** remove `android/key.properties` if you just want an unsigned debug build — the `release` signing config is optional.

## Usage

1. Connect phone and plotter/PC to the **same Wi-Fi** (or phone hotspot).
2. Open the app → grant **Location** permission.
3. Go to **Configuration** → tap **+** → pick a discovered device (or type IP/port manually).
   - Default port `30304` is conventional for NMEA over UDP; change if your plotter expects another port (e.g. OpenCPN default `10110`).
   - Add as many targets as you need — each sentence is sent to all of them.
4. Return to **Map** / **Info** — the NMEA log should start scrolling.
5. On your plotter: add a **Network → UDP** connection pointing at the same port (or listen on the phone's IP).

## NMEA output

Current formatter emits:

* `$GPGGA` — Global Positioning System Fix Data (time, lat/lon, fix quality, altitude)

Example:
```
$GPGGA,143022.00,4807.0380,N,01131.3240,E,1,08,0.9,545.4,M,0,M,,*6A
```

RMC generation is in the formatter for future use. The sentence carries a correct XOR checksum (`*HH`). Sentences are terminated and sent as raw ASCII over UDP.

## Configuration

Destinations are stored locally; no cloud, no account. To reset:

* Remove entries in **Configuration** (trash icon), or clear app data in Android Settings.

Network scan runs automatically on launch (background) and on the **Adding Configuration** screen. If discovery finds nothing, type the target IP manually — discovery is convenience, not required.

## Project structure

```
lib/
  main.dart                # App entry, bottom nav (Map / Info / Configuration)
  nmea.dart                # Position → NMEA, UDP fan-out, state wiring
  ip.dart                  # UDP/Multicast sender, LAN scan, SharedPreferences
  map.dart                 # Map view (google maps tiles + marker)
  location_data.dart       # Info grid + NMEA log
  configuration.dart       # Destination list
  adding_configuration.dart# Add destination + device grid
  usb.dart                 # USB serial stub / MethodChannel
android/                   # Android embedding, permissions, signing
assets/icon/               # Launcher icon
```

## Development

```bash
flutter analyze          # lint
flutter test             # widget tests
flutter pub outdated     # check for updates
flutter pub upgrade --major-versions
```

* Code style: `flutter_lints` (see `analysis_options.yaml`).
* Useful docs: [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [CHANGELOG.md](CHANGELOG.md).

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Location services are disabled` | Enable **Location** in Android quick settings; set mode to *High accuracy*. |
| `Location permissions are denied` | App → Permissions → Location → **Allow all the time** / **Allow only while using**. |
| `No wifi network found` / empty device scan | Ensure Wi-Fi is connected (not mobile data); some hotspots block ICMP — type the IP manually. |
| Plotter receives nothing | Check firewall on the PC/plotter; verify IP+port; try `nc -lu 30304` / `socat UDP-LISTEN:30304,fork -` on the receiver. |
| Build error `NmeaMessage not found` / `altitudeAccuracy` | Update to latest `main` — fixed in [#3](https://github.com/KikiManjaro/NMEAoverIP/pull/3). Run `flutter clean && flutter pub get`. |
| `compileSdkVersion` / Kotlin errors | `flutter upgrade`, and ensure `android/app/build.gradle` is on `compileSdkVersion 34`. |

## Contributing

Contributions are very welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

Good first issues: better NMEA sentence coverage (RMC/VTG/GSA), TCP support, dark map style, background service notification, automated tests.

## License

MIT — see [LICENSE](LICENSE) (or the repository's default). Icons and screenshots remain property of their owners.

---

[![Buy Me a Coffee](https://img.buymeacoffee.com/api/?url=aHR0cHM6Ly9pbWcuYnV5bWVhY29mZmVlLmNvbS9hcGkvP3VybD1hSFIwY0hNNkx5OWpaRzR1WW5WNWJXVmhZMjltWm1WbExtTnZiUzkxY0d4dllXUnpMM0J5YjJacGJHVmZjR2xqZEhWeVpYTXZNakF5TVM4d015ODBZekkwT0RnNE1XWmxOVE5pWmprM1lUa3pOV1kxWm1NNFlqRXpPV1EyTWk1d2JtYz0mc2l6ZT0zMDAmbmFtZT1raWtpbWFuamFybw==&creator=kikimanjaro&is_creating=creating%20mobile%20apps%20and%20plugins&design_code=1&design_color=%23ff813f&slug=kikimanjaro)](https://www.buymeacoffee.com/kikimanjaro)
