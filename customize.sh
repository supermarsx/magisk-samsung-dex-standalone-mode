#
# *********************************
# *  samsung-dex-standalone-mode  *
# *              ---              *
# *  Installation/Upgrade script  *
# *********************************
#

# Installation variables
module_path=$MODPATH
floating_feature_xml_file="floating_feature.xml"
floating_feature_xml_dir="/system/etc/"
floating_feature_xml_fullpath="$floating_feature_xml_dir$floating_feature_xml_file"
floating_feature_xml_dex_key="<SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>"
floating_feature_xml_dex_key_value="standalone"
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_patched_fullpath="$MODPATH/$floating_feature_xml_patched_file"

# set_permissions()
#   Set base permissions
set_permissions() {
    # Set base permissions to module path, owner is rw, others are read
    set_perm_recursive $module_path 0 0 0755 0755
    ui_print " [INFO] Module path permissions set 0755."
}

# filepath_exists()
#   Check if a given file path exists
#
# %usage: filepath_exists filepath
# $parameters
#   filepath - Path to file, full or relative
filepath_exists() {
    local filepath="$1"

    if [[ -e "$filepath"]]; then
        ui_print " [INFO] File path exists: $filepath"
        return 0
    else
        ui_print " [INFO] File path doesn't exist: $filepath"
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
    local filepath="$1"
    local key="$2"

    if grep -q "$key" "$filepath"; then
        ui_print " [INFO] Key '$key' exists inside '$filepath'"
        return 0
    else
        ui_print " [INFO] Key '$key' doesn't exist inside '$filepath'"
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
    local filepath="$1"
    local key="$2"
    local value="$3"

    if grep -q "<$key[^>]*>.*$value.*</$key>" "$filepath"; then
        ui_print " [INFO] Key '$key' contains '$value' inside '$filepath'"
        return 0
    else
        ui_print " [INFO] Key '$key' doesn't contain '$value' inside '$filepath'"
        return 1
    fi
}

# module_remove_mark()
#   Mark module for removal
module_remove_mark() {
    touch $MODPATH/remove
    ui_print " [INFO] Marked module for removal."
}

# install_welcome()
#   Installation welcome message
install_welcome() {
    local file="$floating_feature_xml_file"

    ui_print
    ui_print " *******************************"
    ui_print " * samsung-dex-standalone-mode *"
    ui_print " *******************************"
    ui_print
    ui_print " * Systemlessly patch $file"
    ui_print " * every boot to enable Samsung DeX standalone mode."
    ui_print
    ui_print " [INFO] Starting Installation."
}

# install_done()
#   Finish/Wrap up the installation script process
install_done() {
    local file="$floating_feature_xml_file"

    ui_print
    ui_print " [INFO] $file will be patched every boot."
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
    local filepath=$floating_feature_xml_patched_path

    if filepath_exists "$filepath"; then
        ui_print " [WARN] Module is already installed."
        ui_print " [INFO] Going for *upgrade*."
        ui_print " [INFO] Skipping installation checks."
        install_done
    else
        ui_print " [INFO] No previous installation installation found."
        ui_print " [INFO] Going for initial *installation*."
    fi
}

# floating_feature_file_exists()
#   Check if floating feature file exists
floating_feature_file_exists() {
    local filepath="$floating_feature_xml_fullpath"

    if filepath_exists "$filepath"; then
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
    local filepath="$floating_feature_xml_fullpath"
    local key="$floating_feature_xml_dex_key"

    if file_key_exists "$filepath" "$key"; then
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
    local filepath="$floating_feature_xml_fullpath"
    local key="$floating_feature_xml_dex_key"
    local value="$floating_feature_xml_dex_key_value"

    if file_key_contains_value "$filepath" "$key" "$value"; then
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
    set_permissions
    install_requirements_check
}

install_process