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

# Test if the script runs without errors
@test "Check if script runs without errors" {
    run bash linkChecker.sh --help
    [ "$status" -eq 1 ]
}

# Test when no parameters are provided
@test "Check script with no parameters" {
    run bash linkChecker.sh false false
    [ "$status" -eq 1 ]
    # Check return message
    check_output_contains "Error: Please provide a valid directory to scan."
}

# Test with invalid first parameter (not a directory)
@test "Check script with invalid first parameter" {
    run bash linkChecker.sh "$TEST_DIRECTORY/test_links.txt"
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Please provide a valid directory to scan."* ]]
}

# Test error_only parameter with invalid value
@test "Check error_only parameter with invalid value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" test
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Parameters must be either true or false."* ]]

    run bash linkChecker.sh "$TEST_DIRECTORY" true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false
    [ "$status" -eq 0 ]
}

# Test links_with_file parameter with invalid value
@test "Check links_with_file parameter with invalid value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true test 
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Parameters must be either true or false."* ]]

    run bash linkChecker.sh "$TEST_DIRECTORY" true true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false false
    [ "$status" -eq 0 ]
}

# Test thread_count parameter with invalid value
@test "Check thread_count parameter with invalid value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true false aa
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: THREAD_COUNT must be a positive integer."* ]]

    run bash linkChecker.sh "$TEST_DIRECTORY" false false 12
    [ "$status" -eq 0 ]
}

# Test the error_only flag
@test "Check error_only flag" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true
    [ "$status" -eq 0 ]
    # Only errors and warnings should be present in the output
    [[ "${output}" != *"[INFO]"* ]] && [[ "${output}" != *"[LINK OK]"* ]]
}

# Test link checking functionality
@test "Check link checking functionality" {
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

# Test when there are no links to check in a directory
@test "Check when no links to check in directory" {
    run bash linkChecker.sh "$ONLY_EXTENSIONS_DIRECTORY" false false
    [ "$status" -eq 0 ]
    # Check if the output contains expected message
    [[ "${output}" == *"No links found to check."* ]]
}