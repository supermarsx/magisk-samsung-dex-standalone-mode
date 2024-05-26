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
    echo " [INFO] Incrementing error by 1."
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

    echo " [INFO] Appending new error with '$value'."
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

    echo " [ERR!] Operation failed: $value"
    increment_error_count
    error_message_append "$value"
}

# is_empty()
#   Check if variable is empty
#
# %usage: is_empty value
# $parameters
#   value - Value to check if it is considered empty
is_empty() {
    local value="$1"

    if [ -n "$value" ]; then
        return 0
    else
        return 1
    fi
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

    echo " [INFO] Copying file '$source_path' to '$destination_path'." 
    if cp "$source_path" "$destination_path"; then
        echo " [INFO] File was copied successfully."
        return 0
    else
        echo " [ERR!] Failed to copy file."
        error_add "cp"
        return 1
    fi
}

# filepath_exists()
#   Check if a given file path exists
#
# %usage: filepath_exists filepath
# $parameters
#   filepath - Path to file, full or relative
filepath_exists() {
    local filepath="$1"

    echo " [INFO] Checking if file path exists: '$filepath'."
    if [ -e "$filepath" ]; then
        echo " [INFO] File exists."
        return 0
    else
        echo " [INFO] File doesn't exist."
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

    echo " [INFO] Clearing file '$filepath' property '$property'."
    if sed -i -E "s/${property}=(\[.+\] )?/${property}=/" "$filepath"; then
        echo " [INFO] File property clearing was successful."
    else
        error_add "sed.clearprop"
        echo " [ERR!] File property clearing failed."
    fi
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

    echo " [INFO] Checking if file '$filepath' property '$property' is cleared."
    if grep -q "${property}=" "$filepath"; then
        echo " [INFO] File property is cleared."
        return 0
    else
        echo " [INFO] File property isn't cleared."
        return 1
    fi
}

# file_set_property_direct()
#   Set property of a give properties file directly without checks
#
# %usage: file_set_property_direct filepath property value
# $parameters
#   filepath - Path to file
#   property - Property to change
#   value - Value to set property to
file_set_property_direct() {
    local filepath="$1"
    local property="$2"
    local value="$3"
    
    echo " [INFO] Setting file '$filepath' property '$property' value '$value' directly now."
    if sed -i -E "s/${property}=/&$value/" "$filepath"; then
        echo " [INFO] File property was set successfully."
    else
        error_add "sed.setprop"
        echo " [ERR!] File property set failed."
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

    echo " [INFO] Setting file '$filepath' property '$property' value '$value'."
    if filepath_exists "$filepath"; then
        file_clear_property "$filepath" "$property"
        if file_is_property_clean "$filepath" "$property"; then
            if is_empty "$value"; then
                file_set_property_direct "$filepath" "$property" "$value"
                return 0
            else
                echo " [INFO] No value was set due to parameters."
                return 0
            fi
        else
            return 1
        fi
    else
        error_add "fileexists"
        echo " [ERR!] File '$filepath' doesn't exist."
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

    echo " [INFO] Removing value '$value' from xml file '$filepath' key '$key'."
    if sed -i -E "/<$key>/s/,? *${value}//g" "$filepath"; then
        echo " [INFO] Removed value from xml key successfully."
        return 0
    else
        error_add "sed.removexmlkeyvalue"
        echo " [ERR!] Failed to remove value from xml key."
        return 1
    fi
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

    echo " [INFO] Adding value '$value' to xml file '$filepath' key '$key'."
    if sed -i -E "/<$key>/s/<$key>(.*)<\/$key>/<$key>\1,$value<\/$key>/" "$filepath"; then
        echo " [INFO] Added value to xml key successfully."
        return 0
    else
        error_add "sed.addxmlkeyvalue"
        echo " [ERR!] Failed to add value to xml key."
        return 1
    fi
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

    echo " [INFO] Removing leading commas from value '$value' in xml file '$filepath' key '$key'."
    if sed -i -E "/<$key>/s/<$key>(.*)<\/$key>/<$key>\1,$value<\/$key>/" "$filepath"; then
        echo " [INFO] Removed leading commas successfully."
        return 0
    else
        echo " [WARN] No leading commas found or command failed."
        return 0
    fi
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

    echo " [INFO] Patching xml file key '$key'."
    if filepath_exists "$original_filepath"; then
        file_remove_xml_key_value "$original_filepath" "$key" "$value"
        if file_add_xml_key_value "$original_filepath" "$key" "$value"; then
            file_remove_xml_key_commas "$original_filepath" "$key"
            if file_copy "$original_filepath" "$patched_filepath"; then
                echo " [INFO] Patched xml file successfully."
                return 0
            else
                echo " [ERR!] Failed patching xml file key '$key'."
                return 1
            fi
        else
            return 0
        fi
    else
        error_add "fileexists"
        echo " [ERR!] File '$original_filepath' doesn't exist."
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

    echo " [INFO] Setting permissions."
    echo " [INFO] Changing file owner, '$filepath'"
    if chown root:root "$filepath"; then
        echo " [INFO] Changed file owner successfully."
    else
        error_add "chown"
        echo " [ERR!] Failed to change file owner."
    fi

    echo " [INFO] Setting file permissions."
    if chmod 0644 "$filepath"; then
        echo " [INFO] Change file permissions successfully."
    else
        error_add "chmod"
        echo " [ERR!] Failed to change file permissions."
    fi
    
    echo " [INFO] Setting security context."
    if chcon -v u:object_r:system_file:s0 "$filepath"; then
        echo " [INFO] Security context set successfully."
    else
        error_add "chcon"
        echo " [ERR!] Failed to change security context."
    fi
} 

# mount_file()
#   Bind mount a file to a target
#
# %usage: mount_file source_path destination_path
# parameters
#   source_path - Source file path
#   destination_path - Destination file path
mount_file() {
    local source_path="$1"
    local destination_path="$2"

    echo " [INFO] Mount binding file."
    if mount -o bind "$destination_path" "$source_path"; then
        echo " [INFO] Mount bind was successful."
    else
        error_add "mount.bind"
        echo " [ERR!] Mount bind failed."
    fi
}

# module_set_status()
#   Set module status through description
module_set_status() {
    echo " [INFO] Setting module status."
    if [ "$error_count" -gt 0 ]; then
        module_set_message "⚠️❗ [WARN/ERROR] - Failed to set mode with ($error_count) error(s): $error_message"
    else
        module_set_message "✅ [OK] - Samsung DeX standalone mode set"
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
    if file_set_xml_key "$original_filepath" "$patched_filepath" "$key" "$value"; then
        set_permissions "$patched_filepath"
        mount_file "$original_filepath" "$patched_filepath"
    fi
    
    module_set_status
}

post_fs_process