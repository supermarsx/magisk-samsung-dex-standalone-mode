#!/system/bin/sh

#
# *********************************
# *  samsung-dex-standalone-mode  *
# *              ---              *
# *  Installation/Upgrade script  *
# *********************************
#

# Installation variables
module_name="samsung-dex-standalone-mode"
module_path="/data/adb/modules"
floating_feature_xml_file="floating_feature.xml"
floating_feature_xml_dir="/system/etc/"
floating_feature_xml_fullpath="$floating_feature_xml_dir$floating_feature_xml_file"
floating_feature_xml_dex_key="SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE"
floating_feature_xml_dex_key_value="standalone"
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_patched_fullpath="$module_path/$module_name/$floating_feature_xml_patched_file"

# set_module_permissions()
#   Set base permissions
set_module_permissions() {
	# Set base permissions to module path, owner is rw, others are read
	set_perm_recursive "$MODPATH" 0 0 0755 0755
	ui_print " [INFO] Module path permissions set 0755."
}

# filepath_exists()
#   Check if a given file path exists
#
# %usage: filepath_exists filepath
# $parameters
#   filepath - Path to file, full or relative
filepath_exists() {
	fpe_filepath="$1"

	if [ -e "$fpe_filepath" ]; then
		ui_print " [INFO] File path exists '$fpe_filepath'."
		return 0
	else
		ui_print " [INFO] File path doesn't exist: '$fpe_filepath'."
		return 1
	fi
}

# file_key_exists()
#   Check if specific file key exists
#
# %usage: file_key_exists filepath key
# $parameters
#   filepath - Path to file, full or relative
#   key - Key to look for inside file
file_key_exists() {
	fke_filepath="$1"
	fke_key="$2"

	if grep -q "<$fke_key" "$fke_filepath"; then
		ui_print " [INFO] Key '$fke_key' exists inside '$fke_filepath'."
		return 0
	else
		ui_print " [INFO] Key '$fke_key' doesn't exist inside '$fke_filepath'."
		return 1
	fi
}

# file_key_contains_value()
#   Check if a file key contains a given value
#
# %usage: file_key_contains_value filepath key value
# $parameters
#   filepath - Path to file, full or relative
#   key - Key to check for value
#   value - Value/Partial string to search in key value
file_key_contains_value() {
	fkcv_filepath="$1"
	fkcv_key="$2"
	fkcv_value="$3"

	# shellcheck disable=SC1087
	if grep -q "<$fkcv_key[^>]*>.*$fkcv_value.*</$fkcv_key>" "$fkcv_filepath"; then
		ui_print " [INFO] Key '$fkcv_key' contains '$fkcv_value' inside '$fkcv_filepath'."
		return 0
	else
		ui_print " [INFO] Key '$fkcv_key' doesn't contain '$fkcv_value' inside '$fkcv_filepath'."
		return 1
	fi
}

# module_remove_mark()
#   Mark module for removal
module_remove_mark() {
	touch "$MODPATH/remove"
	ui_print " [INFO] Marked module for removal."
}

# install_welcome()
#   Installation welcome message
install_welcome() {
	iw_file="$floating_feature_xml_file"

	ui_print
	ui_print " *******************************"
	ui_print " * samsung-dex-standalone-mode *"
	ui_print " *******************************"
	ui_print
	ui_print " * Systemlessly patch $iw_file"
	ui_print " * every boot to enable Samsung DeX standalone mode."
	ui_print
	ui_print " [INFO] Starting Installation."
}

# install_done()
#   Finish/Wrap up the installation script process
install_done() {
	id_file="$floating_feature_xml_file"

	ui_print " [INFO] $id_file will be patched every boot."
	ui_print " [INFO] Installation finished successfully."
	exit 0
}

# install_cancel()
#   Abort installation message
install_cancel() {
	ui_print
	module_remove_mark
	abort " [INFO] Installation was cancelled."
}

# install_exists()
#   Check if a previous module installation exists
install_exists() {
	ie_filepath="$floating_feature_xml_patched_fullpath"

	if filepath_exists "$ie_filepath"; then
		ui_print " [WARN] Module is already installed."
		ui_print " [INFO] Going for *upgrade*."
		ui_print " [INFO] Skipping installation checks."
		install_done
	else
		ui_print " [INFO] No previous installation found."
		ui_print " [INFO] Going for initial *installation*."
	fi
}

# floating_feature_file_exists()
#   Check if floating feature file exists
floating_feature_file_exists() {
	fffe_filepath="$floating_feature_xml_fullpath"

	if filepath_exists "$fffe_filepath"; then
		ui_print " [INFO] Passed floating features file exists."
	else
		ui_print " [ERR!] Failed floating features file exists."
		ui_print " [INFO] Might not be a samsung phone or doesn't have a valid floating features file."
		install_cancel
	fi
}

# floating_feature_file_key_exists()
#   Check if floating feature file key exists
floating_feature_file_key_exists() {
	fffke_filepath="$floating_feature_xml_fullpath"
	fffke_key="$floating_feature_xml_dex_key"

	if file_key_exists "$fffke_filepath" "$fffke_key"; then
		ui_print " [INFO] Passed floating feature key check."
	else
		ui_print " [ERR!] Failed floating features key check."
		ui_print " [INFO] Might be an unsupported model or phone doesn't support DeX mode."
		install_cancel
	fi
}

# floating_feature_already_enabled()
#   Check if floating feature has standalone already enabled
floating_feature_already_enabled() {
	ffae_filepath="$floating_feature_xml_fullpath"
	ffae_key="$floating_feature_xml_dex_key"
	ffae_value="$floating_feature_xml_dex_key_value"

	if file_key_contains_value "$ffae_filepath" "$ffae_key" "$ffae_value"; then
		ui_print " [ERR!] Failed floating features key value check."
		ui_print " [INFO] Floating features has DeX standalone mode already enabled."
		install_cancel
	else
		ui_print " [INFO] Passed floating features key value check."
	fi
}

# install_requirements_check()
#   Check if installation requirements are met
install_requirements_check() {
	ui_print " [INFO] Checking requirements."
	install_exists
	floating_feature_file_exists
	floating_feature_file_key_exists
	floating_feature_already_enabled
	install_done
}

# install_process()
#   Process installation (main/entry)
install_process() {
	install_welcome
	set_module_permissions
	install_requirements_check
}

install_process
