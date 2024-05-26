#!/system/bin/sh

# General variables
module_name="samsung-dex-standalone-mode"
module_dir="/data/adb/modules/$module_name/"
module_log_file="post-fs-data.log"
module_log_file_fullpath="$module_dir$module_log_file"
module_prop_file="module.prop"
module_prop_fullpath="$module_dir$module_prop_file"
floating_feature_xml_file="floating_feature.xml"
floating_feature_xml_dir="/system/etc/"
floating_feature_xml_fullpath="$floating_feature_xml_dir$floating_feature_xml_file"
floating_feature_xml_dex_key="SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE"
floating_feature_xml_dex_key_value="standalone"
floating_feature_xml_patched_file="floating_feature.xml.patched"
floating_feature_xml_patched_fullpath="$module_dir$floating_feature_xml_patched_file"
error_count=0
error_message=""
logfile="$module_log_file_fullpath"

# error_count_up()
#   Increase error count
increment_error_count() {
    echo " [INFO] Incrementing error by 1." >> "$logfile"
    error_count="$((error_count+1))"
}

# error_message_append()
#   Append to error message
#
# %usage: error_message_append value
# $parameters
#   value - Message to add to error messages
error_message_append() {
    ema_value="$1"

    echo " [INFO] Appending new error with '$ema_value'." >> "$logfile"
    error_message="$error_message$ema_value failed;"
}

# error_add()
#   Add to running errors
#
# %usage: error_add message
# $parameters
#   value - Error message to add to current errors
error_add() {
    ea_value="$1"

    echo " [ERR!] Operation failed: $ea_value" >> "$logfile"
    increment_error_count
    error_message_append "$ea_value"
}

# is_empty()
#   Check if variable is empty
#
# %usage: is_empty value
# $parameters
#   value - Value to check if it is considered empty
is_empty() {
    ie_value="$1"

    if [ -n "$ie_value" ]; then
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
    fc_source_path="$1"
    fc_destination_path="$2"

    echo " [INFO] Copying file '$fc_source_path' to '$fc_destination_path'." >> "$logfile"
    if cp "$fc_source_path" "$fc_destination_path"; then
        echo " [INFO] File was copied successfully." >> "$logfile"
        return 0
    else
        echo " [ERR!] Failed to copy file." >> "$logfile"
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
    fe_filepath="$1"

    echo " [INFO] Checking if file path exists: '$fe_filepath'." >> "$logfile"
    if [ -e "$fe_filepath" ]; then
        echo " [INFO] File exists." >> "$logfile"
        return 0
    else
        echo " [INFO] File doesn't exist." >> "$logfile"
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
    fcp_filepath="$1"
    fcp_property="$2"

    echo " [INFO] Clearing file '$fcp_filepath' property '$fcp_property'." >> "$logfile"
    if sed -i -E "s/${fcp_property}=(\[.+\] )?/${fcp_property}=/" "$fcp_filepath" >> "$logfile"
    then
        echo " [INFO] File property clearing was successful." >> "$logfile"
    else
        error_add "sed.clearprop"
        echo " [ERR!] File property clearing failed." >> "$logfile"
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
    fipc_filepath="$1"
    fipc_property="$2"

    echo " [INFO] Checking if file '$fipc_filepath' property '$fipc_property' is cleared." >> "$logfile"
    if grep -q "${fipc_property}=" "$fipc_filepath"; then
        echo " [INFO] File property is clear." >> "$logfile"
        return 0
    else
        echo " [INFO] File property isn't cleared." >> "$logfile"
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
    fspd_filepath="$1"
    fspd_property="$2"
    fspd_value="$3"
    
    echo " [INFO] Setting file '$fspd_filepath' property '$fspd_property' value '$fspd_value' directly now." >> "$logfile"
    if sed -i -E "s/$fspd_property=/&$fspd_value/" "$fspd_filepath"
    then
        echo " [INFO] File property was set successfully." >> "$logfile"
    else
        error_add "sed.setprop"
        echo " [ERR!] File property set failed." >> "$logfile"
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
    fsp_filepath="$1"
    fsp_property="$2"
    fsp_value="$3"

    echo " [INFO] Setting file '$fsp_filepath' property '$fsp_property' value '$fsp_value'." >> "$logfile"
    if filepath_exists "$fsp_filepath"; then
        file_clear_property "$fsp_filepath" "$fsp_property"
        if file_is_property_clean "$fsp_filepath" "$fsp_property"; then
            if is_empty "$fsp_value"; then
                file_set_property_direct "$fsp_filepath" "$fsp_property" "$fsp_value"
                return 0
            else
                echo " [INFO] No value was set due to parameters." >> "$logfile"
                return 0
            fi
        else
            return 1
        fi
    else
        error_add "fileexists"
        echo " [ERR!] File '$fsp_filepath' doesn't exist." >> "$logfile"
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
    msm_filepath="$module_prop_fullpath"
    msm_property="description"
    msm_value="$1"

    file_set_property "$msm_filepath" "$msm_property" "$msm_value"
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
    frxkv_filepath="$1"
    frxkv_key="$2"
    frxkv_value="$3"

    echo " [INFO] Removing value '$frxkv_value' from xml file '$frxkv_filepath' key '$frxkv_key'." >> "$logfile"
    if sed -i -E "/<$frxkv_key>/s/,? *$frxkv_value//g" "$frxkv_filepath"
    then
        echo " [INFO] Removed value from xml key successfully." >> "$logfile"
        return 0
    else
        error_add "sed.removexmlkeyvalue"
        echo " [ERR!] Failed to remove value from xml key." >> "$logfile"
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
    faxkv_filepath="$1"
    faxkv_key="$2"
    faxkv_value="$3"

    echo " [INFO] Adding value '$faxkv_value' to xml file '$faxkv_filepath' key '$faxkv_key'." >> "$logfile"
    if sed -i -E "/<$faxkv_key>/s/<$faxkv_key>(.*)<\/$faxkv_key>/<$faxkv_key>\1,$faxkv_value<\/$faxkv_key>/" "$faxkv_filepath"
    then
        echo " [INFO] Added value to xml key successfully." >> "$logfile"
        return 0
    else
        error_add "sed.addxmlkeyvalue"
        echo " [ERR!] Failed to add value to xml key." >> "$logfile"
        return 1
    fi
}

# file_remove_xml_key_commas()
#   Remove extra commas from key value of a given xml file
#
# %usage: file_remove_xml_key_commas filepath key
# $parameters
#   filepath - Xml file path
#   key - Key to remove extra commas from
file_remove_xml_key_commas() {
    frxkc_filepath="$1"
    frxkc_key="$2"

    echo " [INFO] Removing trailing commas from value in xml file '$frxkc_filepath' key '$frxkc_key'." >> "$logfile"
    if sed -i -E "/<$frxkc_key>/s/,(<\/$frxkc_key>)/\1/" "$frxkc_filepath"; then
        echo " [INFO] Removed trailing commas successfully." >> "$logfile"
    else
        echo " [WARN] No trailing commas found or command failed." >> "$logfile"
    fi
    return 0
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
    fsxk_original_filepath="$1"
    fsxk_patched_filepath="$2"
    fsxk_key="$3"
    fsxk_value="$4"

    echo " [INFO] Patching xml file key '$fsxk_key'." >> "$logfile"
    if filepath_exists "$fsxk_original_filepath"; then
        if file_copy "$fsxk_original_filepath" "$fsxk_patched_filepath"; then
            #file_remove_xml_key_value "$fsxk_patched_filepath" "$fsxk_key" "$fsxk_value"
            if file_add_xml_key_value "$fsxk_patched_filepath" "$fsxk_key" "$fsxk_value"; then
                file_remove_xml_key_commas "$fsxk_patched_filepath" "$fsxk_key"
                echo " [INFO] Patched xml file successfully." >> "$logfile"
                return 0
            else
                echo " [ERR!] Failed patching xml file key '$fsxk_key'." >> "$logfile"
                return 1   
            fi
        else
            return 0
        fi
    else
        error_add "fileexists"
        echo " [ERR!] File '$fsxk_original_filepath' doesn't exist." >> "$logfile"
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
    sp_filepath="$1"

    echo " [INFO] Setting permissions." >> "$logfile"
    echo " [INFO] Changing file owner, '$sp_filepath'" >> "$logfile"
    if chown root:root "$sp_filepath"; then
        echo " [INFO] Changed file owner successfully." >> "$logfile"
    else
        error_add "chown"
        echo " [ERR!] Failed to change file owner." >> "$logfile"
    fi

    echo " [INFO] Setting file permissions." >> "$logfile"
    if chmod 0644 "$sp_filepath"; then
        echo " [INFO] Change file permissions successfully." >> "$logfile"
    else
        error_add "chmod"
        echo " [ERR!] Failed to change file permissions." >> "$logfile"
    fi
    
    echo " [INFO] Setting security context." >> "$logfile"
    if chcon -v u:object_r:system_file:s0 "$sp_filepath"; then
        echo " [INFO] Security context set successfully." >> "$logfile"
    else
        error_add "chcon"
        echo " [ERR!] Failed to change security context." >> "$logfile"
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
    mf_source_path="$1"
    mf_destination_path="$2"

    echo " [INFO] Mount binding file." >> "$logfile"
    if mount -o bind "$mf_source_path" "$mf_destination_path"; then
        echo " [INFO] Mount bind was successful." >> "$logfile"
    else
        error_add "mount.bind"
        echo " [ERR!] Mount bind failed." >> "$logfile"
    fi
}

# module_set_status()
#   Set module status through description
module_set_status() {
    echo " [INFO] Setting module status."
    if [ "$error_count" -gt 0 ]; then
        module_set_message "⚠️❗ [WARN/ERROR] - Failed to set standalone mode with ($error_count) error(s): $error_message ||| "
    else
        module_set_message "✅ [OK] - Samsung DeX standalone mode set ||| "
    fi
}

# post_fs_process()
#   Post fs synchronous process at boot (main/entry)
post_fs_process() {
    pfp_original_filepath="$floating_feature_xml_fullpath"
    pfp_patched_filepath="$floating_feature_xml_patched_fullpath"
    pfp_key="$floating_feature_xml_dex_key"
    pfp_value="$floating_feature_xml_dex_key_value"

    echo " [INFO] Starting patching process" > "$logfile"

    module_set_message ""
    if file_set_xml_key "$pfp_original_filepath" "$pfp_patched_filepath" "$pfp_key" "$pfp_value"; then
        set_permissions "$pfp_patched_filepath"
        mount_file "$pfp_patched_filepath" "$pfp_original_filepath"
    fi
    
    module_set_status
    echo " [INFO] Finished patching process" >> "$logfile"
}

post_fs_process