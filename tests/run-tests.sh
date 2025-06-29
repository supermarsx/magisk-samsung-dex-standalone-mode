#!/bin/bash
set -e

export logfile=/tmp/test.log
# Ensure clean log for each run
: > "$logfile"
export MODPATH=/tmp/mod
mkdir -p "$MODPATH"

ui_print() { :; }
abort() { return 1; }
chcon() { true; }
set_perm_recursive() { true; }
umount() { return "${UMOUNT_RC:-0}"; }

# Source scripts without executing main
# Generate temporary versions of the sourced scripts without their final lines
sed '$d' post-fs-data.sh > /tmp/pfsd.sh
# shellcheck source=/tmp/pfsd.sh disable=SC1091
. /tmp/pfsd.sh
sed '$d' customize.sh > /tmp/customize.sh
# shellcheck source=/tmp/customize.sh disable=SC1091
. /tmp/customize.sh
sed '$d' build-tools/debug-unmount.sh > /tmp/debug-unmount.sh
# shellcheck source=/tmp/debug-unmount.sh disable=SC1091
. /tmp/debug-unmount.sh
# Re-source post-fs-data functions to override debug replacements
. /tmp/pfsd.sh
# Restore customize functions overridden above
. /tmp/customize.sh

logfile="/tmp/test.log"
module_prop_fullpath="/tmp/module.prop"
echo "description=" > "$module_prop_fullpath"

# Environment for install_process tests
module_path="/tmp/modules"
floating_feature_xml_dir="/tmp/"
floating_feature_xml_fullpath="${floating_feature_xml_dir}${floating_feature_xml_file}"
floating_feature_xml_original_fullpath="$floating_feature_xml_fullpath"
floating_feature_xml_patched_fullpath="$module_path/$module_name/$floating_feature_xml_patched_file"
mkdir -p "$(dirname "$floating_feature_xml_patched_fullpath")"
touch "$floating_feature_xml_fullpath"

install_process_wrapper() {
  ( set -e; install_process )
}

failure=0

assert_return() {
  expected=$1
  shift
  set +e
  "$@"
  rc=$?
  set -e
  if [ "$rc" -ne "$expected" ]; then
    echo "FAILED: $* - expected $expected got $rc"
    failure=1
  else
    echo "PASSED: $*"
  fi
}

touch /tmp/fileexists
assert_return 0 filepath_exists /tmp/fileexists
rm /tmp/fileexists
assert_return 1 filepath_exists /tmp/fileexists

echo '<a>bar</a>' > /tmp/test.xml
assert_return 0 file_key_exists /tmp/test.xml a
assert_return 1 file_key_exists /tmp/test.xml b

assert_return 0 is_empty ''
assert_return 1 is_empty 'abc'

cat > /tmp/test.prop <<PROP
prop=
PROP
assert_return 0 file_set_property_wrapper /tmp/test.prop prop value
if grep -q 'prop=value' /tmp/test.prop; then
  echo "PASSED: property set"
else
  echo "FAILED: property not set"
  failure=1
fi

# Test property prepend wrapper
cat > /tmp/prepend.prop <<PROP
prop=
PROP
assert_return 0 file_prepend_value_to_property_wrapper /tmp/prepend.prop prop prefix
if grep -q 'prop=prefix' /tmp/prepend.prop; then
  echo "PASSED: prepend value to property"
else
  echo "FAILED: prepend value to property"
  failure=1
fi

# Test module_set_message
assert_return 0 module_set_message "hello"
if grep -q 'description=hello' "$module_prop_fullpath"; then
  echo "PASSED: module set message"
else
  echo "FAILED: module set message"
  failure=1
fi

# Test error helper utilities
error_count=0
error_message=""
assert_return 0 increment_error_count
if [ "$error_count" -eq 1 ]; then
  echo "PASSED: increment_error_count"
else
  echo "FAILED: increment_error_count"
  failure=1
fi

assert_return 0 error_message_append "foo"
if [ "$error_message" = "foo failed;" ]; then
  echo "PASSED: error_message_append"
else
  echo "FAILED: error_message_append"
  failure=1
fi

assert_return 0 error_add "bar"
if [ "$error_count" -eq 2 ]; then
  echo "PASSED: error_add"
else
  echo "FAILED: error_add"
  failure=1
fi

# Direct property helpers
cat > /tmp/direct.prop <<PROP
prop=old
PROP
assert_return 0 file_set_property /tmp/direct.prop prop new
if grep -q 'prop=new' /tmp/direct.prop; then
  echo "PASSED: file_set_property"
else
  echo "FAILED: file_set_property"
  failure=1
fi

cat > /tmp/direct_prepend.prop <<PROP
prop=bar
PROP
assert_return 0 file_prepend_value_to_property /tmp/direct_prepend.prop prop prefix
if grep -q 'prop=prefixbar' /tmp/direct_prepend.prop; then
  echo "PASSED: file_prepend_value_to_property"
else
  echo "FAILED: file_prepend_value_to_property"
  failure=1
fi

# Module status helper
error_count=0
error_message=""
assert_return 0 module_set_status
if grep -q 'Samsung DeX standalone mode set' "$module_prop_fullpath"; then
  echo "PASSED: module_set_status ok"
else
  echo "FAILED: module_set_status ok"
  failure=1
fi

# Permission helper
touch /tmp/permfile
assert_return 0 set_permissions /tmp/permfile
if [ "$(stat -c %a /tmp/permfile)" = "644" ] && [ "$(stat -c %U:%G /tmp/permfile)" = "root:root" ]; then
  echo "PASSED: set_permissions"
else
  echo "FAILED: set_permissions"
  failure=1
fi

# Additional helpers
cat > /tmp/src.txt <<EOF
foo
EOF
assert_return 0 file_copy /tmp/src.txt /tmp/dst.txt
if [ -f /tmp/dst.txt ] && grep -q foo /tmp/dst.txt; then
  echo "PASSED: file copy"
else
  echo "FAILED: file copy"
  failure=1
fi

cat > /tmp/clear.prop <<PROP
prop=value
PROP
file_clear_property /tmp/clear.prop prop
assert_return 0 file_is_property_clean /tmp/clear.prop prop

echo '<a>foo bar</a>' > /tmp/contains.xml
assert_return 0 file_key_contains_value /tmp/contains.xml a foo
assert_return 1 file_key_contains_value /tmp/contains.xml a baz

module_remove_mark
if [ -f "$MODPATH/remove" ]; then
  echo "PASSED: module remove mark"
else
  echo "FAILED: module remove mark"
  failure=1
fi

# Test unmount utilities
UMOUNT_RC=0
out=$(unmount_file /tmp/test.unmount 2>&1)
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "PASSED: unmount_file success"
else
  echo "FAILED: unmount_file success"
  failure=1
fi
if echo "$out" | grep -q 'Unmount was successful.'; then
  echo "PASSED: unmount_file log success"
else
  echo "FAILED: unmount_file log success"
  failure=1
fi

UMOUNT_RC=1
out=$(unmount_file /tmp/test.unmount 2>&1 || true)
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "PASSED: unmount_file failure"
else
  echo "FAILED: unmount_file failure"
  failure=1
fi
if echo "$out" | grep -q 'Unmount failed.'; then
  echo "PASSED: unmount_file log failure"
else
  echo "FAILED: unmount_file log failure"
  failure=1
fi
if grep -q 'mount.bind' "$logfile"; then
  echo "PASSED: unmount_file error logged"
else
  echo "FAILED: unmount_file error logged"
  failure=1
fi

UMOUNT_RC=0
out=$(process_unmount 2>&1)
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "PASSED: process_unmount success"
else
  echo "FAILED: process_unmount success"
  failure=1
fi
if echo "$out" | grep -q 'Unmount was successful.'; then
  echo "PASSED: process_unmount log success"
else
  echo "FAILED: process_unmount log success"
  failure=1
fi

UMOUNT_RC=1
out=$(process_unmount 2>&1 || true)
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "PASSED: process_unmount failure"
else
  echo "FAILED: process_unmount failure"
  failure=1
fi
if echo "$out" | grep -q 'Unmount failed.'; then
  echo "PASSED: process_unmount log failure"
else
  echo "FAILED: process_unmount log failure"
  failure=1
fi
if grep -q 'mount.bind' "$logfile"; then
  echo "PASSED: process_unmount error logged"
else
  echo "FAILED: process_unmount error logged"
  failure=1
fi

# Test XML utilities
cat > /tmp/xml_add.xml <<EOF
<a>foo</a>
EOF
assert_return 0 file_add_xml_key_value /tmp/xml_add.xml a bar
if grep -q '<a>foo,bar</a>' /tmp/xml_add.xml; then
  echo "PASSED: add xml key value"
else
  echo "FAILED: add xml key value"
  failure=1
fi

cat > /tmp/xml_remove.xml <<EOF
<a>foo,bar,baz</a>
EOF
assert_return 0 file_remove_xml_key_value /tmp/xml_remove.xml a bar
if grep -q '<a>foo,baz</a>' /tmp/xml_remove.xml; then
  echo "PASSED: remove xml key value"
else
  echo "FAILED: remove xml key value"
  failure=1
fi

cat > /tmp/xml_commas.xml <<EOF
<a>foo,</a>
EOF
assert_return 0 file_remove_xml_key_commas /tmp/xml_commas.xml a
if grep -q '<a>foo</a>' /tmp/xml_commas.xml; then
  echo "PASSED: remove xml key commas"
else
  echo "FAILED: remove xml key commas"
  failure=1
fi

cat > /tmp/xml_orig.xml <<EOF
<a>foo</a>
EOF
assert_return 0 file_set_xml_key /tmp/xml_orig.xml /tmp/xml_patched.xml a bar
if grep -q '<a>foo,bar</a>' /tmp/xml_patched.xml; then
  echo "PASSED: set xml key"
else
  echo "FAILED: set xml key"
  failure=1
fi

# Test install_process behaviour
touch "$floating_feature_xml_patched_fullpath"
assert_return 0 install_process_wrapper
rm -f "$floating_feature_xml_patched_fullpath"
rm -f "$MODPATH/remove"
rm -f "$floating_feature_xml_fullpath"
assert_return 1 install_process_wrapper
if [ -f "$MODPATH/remove" ]; then
  echo "PASSED: install abort path"
else
  echo "FAILED: install abort path"
  failure=1
fi

# Build module creation test
assert_return 0 tests/test-build-create-module.sh

if [ "$failure" -eq 0 ]; then
  echo "All tests passed"
else
  echo "Some tests failed"
  exit 1
fi
