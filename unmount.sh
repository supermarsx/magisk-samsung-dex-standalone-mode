#!/system/bin/sh

# Unmount variables
floating_feature_xml_patched_file="floating_feature.xml.patched"

# unmount_file()
#   Unmount target
#
# %usage: unmount_file source_path target_path
# parameters
#   destination_path - Destination file path
unmount_file() {
    uf_destination_path="$2"

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
    pu_unmount_target="$floating_feature_xml_patched_file"
    unmount_file "$pu_unmount_target"
}

process_unmount