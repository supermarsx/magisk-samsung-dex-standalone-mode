#!/data/adb/magisk/busybox ash
# shellcheck shell=dash

# Installation variables
module_name="samsung-dex-standalone-mode"
module_path="/data/adb/modules"
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_patched_fullpath="$module_path/$module_name/$floating_feature_xml_patched_file"

# unmount_file()
#   Unmount target
#
# %usage: unmount_file source_path target_path
# parameters
#   destination_path - Destination file path
unmount_file() {
    local destination_path="$2"

    echo " [INFO] Unmounting."
    if umount "$destination_path"; then
        echo " [INFO] Unmount was successful."
    else
        error_add "mount.bind"
        echo " [ERR!] Unmount failed."
    fi
}

# process_unmount()
#   Process unmount
process_unmount() {
    local unmount_target="$floating_feature_xml_patched_fullpath"
    unmount_file "$unmount_target"
}

process_unmount