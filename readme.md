# magisk-samsung-dex-standalone-mode

Magisk module to systemlessly enable Samsung DeX standalone mode by patching `floating_feature.xml`, it adds `standalone` value to `SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE` key.

✅ Enables DeX standalone mode on supported phones.

✅ Compatible with `magisk` and `kernelsu`.

[![Made with brain](https://img.shields.io/badge/Made%20with-brain%E2%84%A2-orange.svg?style=flat-square)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
[![GitHub Stars](https://img.shields.io/github/stars/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Stars)](#)
[![GitHub Forks](https://img.shields.io/github/forks/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Forks)](#)
[![GitHub Watchers](https://img.shields.io/github/watchers/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Watchers)](#)
[![CI](https://img.shields.io/github/actions/workflow/status/supermarsx/magisk-samsung-dex-standalone-mode/ci.yml?style=flat-square&label=CI)](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/actions/workflows/ci.yml)
[![GitHub repo size](https://img.shields.io/github/repo-size/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Repo%20Size)](#)
[![GitHub Downloads](https://img.shields.io/github/downloads/supermarsx/magisk-samsung-dex-standalone-mode/total.svg?style=flat-square&label=Downloads)](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Issues)](#)


[**[Download latest release]**](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/releases/latest/download/magisk-samsung-dex-standalone-mode.zip)

[[Download repository]](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)

## Module requirements 

- Samsung One UI based ROM installed, either stock or custom, doesn't matter
- Rooted phone with Magisk or KernelSU (aka KSU)
- No potentially conflicting modules installed that change or interact with `floating_feature.xml`, overlapping modules will cause problems.

## Build Prerequisites

The build scripts require `bash` and the `zip` command to be installed and available in your PATH. Linux distributions usually provide them by default. Windows users can rely on WSL or Git Bash.

## Other goodies

There are shell `.sh` and batch `.bat` scripts to use according to your OS. They now live inside the `build-tools/` folder and are used for building and debugging the module.

Build related:

`build-tools/build-create-module.*` - Generates a new distribution ready ZIP module for installation.

`build-tools/build-delete-module.*` - Delete the current generated ZIP from folder.

`build-tools/build-filelist.txt` - Lists all files and folders to be included in the distribution ready ZIP module.

A `Makefile` is also provided for convenience with the targets:
`make build` - create the ZIP module.
`make clean` - remove the generated module.
`make test` - run the shell tests.
`make lint` - run shellcheck on all scripts.

Testing/debug related:

`debug/debug-unmount.sh` - Simple unmount script.

Run it after testing the module to unmount the patched file:

```bash
sh debug/debug-unmount.sh
```

Every boot `post-fs-data.log` a new log file is generated with debugging information, existing log file is always overwritten keeping space footprint small. It's usually located inside the modules folder `/data/adb/modules/samsung-dex-standalone-mode`.

## Building

Run `make build` from the repository root to create `magisk-samsung-dex-standalone-mode.zip` using the paths listed in `build-tools/build-filelist.txt`.
Use `make clean` to remove a previously generated ZIP.
During development `debug/debug-unmount.sh` can be used to unmount the patched file.


Check `floating_feature.xml` file values by using `su` and then `cat /system/etc/floating_feature.xml` using your preferred terminal interface.

## Testing

Run the shell based tests from the repository root with:

```bash
make test
```
Lint all shell scripts with:
```bash
make lint
```

Tests are also executed automatically in the CI pipeline.

## Release workflow

A GitHub Actions workflow builds the module whenever a tag is pushed or a release is published. The resulting `magisk-samsung-dex-standalone-mode.zip` is saved as a workflow artifact and attached to the release.

## Manual installation

After building the ZIP you can install it directly with Magisk:

```bash
magisk --install-module path/to/magisk-samsung-dex-standalone-mode.zip
```


## Issues

#### *"I'm having issues with gestures after exiting DeX"* or similar

See [Issue 2](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/2)

#### *"DeX is ignoring the notch", "Bar and DeX desktop doesn't go all the way"* or similar

See [Issue 3](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/3)

##### Possible fix
*TLDR:* Change cutout simulation to double cutout, thanks to [@admiralsym](https://github.com/admiralsym)

Generic instructions on how to change the display cutout setting

- Enable Developer Options (If Not Already Enabled)
  - Go to Settings > About phone.
  - Tap Software information.
  - Tap Build number seven times until you see "Developer mode has been enabled."
- Open Developer Options
  - Go back to Settings.
  - Scroll down and select Developer options.
- Change the Display Cutout Setting
  - Scroll down and find Simulate display with a cutout.
  - Tap it and select Double cutout.

#### *"Can't install zip", "Have an unzip error"* or similar

See [Issue 4](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/4)

##### Possible fix
*TLDR:* Use termux to manually install zip, thanks to [@hzykiss](https://github.com/hzykiss) 

- Use a terminal emulator like termux.
- Do su to get root privileges.
- Run magisk --install-module full_path_of_the_module.zip to install the module manually.

## Questions & Answers

Thanks to [@WilsonBradley](https://github.com/WilsonBradley) and [@foxypiratecove37350](https://github.com/foxypiratecove37350) for their questions, adapted for comprehension.

**Q. Does this require a Samsung device?**
- **A.** It does indeed, a Samsung but more precisely a Samsung based ROM with DeX in it.

**Q. By "Standalone mode" - does this mean DeX can be started on device itself at will (no HDMI connection required)?**
- **A.** YES, this what the module actually pretends to solve.

**Q. Could DeX be screen shared to another Android device?**
- **A.** This is a Android/DeX specific question but my guess is no?, if you know better open an issue.

**Q. Can it work on non-Samsung devices, or Samsung devices that don't support DeX?**
- **A.** Short is answer no. Long answer is any Samsung based ROM that has DeX can be used somehow, not at my level of interest though.

**Q. Can it work if the Samsung device has a custom ROM?**
- **A.** Maybe, if the custom ROM is stock/One UI based and has DeX it will work.

**Q. What are the requirements to run this?**
- **A.** Please check "module requirements" for more information.

**Q. Will this add DeX to my phone?**
- **A.** No.

## Changelog

2025.1
- Add release automation script
- Resolve shellcheck warnings

2024.2
- Build/debug scripts restructured
- Module status bug fix, kept adding onto olders statuses on reboot

2024.1
- Initial release

## Warranty

No warranties whatsoever.

## License

MIT License, check `license.md`.
