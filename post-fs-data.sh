#!/data/adb/magisk/busybox ash
# shellcheck shell=dash

# General variables
module_dir=${0%/*}
module_prop_file="module.prop"
module_prop_fullpath="$module_dir/$module_prop_file"
floating_feature_xml_file="floating_feature.xml"
floating_feature_xml_dir="/system/etc/"
floating_feature_xml_fullpath="$floating_feature_xml_dir$floating_feature_xml_file"
floating_feature_xml_dex_key="<SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>"
floating_feature_xml_dex_key_value="standalone"
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_patched_fullpath="$module_dir/$floating_feature_xml_patched_file"
error_count=0
error_message=""

# error_count_up()
#   Increase error count
increment_error_count() {
    error_count="$((error_count+1))"
}

# error_message_append()
#   Append to error message
#
# %usage: error_message_append value
# $parameters
#   value - Message to add to error messages
error_message_append() {
    local value="$1"

    error_message="$error_message$value failed;"
}

# error_add()
#   Add to running errors
#
# %usage: error_add message
# $parameters
#   value - Error message to add to current errors
error_add() {
    local value="$1"

    increment_error_count
    error_message_append "$value"
}

# file_copy()
#   Copy file to another path
#
# %usage: file_copy source_path destination_path
# $parameters
#   source_path - Source file path
#   destination_path - Destination file path
file_copy() {
    local source_path="$1"
    local destination_path="$2"

    cp "$source_path" "$destination_path" || error_add "cp"
}

# filepath_exists()
#   Check if a given file path exists
#
# %usage: filepath_exists filepath
# $parameters
#   filepath - Path to file, full or relative
filepath_exists() {
    local filepath="$1"

    if [ -e "$filepath" ]; then
        return 0
    else
        return 1
    fi
}

# file_clear_property()
#   Clear property of a given properties file
#
# %usage: file_clear_property filepath property
# $parameters
#   filepath - Path to file
#   property - Property to clear
file_clear_property() {
    local filepath="$1"
    local property="$2"

    sed -i -E "s/${property}=(\[.+\] )?/${property}=/" "$filepath"
}

# file_is_property_clean()
#   Check if property of a given properties file is clean/empty
#
# %usage: file_is_property_clean filepath property
# $parameters
#   filepath - Path to file
#   property - Property to check
file_is_property_clean() {
    local filepath="$1"
    local property="$2"

    if grep -q "${property}=" "$filepath"; then
        return 0
    else
        return 1
    fi
}

# file_set_property()
#   Set property of a given properties file
#
# %usage: file_set_property filepath property value
# $parameters
#   filepath - Path to file
#   property - Property to change
#   value - Value to set property to
file_set_property() {
    local filepath="$1"
    local property="$2"
    local value="$3"

    if filepath_exists "$filepath"; then
        file_clear_property "$filepath" "$property"
        if file_is_property_clean "$filepath" "$property"; then
            if [ -n "$value" ]; then
                sed -i -E "s/${property}=/&$value/" "$filepath"
            fi
        fi
    else
        return 1
    fi
}

# module_set_message()
#   Set description of module, like status or other useful message
#
# %usage: module_set_message value
# $parameters
#   value - message to set prop to
module_set_message() {
    local filepath="$module_prop_fullpath"
    local property="description"
    local value="$1"

    file_set_property "$filepath" "$property" "$value"
}

# file_remove_xml_key_value()
#   Remove value from key of a given xml file
#
# %usage: file_remove_xml_key_value filepath key value
# $parameters
#   filepath - Xml file path
#   key - Key
#   value - Value to remove from key
file_remove_xml_key_value() {
    local filepath="$1"
    local key="$2"
    local value="$3"

    sed -i -E "/<$key>/s/,? *${value}//g" "$filepath"
}

# file_add_xml_key_value()
#   Add value to key of a given xml file
#
# %usage: file_add_xml_key_value filepath key value
# $parameters
#   filepath - Xml file path
#   key - Key to set
#   value - Value to add to key
file_add_xml_key_value() {
    local filepath="$1"
    local key="$2"
    local value="$3"

    sed -i -E "/<$key>/s/<$key>(.*)<\/$key>/<$key>\1,$value<\/$key>/" "$filepath"
}

# file_remove_xml_key_commas()
#   Remove leading commas from key value of a given xml file
#
# %usage: file_remove_xml_key_commas filepath key
# $parameters
#   filepath - Xml file path
#   key - Key to remove leading commas from
file_remove_xml_key_commas() {
    local filepath="$1"
    local key="$2"
    local value="$3"

    sed -i -E "/<$key>/s/<$key>(.*)<\/$key>/<$key>\1,$value<\/$key>/" "$filepath"
}

# file_set_xml_key()
#   Set/Add to key of a given xml file
#
# %usage: file_set_xml_key original_filepath patched_filepath key value
# $parameters
#   original_filepath - Original xml file path
#   patched_filepath - Patched xml file destination file path 
#   key - Key to set
#   value - Value to set key to/add to
file_set_xml_key() {
    local original_filepath="$1"
    local patched_filepath="$2"
    local key="$3"
    local value="$4"

    if filepath_exists "$original_filepath"; then
        file_remove_xml_key_value "$original_filepath" "$key" "$value"
        file_add_xml_key_value "$original_filepath" "$key" "$value"
        file_remove_xml_key_commas "$original_filepath" "$key"
        file_copy "$original_filepath" "$patched_filepath"
    else
        return 1
    fi
}

# set_permissions()
#   Set file permissions
#
# %usage: set_permissions filepath
# $parameters
#   filepath - File path to set permissions
set_permissions() {
    local filepath="$1"

    chown root:root "$filepath" || error_add "chown"
    chmod 0644 "$filepath" || error_add "chmod"
    chcon -v u:object_r:system_file:s0 "$filepath" || error_add "chcon"
}

# mount_file()
#   Bind mount a file to a target
#
# %usage: mount_file source_path target_path
# parameters
#   source_path - Source file path
#   destination_path - Destination file path
mount_file() {
    local source_path="$1"
    local destination_path="$2"

    mount -o bind "$destination_path" "$source_path" || error_add "mount bind"
}

# module_set_status()
#   Set module status through description
module_set_status() {
    if [ "$error_count" -gt 0 ]; then
        module_set_message "$(printf '\u274C') [WARN/ERROR] - Failed with $error_count error(s): $error_message"
    else
        module_set_message "$(printf '\u2705') [OK] - Samsung DeX standalone mode set"
    fi
}

# post_fs_process()
#   Post fs synchronous process at boot (main/entry)
post_fs_process() {
    local original_filepath="$floating_feature_xml_fullpath"
    local patched_filepath="$floating_feature_xml_patched_fullpath"
    local key="$floating_feature_xml_dex_key"
    local value="$floating_feature_xml_dex_key_value"

    module_set_message ""
    file_set_xml_key "$original_filepath" "$patched_filepath" "$key" "$value"
    set_permissions "$patched_filepath"
    mount_file "$original_filepath" "$patched_filepath"
    module_set_status
}

post_fs_process