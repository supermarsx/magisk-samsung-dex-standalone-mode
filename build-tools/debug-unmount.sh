#!/system/bin/sh
set -euo pipefail

# Unmount variables
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_original_fullpath="/system/etc/floating_feature.xml"

# error_add()
#   Print an error message
#
# %usage: error_add message
error_add() {
    ea_value="$1"
    echo " [ERR!] Operation failed: $ea_value"
}

# unmount_file()
#   Unmount target
#
# %usage: unmount_file target_path
# parameters
#   target_path - Destination file path to unmount
unmount_file() {
    uf_destination_path="$1"

    echo " [INFO] Unmounting."
    if umount "$uf_destination_path"; then
        echo " [INFO] Unmount was successful."
    else
        error_add "mount.bind"
        echo " [ERR!] Unmount failed."
    fi
}

# process_unmount()
#   Process unmount
process_unmount() {
    pu_unmount_target="$floating_feature_xml_original_fullpath"
    unmount_file "$pu_unmount_target"
}

process_unmount
