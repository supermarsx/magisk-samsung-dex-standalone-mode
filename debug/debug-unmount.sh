#!/system/bin/sh

# Unmount variables
floating_feature_xml_file="floating_feature.xml"

# Check for correct floating_feature.xml path
if [ -f "/system/vendor/etc/floating_feature.xml" ]; then
	floating_feature_xml_dir="/system/vendor/etc/"
elif [ -f "/vendor/etc/floating_feature.xml" ]; then
	floating_feature_xml_dir="/vendor/etc/"
elif [ -f "/system/etc/floating_feature.xml" ]; then
	floating_feature_xml_dir="/system/etc/"
else
	floating_feature_xml_dir="/system/etc/"
fi

floating_feature_xml_fullpath="$floating_feature_xml_dir$floating_feature_xml_file"

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
	pu_unmount_target="$floating_feature_xml_fullpath"
	unmount_file "$pu_unmount_target"
}

process_unmount
