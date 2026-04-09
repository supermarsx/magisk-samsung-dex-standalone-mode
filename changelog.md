# Samsung DeX Standalone Mode

### New version available 

Version: 2026.2

Check [module github page](https://github.com/supermarsx/magisk-samsung-dex-standalone-mode)

## Changelog:

2026.2
- Fix patching on devices where floating_feature.xml exists at multiple paths (e.g. Galaxy S20+) thanks to [@parkerlreed](https://github.com/parkerlreed)
- Mount patched file to all detected locations instead of only the first one found
- Add path detection logging for easier debugging
- Installation checks now validate across all known paths

2026.1
- Add support for older phones such as S9, 10, Note 9 that use "system-as-root" partition layout thanks to [@serifpersia](https://github.com/serifpersia)
- Minor fixes

2025.1
- Add release automation script
- Resolve shellcheck warnings

2024.2
- Build/debug scripts restructured
- Module status bug fix

2024.1
- Initial release
