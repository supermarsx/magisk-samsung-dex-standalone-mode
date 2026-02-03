#!/bin/bash
# Tests for release-related scripts:
# - build-tools/set-version.sh
# - build-tools/update-changelog.sh
# - scripts/check-version.sh
# - scripts/build-and-commit.sh (partial - no git operations)

set -euo pipefail

# Test utilities
TMPDIR=""
failure=0

setup() {
	TMPDIR=$(mktemp -d)
	cd "$TMPDIR"
}

teardown() {
	cd /
	rm -rf "$TMPDIR"
}

pass() {
	echo "PASSED: $1"
}

fail() {
	echo "FAILED: $1"
	failure=1
}

assert_file_contains() {
	local file=$1
	local pattern=$2
	local msg=$3
	if grep -q "$pattern" "$file"; then
		pass "$msg"
	else
		fail "$msg - pattern '$pattern' not found in $file"
		echo "File contents:"
		cat "$file"
	fi
}

assert_file_not_contains() {
	local file=$1
	local pattern=$2
	local msg=$3
	if ! grep -q "$pattern" "$file"; then
		pass "$msg"
	else
		fail "$msg - pattern '$pattern' unexpectedly found in $file"
	fi
}

assert_exit_code() {
	local expected=$1
	local actual=$2
	local msg=$3
	if [ "$actual" -eq "$expected" ]; then
		pass "$msg"
	else
		fail "$msg - expected exit code $expected, got $actual"
	fi
}

# Get the repo root (parent of tests directory)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#######################################
# Tests for set-version.sh
#######################################

test_set_version_updates_module_prop() {
	setup
	cat >module.prop <<EOF
id=test-module
name=Test Module
version=1.0.0
versionCode=1
author=test
description=Test
EOF
	cat >update.json <<EOF
{
    "version": "1.0.0",
    "versionCode": 1
}
EOF

	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.5" "42"

	assert_file_contains module.prop "^version=2026.5$" "set-version updates version in module.prop"
	assert_file_contains module.prop "^versionCode=42$" "set-version updates versionCode in module.prop"
	teardown
}

test_set_version_updates_update_json() {
	setup
	cat >module.prop <<EOF
id=test-module
version=1.0.0
versionCode=1
EOF
	cat >update.json <<EOF
{
    "version": "1.0.0",
    "versionCode": 1,
    "zipUrl": "https://example.com/test.zip"
}
EOF

	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.5" "42"

	assert_file_contains update.json '"version": "2026.5"' "set-version updates version in update.json"
	assert_file_contains update.json '"versionCode": "42"' "set-version updates versionCode as string in update.json"
	teardown
}

test_set_version_fails_without_args() {
	setup
	set +e
	bash "$REPO_ROOT/build-tools/set-version.sh" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "set-version fails without arguments"
	teardown
}

test_set_version_fails_with_one_arg() {
	setup
	set +e
	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.1" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "set-version fails with only one argument"
	teardown
}

test_set_version_fails_missing_module_prop() {
	setup
	cat >update.json <<EOF
{"version": "1.0.0", "versionCode": 1}
EOF
	set +e
	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.1" "5" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "set-version fails when module.prop is missing"
	teardown
}

test_set_version_fails_missing_update_json() {
	setup
	cat >module.prop <<EOF
version=1.0.0
versionCode=1
EOF
	set +e
	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.1" "5" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "set-version fails when update.json is missing"
	teardown
}

test_set_version_preserves_other_fields() {
	setup
	cat >module.prop <<EOF
id=samsung-dex-standalone-mode
name=Samsung DeX standalone mode
version=2025.1
versionCode=3
author=supermarsx
description=Test description
updateJson=https://example.com/update.json
EOF
	cat >update.json <<EOF
{
    "version": "2025.1",
    "versionCode": 3,
    "zipUrl": "https://github.com/example/test.zip",
    "changelog": "https://example.com/changelog.md"
}
EOF

	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.1" "4"

	assert_file_contains module.prop "^id=samsung-dex-standalone-mode$" "set-version preserves id"
	assert_file_contains module.prop "^author=supermarsx$" "set-version preserves author"
	assert_file_contains update.json "zipUrl" "set-version preserves zipUrl"
	assert_file_contains update.json "changelog" "set-version preserves changelog"
	teardown
}

#######################################
# Tests for update-changelog.sh
#######################################

test_update_changelog_prepends_entry() {
	setup
	cat >changelog.md <<EOF
# Changelog

## v1.0.0 - 2025-01-01
- Initial release
EOF
	cat >notes.txt <<EOF
- Added new feature
- Fixed bug
EOF

	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.1" "notes.txt"

	# Check new entry is at the top
	head -1 changelog.md | grep -q "## v2026.1"
	if [ $? -eq 0 ]; then
		pass "update-changelog prepends new version header"
	else
		fail "update-changelog prepends new version header"
	fi

	assert_file_contains changelog.md "Added new feature" "update-changelog includes notes content"
	assert_file_contains changelog.md "Initial release" "update-changelog preserves old content"
	teardown
}

test_update_changelog_includes_date() {
	setup
	cat >changelog.md <<EOF
# Old changelog
EOF
	cat >notes.txt <<EOF
- Test note
EOF

	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.2" "notes.txt"

	local today
	today=$(date +%Y-%m-%d)
	assert_file_contains changelog.md "## v2026.2 - $today" "update-changelog includes today's date"
	teardown
}

test_update_changelog_fails_without_args() {
	setup
	set +e
	bash "$REPO_ROOT/build-tools/update-changelog.sh" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "update-changelog fails without arguments"
	teardown
}

test_update_changelog_fails_missing_notes_file() {
	setup
	cat >changelog.md <<EOF
# Changelog
EOF
	set +e
	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.1" "nonexistent.txt" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "update-changelog fails when notes file is missing"
	teardown
}

test_update_changelog_fails_missing_changelog() {
	setup
	cat >notes.txt <<EOF
- Test
EOF
	set +e
	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.1" "notes.txt" 2>/dev/null
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "update-changelog fails when changelog.md is missing"
	teardown
}

test_update_changelog_handles_empty_notes() {
	setup
	cat >changelog.md <<EOF
# Changelog
EOF
	touch notes.txt

	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.3" "notes.txt"

	assert_file_contains changelog.md "## v2026.3" "update-changelog works with empty notes"
	teardown
}

test_update_changelog_handles_multiline_notes() {
	setup
	cat >changelog.md <<EOF
# Old
EOF
	cat >notes.txt <<EOF
- Feature 1
- Feature 2
- Feature 3

### Breaking changes
- Removed old API
EOF

	bash "$REPO_ROOT/build-tools/update-changelog.sh" "3.0.0" "notes.txt"

	assert_file_contains changelog.md "Feature 1" "update-changelog includes first line"
	assert_file_contains changelog.md "Feature 3" "update-changelog includes all features"
	assert_file_contains changelog.md "Breaking changes" "update-changelog includes subsections"
	assert_file_contains changelog.md "Removed old API" "update-changelog includes breaking changes"
	teardown
}

#######################################
# Tests for check-version.sh
#######################################

test_check_version_passes_when_synced() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=3
EOF
	cat >update.json <<EOF
{
    "version": "2025.1",
    "versionCode": 3
}
EOF

	set +e
	bash "$REPO_ROOT/scripts/check-version.sh"
	local rc=$?
	set -e
	assert_exit_code 0 "$rc" "check-version passes when versions are synced"
	teardown
}

test_check_version_fails_version_mismatch() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=3
EOF
	cat >update.json <<EOF
{
    "version": "2026.1",
    "versionCode": 3
}
EOF

	set +e
	local output
	output=$(bash "$REPO_ROOT/scripts/check-version.sh" 2>&1)
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "check-version fails on version mismatch"
	if echo "$output" | grep -q "Version mismatch"; then
		pass "check-version reports version mismatch"
	else
		fail "check-version reports version mismatch"
	fi
	teardown
}

test_check_version_fails_versioncode_mismatch() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=3
EOF
	cat >update.json <<EOF
{
    "version": "2025.1",
    "versionCode": 5
}
EOF

	set +e
	local output
	output=$(bash "$REPO_ROOT/scripts/check-version.sh" 2>&1)
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "check-version fails on versionCode mismatch"
	if echo "$output" | grep -q "VersionCode mismatch"; then
		pass "check-version reports versionCode mismatch"
	else
		fail "check-version reports versionCode mismatch"
	fi
	teardown
}

test_check_version_handles_integer_versioncode() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=42
EOF
	cat >update.json <<EOF
{
    "version": "2025.1",
    "versionCode": 42
}
EOF

	set +e
	bash "$REPO_ROOT/scripts/check-version.sh"
	local rc=$?
	set -e
	assert_exit_code 0 "$rc" "check-version handles integer versionCode in JSON"
	teardown
}

test_check_version_detects_both_mismatches() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=3
EOF
	cat >update.json <<EOF
{
    "version": "2026.1",
    "versionCode": 5
}
EOF

	set +e
	local output
	output=$(bash "$REPO_ROOT/scripts/check-version.sh" 2>&1)
	local rc=$?
	set -e
	assert_exit_code 1 "$rc" "check-version fails on both mismatches"
	if echo "$output" | grep -q "Version mismatch" && echo "$output" | grep -q "VersionCode mismatch"; then
		pass "check-version reports both mismatches"
	else
		fail "check-version reports both mismatches"
	fi
	teardown
}

test_check_version_handles_whitespace_in_json() {
	setup
	cat >module.prop <<EOF
version=2025.1
versionCode=3
EOF
	cat >update.json <<EOF
{
    "version"   :   "2025.1",
    "versionCode"  :  3
}
EOF

	set +e
	bash "$REPO_ROOT/scripts/check-version.sh"
	local rc=$?
	set -e
	assert_exit_code 0 "$rc" "check-version handles extra whitespace in JSON"
	teardown
}

#######################################
# Tests for version increment logic (from build-and-commit.sh)
#######################################

test_version_increment_same_year() {
	setup
	local current_year
	current_year=$(date +%Y)
	cat >module.prop <<EOF
version=${current_year}.5
versionCode=5
EOF
	cat >update.json <<EOF
{
    "version": "${current_year}.5",
    "versionCode": 5
}
EOF

	# Extract and test version increment logic
	current_version="${current_year}.5"
	current_year_from_version=${current_version%%.*}
	current_increment=${current_version##*.}

	if [ "$current_year" = "$current_year_from_version" ]; then
		new_increment=$((current_increment + 1))
	else
		new_increment=1
	fi
	new_version="${current_year}.${new_increment}"

	if [ "$new_version" = "${current_year}.6" ]; then
		pass "version increment: same year increments counter"
	else
		fail "version increment: same year increments counter - got $new_version"
	fi
	teardown
}

test_version_increment_new_year() {
	setup
	# Simulate a version from last year
	local current_year
	current_year=$(date +%Y)
	local last_year=$((current_year - 1))

	current_version="${last_year}.99"
	current_year_from_version=${current_version%%.*}
	current_increment=${current_version##*.}

	if [ "$current_year" != "$current_year_from_version" ]; then
		new_increment=1
	else
		new_increment=$((current_increment + 1))
	fi
	new_version="${current_year}.${new_increment}"

	if [ "$new_version" = "${current_year}.1" ]; then
		pass "version increment: new year resets counter to 1"
	else
		fail "version increment: new year resets counter to 1 - got $new_version"
	fi
	teardown
}

#######################################
# Integration tests
#######################################

test_set_version_then_check_version() {
	setup
	cat >module.prop <<EOF
version=1.0.0
versionCode=1
EOF
	cat >update.json <<EOF
{
    "version": "1.0.0",
    "versionCode": 1
}
EOF

	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.10" "100"

	set +e
	bash "$REPO_ROOT/scripts/check-version.sh"
	local rc=$?
	set -e

	assert_exit_code 0 "$rc" "integration: set-version followed by check-version passes"
	teardown
}

test_update_changelog_multiple_times() {
	setup
	cat >changelog.md <<EOF
# Changelog
EOF

	echo "- First release" >notes1.txt
	bash "$REPO_ROOT/build-tools/update-changelog.sh" "1.0.0" "notes1.txt"

	echo "- Second release" >notes2.txt
	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2.0.0" "notes2.txt"

	# Check order: newest should be first
	local first_version
	first_version=$(grep -m1 "^## v" changelog.md | sed 's/## v\([^ ]*\).*/\1/')

	if [ "$first_version" = "2.0.0" ]; then
		pass "integration: multiple changelog updates maintain order"
	else
		fail "integration: multiple changelog updates maintain order - first was $first_version"
	fi

	assert_file_contains changelog.md "First release" "integration: old changelog entries preserved"
	assert_file_contains changelog.md "Second release" "integration: new changelog entries added"
	teardown
}

test_full_release_flow() {
	setup
	# Setup initial state
	cat >module.prop <<EOF
id=test-module
name=Test Module
version=2025.1
versionCode=3
author=test
description=Test module
EOF
	cat >update.json <<EOF
{
    "version": "2025.1",
    "versionCode": 3,
    "zipUrl": "https://example.com/test.zip",
    "changelog": "https://example.com/changelog.md"
}
EOF
	cat >changelog.md <<EOF
# Test Changelog

## v2025.1 - 2025-01-01
- Previous release
EOF
	cat >notes.txt <<EOF
- New feature X
- Bug fix Y
EOF

	# Run the release flow (without git operations)
	bash "$REPO_ROOT/build-tools/set-version.sh" "2026.1" "4"
	bash "$REPO_ROOT/build-tools/update-changelog.sh" "2026.1" "notes.txt"

	# Verify everything is updated correctly
	assert_file_contains module.prop "^version=2026.1$" "full flow: module.prop version updated"
	assert_file_contains module.prop "^versionCode=4$" "full flow: module.prop versionCode updated"
	assert_file_contains update.json '"version": "2026.1"' "full flow: update.json version updated"
	assert_file_contains update.json '"versionCode": 4' "full flow: update.json versionCode updated"
	assert_file_contains changelog.md "## v2026.1" "full flow: changelog has new version"
	assert_file_contains changelog.md "New feature X" "full flow: changelog has notes"
	assert_file_contains changelog.md "Previous release" "full flow: changelog preserves history"

	# Verify versions are in sync
	set +e
	bash "$REPO_ROOT/scripts/check-version.sh"
	local rc=$?
	set -e
	assert_exit_code 0 "$rc" "full flow: versions are in sync after release"

	teardown
}

#######################################
# Run all tests
#######################################

echo "=== Testing set-version.sh ==="
test_set_version_updates_module_prop
test_set_version_updates_update_json
test_set_version_fails_without_args
test_set_version_fails_with_one_arg
test_set_version_fails_missing_module_prop
test_set_version_fails_missing_update_json
test_set_version_preserves_other_fields

echo ""
echo "=== Testing update-changelog.sh ==="
test_update_changelog_prepends_entry
test_update_changelog_includes_date
test_update_changelog_fails_without_args
test_update_changelog_fails_missing_notes_file
test_update_changelog_fails_missing_changelog
test_update_changelog_handles_empty_notes
test_update_changelog_handles_multiline_notes

echo ""
echo "=== Testing check-version.sh ==="
test_check_version_passes_when_synced
test_check_version_fails_version_mismatch
test_check_version_fails_versioncode_mismatch
test_check_version_handles_integer_versioncode
test_check_version_detects_both_mismatches
test_check_version_handles_whitespace_in_json

echo ""
echo "=== Testing version increment logic ==="
test_version_increment_same_year
test_version_increment_new_year

echo ""
echo "=== Integration tests ==="
test_set_version_then_check_version
test_update_changelog_multiple_times
test_full_release_flow

echo ""
if [ "$failure" -eq 0 ]; then
	echo "All release script tests passed!"
	exit 0
else
	echo "Some release script tests failed!"
	exit 1
fi
