#!/system/bin/sh

# Unmount variables
floating_feature_xml_file="floating_feature.xml"

# Build list of all existing floating_feature.xml paths to unmount
floating_feature_xml_paths=""
if [ -f "/system/vendor/etc/floating_feature.xml" ]; then
	floating_feature_xml_paths="/system/vendor/etc/"
fi
if [ -f "/vendor/etc/floating_feature.xml" ]; then
	floating_feature_xml_paths="$floating_feature_xml_paths /vendor/etc/"
fi
if [ -f "/system/etc/floating_feature.xml" ]; then
	floating_feature_xml_paths="$floating_feature_xml_paths /system/etc/"
fi

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
#   Process unmount for all possible locations
process_unmount() {
	# Log path detection results
	for pu_check_path in /system/vendor/etc/ /vendor/etc/ /system/etc/; do
		if [ -f "${pu_check_path}${floating_feature_xml_file}" ]; then
			echo " [INFO] Found $floating_feature_xml_file at '$pu_check_path'."
		else
			echo " [INFO] Not found $floating_feature_xml_file at '$pu_check_path'."
		fi
	done
	for pu_unmount_dir in $floating_feature_xml_paths; do
		pu_unmount_target="$pu_unmount_dir$floating_feature_xml_file"
		unmount_file "$pu_unmount_target"
	done
}

process_unmount
