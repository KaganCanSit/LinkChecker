#!/usr/bin/env bats

TEST_DIRECTORY="tests/sample_dir"
TEST_ONLY_EXTENSIONS_DIRECTORY="${TEST_DIRECTORY}/only_extensions"

# Load the helper functions
load ./test_helper.bash

# Test if the script runs without errors
@test "Check if script runs without errors" {
    run bash linkChecker.sh --help
    [ "$status" -eq 1 ]
}

# If not set any parameters show help
@test "Check any parameters have" {
    run bash linkChecker.sh
    [ "$status" -eq 1 ]
}

# Check parameters only directory
@test "Check first parameters directory" {
    run bash linkChecker.sh "$TEST_DIRECTORY/empty.txt"
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Please provide a valid directory to scan."* ]]   
}

# Check error_only only parameters value true/false
@test "Check error_only parameters value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" test
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Parameters must be either true or false."* ]]

    run bash linkChecker.sh "$TEST_DIRECTORY" true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false
    [ "$status" -eq 0 ]
}

# Check links_with_file only parameters value true/false
@test "Check links_with_file parameters value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true test 
    [ "$status" -eq 1 ]
    # Check return message
    [[ "${output}" == *"Error: Parameters must be either true or false."* ]]

    run bash linkChecker.sh "$TEST_DIRECTORY" true true
    [ "$status" -eq 0 ]

    run bash linkChecker.sh "$TEST_DIRECTORY" false false
    [ "$status" -eq 0 ]
}

# Check thread_count only parameters value numeric
@test "Check thread_count parameters value" {
    run bash linkChecker.sh "$TEST_DIRECTORY" true false aa
    [ "$status" -eq 1 ]
    # Check return message
    echo "${output}"
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

# Links check
@test "Check return output only errors" {
    run bash linkChecker.sh "$TEST_DIRECTORY"
    [ "$status" -eq 0 ]
    # Check if the output contains expected URL status
    [[ "${output}" == *"[LINK REDIRECT (301)] - https://www.github.com"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.python.org"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.youtube.com"* ]]
    [[ "${output}" == *"LINK OK] - https://stackoverflow.com"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.microsoft.com"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.shellcheck.net"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/microsoft"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/KaganCanSit"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/badges/shields"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/odb/official-bash-logo"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/NVIDIA/open-gpu-kernel-modules"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/github/docs/blob/main/content/actions/learn-github-actions/understanding-github-actions.md"* ]]
    [[ "${output}" == *"[LINK OK] - https://git-scm.com/docs"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.python.org/doc/"* ]]
    [[ "${output}" == *"[LINK OK] - https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging"* ]]
    [[ "${output}" == *"[LINK REDIRECT (302)] - https://www.python.org/dev/peps/pep-0008/"* ]]
    [[ "${output}" == *"[LINK OK] - https://git-scm.com/book/en/v2/Git-Tools-Submodules#_submodules"* ]]
    [[ "${output}" == *"[LINK OK] - https://en.wikipedia.org/wiki/Software_repository"* ]]
    [[ "${output}" == *"[LINK REDIRECT (301)] - http://tr.wikipedia.org/wiki/SSH"* ]]
    [[ "${output}" == *"[LINK OK] - https://tr.wikipedia.org/wiki/Markdown"* ]]
    [[ "${output}" == *"[LINK REDIRECT (301)] - https://docs.microsoft.com/en-us/azure/devops/"* ]]
    [[ "${output}" == *"[LINK OK] - https://github.com/features/actions"* ]]
    [[ "${output}" == *"[LINK OK] - https://stackoverflow.blog/"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.microsoft.com/en-us/software-download/windows10"* ]]
    [[ "${output}" == *"[LINK REDIRECT (301)] - https://stackoverflow.com/questions/231767/what-does-the-yield-keyword-do"* ]]
    [[ "${output}" == *"[LINK OK] - https://www.python.org/downloads/release/python-391/#:~:text=Python%203.9.1%20is%20the%20first"* ]]
    [[ "${output}" == *"[LINK REDIRECT (301)] - http://opensource.org/licenses/MIT"* ]]
    [[ "${output}" == *"[LINK COULD NOT RESOLVE HOST] - http://remote_repository_address.git"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://www.microsoft.com/en-us/software-donwload/windows10"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-HI-CocoaCore/index.html"* ]]
    [[ "${output}" == *"[LINK COULD NOT RESOLVE HOST] - https://aws.amazon/s3/?nc=h_l3c"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://support.google.com/google-ads/answer/2375466?hl=en&ref_topic=3119071"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://docs.github.com/e/rest/issues?apiVersion=2022-11-28"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://www.npmjs.com/package/packagefail"* ]]
    [[ "${output}" == *"[LINK NOT FOUND] - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Glabol_Objects/JSON/pars"* ]]
}

# Extensions remove check
@test "Check only extensions links output" {
    run bash linkChecker.sh "$TEST_ONLY_EXTENSIONS_DIRECTORY" false false
    [ "$status" -eq 0 ]
    # Check if the output contains expected URL status
    [[ "${output}" == *"No links found to check."* ]]
}
