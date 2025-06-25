#!/bin/bash
set -e

export logfile=/tmp/test.log
export MODPATH=/tmp/mod
mkdir -p "$MODPATH"

ui_print() { :; }
abort() { return 1; }
chcon() { true; }

# Source scripts without executing main
sed '$d' post-fs-data.sh > /tmp/pfsd.sh
. /tmp/pfsd.sh
sed '$d' customize.sh > /tmp/customize.sh
. /tmp/customize.sh
sed '$d' build-tools/debug-unmount.sh > /tmp/debug-unmount.sh
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
assert_return 0 file_key_exists /tmp/test.xml '<a>'
assert_return 1 file_key_exists /tmp/test.xml '<b>'

assert_return 0 is_empty ''
assert_return 1 is_empty 'abc'

cat > /tmp/test.prop <<PROP
prop=
PROP
assert_return 0 file_set_property_wrapper /tmp/test.prop prop value
grep -q 'prop=value' /tmp/test.prop && echo "PASSED: property set" || { echo "FAILED: property not set"; failure=1; }

if [ $failure -eq 0 ]; then
  echo "All tests passed"
else
  echo "Some tests failed"
  exit 1
fi
