# magisk-samsung-dex-standalone-mode

Magisk module to systemlessly enable Samsung DeX standalone mode by patching `floating_feature.xml`, adds `standalone` value to the key `<SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>`.

✅ Enables DeX standalone mode on supported phones.

✅ Compatible with `magisk` and `kernelsu`.



[**[Download latest release]**](https://codeload.github.com/supermarsx/magickeyboard/zip/refs/heads/main)

[[Download repository]](https://codeload.github.com/supermarsx/magickeyboard/zip/refs/heads/main)



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



## Warranty

No warranties whatsoever.
