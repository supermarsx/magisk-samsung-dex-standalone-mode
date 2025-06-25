#!/bin/bash
set -e

export logfile=/tmp/test.log
export MODPATH=/tmp/mod
mkdir -p "$MODPATH"

ui_print() { :; }
abort() { return 1; }
chcon() { true; }

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

logfile="/tmp/test.log"

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

if [ "$failure" -eq 0 ]; then
  echo "All tests passed"
else
  echo "Some tests failed"
  exit 1
fi
