#!/usr/bin/env bats

# Define test directory paths
TEST_DIRECTORY="tests/sample_dir"
ONLY_EXTENSIONS_DIRECTORY="${TEST_DIRECTORY}/only_extensions"

# Load the helper functions
load ./test_helper.bash

# Helper function to check if the output contains a specific substring
function check_output_contains() {
    local expected="$1"
    [[ "${output}" == *"$expected"* ]]
}

@test "Test script with --help/-h flag and returns status 0" {
    run bash linkChecker.sh --help
    [ "$status" -eq 0 ]

    run bash linkChecker.sh -h
    [ "$status" -eq 0 ]
}

@test "Test if no parameters returns status 1 with correct error message" {
    run bash linkChecker.sh
    [ "$status" -eq 1 ]
    check_output_contains "Missing scan required parameters."
}

@test "Test if providing a non-directory returns status 1 with correct error message" {
    run bash linkChecker.sh "$TEST_DIRECTORY/test_links.txt"
    [ "$status" -eq 1 ]
    [[ "${output}" == *"Please provide a valid directory to scan."* ]]
}

@test "Test error_only parameter" {
    # Invalid value
    run bash linkChecker.sh "$TEST_DIRECTORY" test
    [ "$status" -eq 1 ]
    [[ "${output}" == *"Parameters must be either true or false."* ]]

    # Valid values
    run bash linkChecker.sh "$TEST_DIRECTORY" true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false
    [ "$status" -eq 0 ]
}

@test "Test links_with_file parameter" {
    # Invalid value
    run bash linkChecker.sh "$TEST_DIRECTORY" true test 
    [ "$status" -eq 1 ]
    [[ "${output}" == *"Parameters must be either true or false."* ]]

    # Valid values
    run bash linkChecker.sh "$TEST_DIRECTORY" true true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false false
    [ "$status" -eq 0 ]
}

@test "Test thread_count parameter" {
    # Invalid value
    run bash linkChecker.sh "$TEST_DIRECTORY" true false aa
    [ "$status" -eq 1 ]
    [[ "${output}" == *"THREAD_COUNT must be a positive integer."* ]]

    # Valid values
    run bash linkChecker.sh "$TEST_DIRECTORY" false false 12
    [ "$status" -eq 0 ]
}

@test "Test error_only=true, no INFO and WARN messages are logged" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true
    [ "$status" -eq 0 ]
    [[ "${output}" != *"[INFO]"* ]] && [[ "${output}" != *"[LINK OK]"* ]] && [[ "${output}" != *"[WARN]"* ]]
}

@test "Test link checking functionality" {
    run bash linkChecker.sh "$TEST_DIRECTORY"
    [ "$status" -eq 0 ]
    # Check if the output contains expected URL status
    check_output_contains "[LINK REDIRECT (301)] - https://www.github.com"
    check_output_contains "[LINK OK] - https://www.python.org"
    check_output_contains "[LINK OK] - https://www.youtube.com"
    check_output_contains "[LINK OK] - https://stackoverflow.com"
    check_output_contains "[LINK OK] - https://www.microsoft.com"
    check_output_contains "[LINK OK] - https://www.shellcheck.net"
    check_output_contains "[LINK OK] - https://github.com/microsoft"
    check_output_contains "[LINK OK] - https://github.com/KaganCanSit"
    check_output_contains "[LINK OK] - https://github.com/badges/shields"
    check_output_contains "[LINK OK] - https://github.com/odb/official-bash-logo"
    check_output_contains "[LINK OK] - https://github.com/NVIDIA/open-gpu-kernel-modules"
    check_output_contains "[LINK OK] - https://github.com/github/docs/blob/main/content/actions/learn-github-actions/understanding-github-actions.md"
    check_output_contains "[LINK OK] - https://git-scm.com/docs"
    check_output_contains "[LINK OK] - https://www.python.org/doc/"
    check_output_contains "[LINK OK] - https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging"
    check_output_contains "[LINK REDIRECT (302)] - https://www.python.org/dev/peps/pep-0008/"
    check_output_contains "[LINK OK] - https://git-scm.com/book/en/v2/Git-Tools-Submodules#_submodules"
    check_output_contains "[LINK OK] - https://en.wikipedia.org/wiki/Software_repository"
    check_output_contains "[LINK REDIRECT (301)] - http://tr.wikipedia.org/wiki/SSH"
    check_output_contains "[LINK OK] - https://tr.wikipedia.org/wiki/Markdown"
    check_output_contains "[LINK REDIRECT (301)] - https://docs.microsoft.com/en-us/azure/devops/"
    check_output_contains "[LINK OK] - https://github.com/features/actions"
    check_output_contains "[LINK OK] - https://stackoverflow.blog/"
    check_output_contains "[LINK OK] - https://www.microsoft.com/en-us/software-download/windows10"
    check_output_contains "[LINK REDIRECT (301)] - https://stackoverflow.com/questions/231767/what-does-the-yield-keyword-do"
    check_output_contains "[LINK OK] - https://www.python.org/downloads/release/python-391/#:~:text=Python%203.9.1%20is%20the%20first"
    check_output_contains "[LINK REDIRECT (301)] - http://opensource.org/licenses/MIT"
    check_output_contains "[LINK COULD NOT RESOLVE HOST] - http://remote_repository_address.git"
    check_output_contains "[LINK NOT FOUND] - https://www.microsoft.com/en-us/software-donwload/windows10"
    check_output_contains "[LINK NOT FOUND] - https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-HI-CocoaCore/index.html"
    check_output_contains "[LINK COULD NOT RESOLVE HOST] - https://aws.amazon/s3/?nc=h_l3c"
    check_output_contains "[LINK NOT FOUND] - https://support.google.com/google-ads/answer/2375466?hl=en&ref_topic=3119071"
    check_output_contains "[LINK NOT FOUND] - https://docs.github.com/e/rest/issues?apiVersion=2022-11-28"
    check_output_contains "[LINK NOT FOUND] - https://www.npmjs.com/package/packagefail"
    check_output_contains "[LINK NOT FOUND] - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Glabol_Objects/JSON/pars"
}

@test "Test when no links are found in the directory" {
    run bash linkChecker.sh "$ONLY_EXTENSIONS_DIRECTORY" false false
    [ "$status" -eq 0 ]
    [[ "${output}" == *"No links found to check."* ]]
}