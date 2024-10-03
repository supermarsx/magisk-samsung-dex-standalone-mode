# magisk-samsung-dex-standalone-mode

Magisk module to systemlessly enable Samsung DeX standalone mode by patching `floating_feature.xml`, adds `standalone` value to `<SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>` key.

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


## Additional stuff

Build related:

`create-module.bat` - Generates a new module ZIP for installation

`filelist.txt` - File and folder list to include in a new module ZIP

`delete-module.bat` - Delete module ZIP from folder

Testing related:

`unmount.sh` - Unmount script

Debugging related:

Every boot `post-fs-data.log` log file is generated with debugging information, if there was another already there it's overwritten.

Check `floating_feature.xml` values by using `su` and `cat /system/etc/floating_feature.xml`

## Issues

*"I'm having issues with gestures after exiting DeX"* or similar, See [Issue 2](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode/issues/2)

## Changelog

2024.1
- Initial release

2024.2
- Build/debug scripts restructured
- Module status bug fix

## Warranty

No warranties whatsoever.

## License

MIT License, check `license.md`
