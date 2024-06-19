#!/usr/bin/env bash

TEST_DIRECTORY="tests/sample_dir"
TEST_ONLY_EXTENSIONS_DIRECTORY="${TEST_DIRECTORY}/only_extensions"

TEST_EMPTY_TXT="${TEST_DIRECTORY}/empty.txt"
TEST_LINKS_TXT="${TEST_DIRECTORY}/test_links.txt"
TEST_LINKS_OUTPUT_TXT="${TEST_DIRECTORY}/test_links_output.txt"
ONLY_EXTENSIONS_LINKS_TXT="${TEST_DIRECTORY}/only_extensions_links.txt"

function create_directory() {
    local directory="$1"

    if ! mkdir -p "$directory"; then
        echo "$directory directory create failed!"
        exit 1
    fi
}

function file_create() {
    local file="$1"

    if ! touch "$file"; then
        echo "$file file create failed!"
        exit 1
    fi
}


function create_test_links_file() {
    file_create "$TEST_LINKS_TXT"

    cat <<EOL >"$TEST_LINKS_OUTPUT_TXT"
https://www.github.com
https://www.youtube.com
https://www.python.org
https://stackoverflow.com
https://www.microsoft.com
https://www.shellcheck.net

https://github.com/microsoft
https://github.com/KaganCanSit
https://github.com/badges/shields
https://github.com/odb/official-bash-logo
https://github.com/NVIDIA/open-gpu-kernel-modules
https://github.com/github/docs/blob/main/content/actions/learn-github-actions/understanding-github-actions.md

http://opensource.org/licenses/MIT
https://git-scm.com/docs
https://www.python.org/doc/
https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging
https://www.python.org/dev/peps/pep-0008/
https://git-scm.com/book/en/v2/Git-Tools-Submodules#_submodules

https://en.wikipedia.org/wiki/Software_repository
http://tr.wikipedia.org/wiki/SSH
https://tr.wikipedia.org/wiki/Markdown

https://docs.microsoft.com/en-us/azure/devops/
https://github.com/features/actions
https://stackoverflow.blog/
https://www.microsoft.com/en-us/software-download/windows10
https://stackoverflow.com/questions/231767/what-does-the-yield-keyword-do
https://www.python.org/downloads/release/python-391/#:~:text=Python%203.9.1%20is%20the%20first,language%20and%20extensive%20standard%20library

http://remote_repository_address.git
https://www.microsoft.com/en-us/software-donwload/windows10
https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-HI-CocoaCore/index.html
https://aws.amazon/s3s3s
https://aws.amazon/s3/?nc=h_l3c
https://support.google.com/google-ads/answer/2375466?hl=en&ref_topic=3119071
https://docs.github.com/e/rest/issues?apiVersion=2022-11-28
https://www.npmjs.com/package/packagefail
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Glabol_Objects/JSON/pars
EOL
}

function create_only_extensions_links_file() {
    file_create "$ONLY_EXTENSIONS_LINKS_TXT"

    cat <<EOL >"$ONLY_EXTENSIONS_LINKS_TXT"
http://www
http://www.
https://www.
http://.com
https://.com
https://www..com
https://www..org
https://www..net
EOL
}

# Setup and teardown hooks for bats
# Helper function to create sample directory and files for testing
function setup() {
    create_directory "$TEST_DIRECTORY"
    file_create "$TEST_EMPTY_TXT"
    create_test_links_file

    create_directory "$TEST_ONLY_EXTENSIONS_DIRECTORY"
    create_only_extensions_links_file
}

# Cleanup function to remove the sample directory after tests
function teardown() {
    if ! rm -rf "$TEST_DIRECTORY"; then
        echo "$TEST_DIRECTORY directory remove failed!"
        exit 1
    fi
}