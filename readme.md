# magisk-samsung-dex-standalone-mode

Magisk module to systemlessly enable Samsung DeX standalone mode by patching `floating_feature.xml`, it adds `standalone` value to `<SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>` key.

✅ Enables DeX standalone mode on supported phones.

✅ Compatible with `magisk` and `kernelsu`.

[![Made with brain](https://img.shields.io/badge/Made%20with-brain%E2%84%A2-orange.svg?style=flat-square)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
[![GitHub Stars](https://img.shields.io/github/stars/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Stars)](#)
[![GitHub Forks](https://img.shields.io/github/forks/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Forks)](#)
[![GitHub Watchers](https://img.shields.io/github/watchers/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Watchers)](#)
[![GitHub repo size](https://img.shields.io/github/repo-size/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Repo%20Size)](#)
[![GitHub Downloads](https://img.shields.io/github/downloads/supermarsx/magisk-samsung-dex-standalone-mode/total.svg?style=flat-square&label=Downloads)](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/supermarsx/magisk-samsung-dex-standalone-mode?style=flat-square&label=Issues)](#)


[**[Download latest release]**](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/releases/latest/download/magisk-samsung-dex-standalone-mode.zip)

[[Download repository]](https://codeload.github.com/supermarsx/magisk-samsung-dex-standalone-mode/zip/refs/heads/main)


## Other goodies

There are shell `.sh` and batch `.bat` scripts to use according to your OS, they're basically build and testing scripts.

Build related:

`build-create-module.*` - Generates a new distribution ready ZIP module for installation.

`build-delete-module.*` - Delete module the current generated ZIP from folder.

`build-filelist.txt` - Lists all files and folders to be included in the distribution ready ZIP module.

Testing/debug related:

`debug-unmount.sh` - Simple unmount script.

Every boot `post-fs-data.log` a new log file is generated with debugging information, existing log file is always overwritten keeping space footprint small. It's usually located inside the modules folder `/data/adb/modules/samsung-dex-standalone-mode`.

Check `floating_feature.xml` file values by using `su` and then `cat /system/etc/floating_feature.xml` using your preferred terminal interface.

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

## Changelog

2024.2
- Build/debug scripts restructured
- Module status bug fix, kept adding onto olders statuses on reboot

2024.1
- Initial release

## Warranty

No warranties whatsoever.

## License

MIT License, check `license.md`.
