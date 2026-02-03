# magisk-samsung-dex-standalone-mode

Magisk module to systemlessly enable Samsung DeX standalone mode by patching `floating_feature.xml`, it adds `standalone` value to `SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE` key.

✅ Enables DeX standalone mode on supported phones.

✅ Compatible with `magisk` and `kernelsu`.

[![Made with brain](https://img.shields.io/badge/Made%20with-brain%E2%84%A2-orange.svg?style=flat-square)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
[![GitHub Stars](https://img.shields.io/github/stars/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Stars)](#)
[![GitHub Forks](https://img.shields.io/github/forks/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Forks)](#)
[![GitHub Watchers](https://img.shields.io/github/watchers/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Watchers)](#)
[![GitHub repo size](https://img.shields.io/github/repo-size/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Repo%20Size)](#)
[![CI](https://img.shields.io/github/actions/workflow/status/supermarsx/magisk-samsung-dex-standalone-mode/ci.yml?style=flat-square&label=CI)](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/actions/workflows/ci.yml)
[![GitHub Downloads](https://img.shields.io/github/downloads/supermarsx/magisk-samsung-dex-standalone-mode/total.svg?style=flat-square&label=Downloads)](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Issues)](#)

[**[Download latest release]**](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/releases/latest/download/magisk-samsung-dex-standalone-mode.zip)

[[Download repository]](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Development](#development)
  - [Building](#building)
  - [Testing](#testing)
  - [Release Workflow](#release-workflow)
- [Changelog](#changelog)
- [License](#license)

## Requirements

- **Samsung One UI ROM** (stock or custom)
- **Root access** via Magisk or KernelSU
- **No conflicting modules** that modify `floating_feature.xml`

## Installation

### Via Magisk/KernelSU App

1. Download the [latest release](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/releases/latest/download/magisk-samsung-dex-standalone-mode.zip)
2. Open Magisk or KernelSU app
3. Go to Modules → Install from storage
4. Select the downloaded ZIP
5. Reboot

### Via Terminal

```bash
magisk --install-module path/to/magisk-samsung-dex-standalone-mode.zip
```

### Verify Installation

Check the patched value with root access:

```bash
su -c "cat /system/etc/floating_feature.xml | grep DEX_MODE"
```

## Troubleshooting

### Gesture Issues After Exiting DeX

See [Issue #2](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/2)

### DeX Ignoring the Notch / Desktop Not Full Width

See [Issue #3](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/3)

**Fix:** Change display cutout simulation to "Double cutout"  
*Thanks to [@admiralsym](https://github.com/admiralsym)*

1. Enable **Developer Options**: Settings → About phone → Software information → Tap "Build number" 7 times
2. Go to **Settings → Developer options**
3. Find **Simulate display with a cutout** → Select **Double cutout**

### ZIP Install Error

See [Issue #4](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/4)

**Fix:** Install manually via Termux  
*Thanks to [@hzykiss](https://github.com/hzykiss)*

```bash
su
magisk --install-module /path/to/module.zip
```

## FAQ

<details>
<summary><strong>Does this require a Samsung device?</strong></summary>

Yes. Specifically a Samsung device running One UI with DeX support.
</details>

<details>
<summary><strong>What does "standalone mode" mean?</strong></summary>

It allows starting DeX directly on your phone screen without connecting to an external display via HDMI or wireless.
</details>

<details>
<summary><strong>Can DeX be screen-shared to another Android device?</strong></summary>

Not with this module. That would require a different solution.
</details>

<details>
<summary><strong>Will this work on non-Samsung devices?</strong></summary>

No. This module is specifically for Samsung devices with DeX.
</details>

<details>
<summary><strong>Will this work on custom ROMs?</strong></summary>

Only if the custom ROM is One UI-based and includes DeX.
</details>

<details>
<summary><strong>Will this add DeX to my phone?</strong></summary>

No. This only enables standalone mode on phones that already have DeX.
</details>

<details>
<summary><strong>I have an S23 Ultra, does standalone work without this module?</strong></summary>

No. Standalone mode isn't enabled by default on any Samsung phone, regardless of how high-end it is.
</details>

*Thanks to [@WilsonBradley](https://github.com/WilsonBradley) and [@foxypiratecove37350](https://github.com/foxypiratecove37350) for their questions.*

## Development

### Prerequisites

- `bash` and `zip` in PATH
- Linux, WSL, or Git Bash on Windows

### Building

```bash
make build    # Create magisk-samsung-dex-standalone-mode.zip
make clean    # Remove generated ZIP
```

Or use the scripts directly:

```bash
bash build-tools/build-create-module.sh    # Create ZIP
bash build-tools/build-delete-module.sh    # Delete ZIP
```

The file list for the ZIP is defined in `build-tools/build-filelist.txt`.

### Testing

```bash
make test     # Run all tests
make lint     # Run shellcheck on all scripts
```

Tests run automatically in CI on every push.

### Debugging

A log file `post-fs-data.log` is generated on each boot at:
```
/data/adb/modules/samsung-dex-standalone-mode/post-fs-data.log
```

To unmount the patched file during development:

```bash
sh debug/debug-unmount.sh
```

### Release Workflow

Releases are automated via GitHub Actions when a tag is pushed.

#### Version Management Scripts

| Script | Purpose |
|--------|---------|
| `build-tools/set-version.sh` | Update version in `module.prop` and `update.json` |
| `build-tools/update-changelog.sh` | Prepend new entry to `changelog.md` |
| `build-tools/release.sh` | Full release: version, changelog, lint, test, package, tag, publish |
| `scripts/check-version.sh` | Verify `module.prop` and `update.json` are in sync |
| `scripts/build-and-commit.sh` | Auto-increment version, build, commit, and tag |

#### Release Commands

**Full release** (recommended):
```bash
VERSION=2026.2 VERSION_CODE=5 CHANGELOG_NOTES_FILE=notes.txt bash build-tools/release.sh
```

**Auto-increment release**:
```bash
bash scripts/build-and-commit.sh
```

**Manual version update**:
```bash
bash build-tools/set-version.sh 2026.2 5
bash build-tools/update-changelog.sh 2026.2 notes.txt
```

**Verify version sync**:
```bash
bash scripts/check-version.sh
```

## Changelog

### 2026.1
- Add support for older phones (S9, S10, Note 9) with "system-as-root" partition layout — *thanks to [@serifpersia](https://github.com/serifpersia)*
- Minor fixes

### 2025.1
- Add release automation scripts
- Resolve shellcheck warnings

### 2024.2
- Restructure build/debug scripts
- Fix module status bug (was appending to old statuses on reboot)

### 2024.1
- Initial release

## License

MIT License — see [license.md](license.md)

**No warranties whatsoever.**
