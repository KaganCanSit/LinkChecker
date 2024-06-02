#!/bin/bash

# Outside parameter
SCAN_DIRECTORY="$1"
ERROR_ONLY=${2:-false}
LINKS_WITH_FILE=${3:-false}
THREAD_COUNT=${4:-10}

# --------------------------------------- Script Requirements Check ----------------------------------------------
if [ "$#" -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
cat <<EOF
Usage: $0 <directory> <error_only> <links_with_file> <thread_count>
Parameters:
    * <directory> - Directory address where links will be scanned.
    * <error_only> - Flag that ensures that only ERROR logs will be written. (Default: false)
    * <links_with_file> - Prints the files containing the link. (Default: false)
    * <thread_count> - The number of threads to use for scanning. (Default: 10)
Example:
    $0 /path/to/directory true true 20
EOF
    exit 1
fi

# Check if SCAN_DIRECTORY is provided and exists
if [ -z "$SCAN_DIRECTORY" ] || [ ! -d "$SCAN_DIRECTORY" ]; then
    echo "Error: Please provide a valid directory to scan."
    exit 1
fi

# Check if ERROR_ONLY and WRITE_TO_FILE are true or false
for param in "$ERROR_ONLY" "$LINKS_WITH_FILE"; do
    if [[ "$param" != "true" && "$param" != "false" ]]; then
        echo "Error: Parameters must be either true or false."
        exit 1
    fi
done

# Check if THREAD_COUNT is provided and is a positive integer
if ! [[ "$THREAD_COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: THREAD_COUNT must be a positive integer."
    exit 1
fi

# Check if required packages are installed
for package_name in curl parallel; do
    if ! command -v "$package_name" &>/dev/null; then
        echo "'$package_name' is not installed. Do you want to install it now? (yes/no)"
        read -r response
        if [[ "$response" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
            # Operation system check
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                if command -v apt-get &>/dev/null; then
                    sudo apt-get install "$package_name"
                elif command -v yum &>/dev/null; then
                    sudo yum install "$package_name"
                elif command -v pacman &>/dev/null; then
                    sudo pacman -S "$package_name"
                else
                    echo "Unsupported package manager. Please install $package_name manually."
                    exit 1
                fi
            else
                echo "Unsupported operating system. Please install $package_name manually."
                exit 1
            fi
        else
            echo "$package_name is required for this script to run. Please install $package_name and try again."
            exit 1
        fi
    fi
done

# ------------------------------------------------ Functions -------------------------------------------------
function log() {
    local level="$1"
    local message="$2"
    local files=("${@:3}")

    local color_reset='\033[0m'
    local color_red='\033[31m'
    local color_green='\033[32m'
    local color_yellow='\033[33m'

    case "$level" in
    "ERROR")
        color="$color_red";;
    "WARN")
        color="$color_yellow";;
    "INFO")
        color="$color_green";;
    *)
        color="$color_reset";;
    esac

    # Print only error log
    if [ "$ERROR_ONLY" == "true" ] && [ "$level" != "ERROR" ]; then
        return
    fi

    echo -e "${color}[$level]\t$message${color_reset}"
    if [[ "$LINKS_WITH_FILE" == "true" && ${#files[@]} -gt 0 ]]; then
        for file in "${files[@]}"; do
            echo -e "\tFile: $file"
        done
    fi
}

# Function to find links in files within a directory
function find_links() {
    local dir="$1"
    local found_links=()

    #ShellCheck warning - Declare and assign separately to avoid masking return values
    local file
    local links

    # Scan all files in the directory
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            links=$(grep -soP 'https?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+(?![\w\/:%#\$&\?\(\)~\.=\+\-])' "$file")
            if [[ -n "$links" ]]; then
                while IFS= read -r link; do
                    link=$(echo "$link" | sed 's/)//g' | sed 's/\.$//' | sed 's/&gt//g')
                    if [ -n "$link" ]; then
                        found_links+=("$link|$file")
                    fi
                done <<<"$links"
            fi
        fi
    done < <(find "$dir" -type f -print0)

    sorted_unique_links=$(printf "%s\n" "${found_links[@]}" | sort -u)

    # Check if any links are found
    if [ ${#sorted_unique_links[@]} -eq 0 ]; then
        log "ERROR" "No links found in the specified directory."
        exit 1
    fi
    echo "$sorted_unique_links"
}

# Function to check the status of a link
function check_link() {
    local link="$1"
    local response
    local http_code
    local curl_exit_code
    local files=("${@:2}")

    # Get the response header and capture the error code
    response=$(curl -IsS "$link" 2>&1)
    curl_exit_code=$?

    # Check for common curl error codes and provide meaningful messages
    if [[ $curl_exit_code -ne 0 ]]; then
        handle_curl_error "$curl_exit_code" "$link" "${files[@]}"
        return 1
    fi

    # If the response is empty, the server is unreachable
    if [[ -z "$response" ]]; then
        log "ERROR" "Unable to connect to the server: $link" "${files[@]}"
        return 1
    fi

    # Get the HTTP status code
    http_code=$(echo "$response" | awk 'NR==1{print $2}')

    # Handle specific HTTP status codes that indicate the link is still valid
    handle_http_code "$http_code" "$link" "${files[@]}"
    return 0
}

# Function to handle common curl errors
function handle_curl_error() {
    local error_code="$1"
    local link="$2"
    local files=("${@:3}")

    local log_level="ERROR"
    local log_message=""

    case $error_code in
    6)
        log_message="[LINK COULD NOT RESOLVE HOST]";;
    7)
        log_message="[LINK FAILED TO CONNECT TO HOST]";;
    23)
        log_message="[LINK FAILED WRITING BODY]";;
    35)
        log_message="[SSL HANDSHAKE FAILED]";;
    60)
        log_message="[SSL CERTIFICATE PROBLEM]";;
    *)
        log_message="[LINK CURL ERROR $error_code]";;
    esac
    log "$log_level" "$log_message - $link" "${files[@]}"
}

# Function to handle HTTP status codes
function handle_http_code() {
    local http_code="$1"
    local link="$2"
    local files=("${@:3}")

    local log_level="WARN"
    local log_message=""

    case $http_code in
    103)
        log_level="INFO"
        log_message="[LINK EARLY HINTS]";;
    200 | 201 | 202)
        log_level="INFO"
        log_message="[LINK OK]";;
    204)
        log_message="[LINK NO CONTENT]";;
    301 | 302 | 303 | 304 | 308)
        log_level="INFO"
        log_message="[LINK REDIRECT ($http_code)]";;
    400)
        log_message="[LINK BAD REQUEST]";;
    401 | 999) # 999 is a custom status code for unauthorized access(Linkedin)
        log_message="[LINK UNAUTHORIZED]";;
    403)
        log_message="[LINK FORBIDDEN]";;
    404)
        log_level="ERROR"
        log_message="[LINK NOT FOUND]";;
    429)
        log_message="[LINK TOO MANY REQUESTS]";;
    500)
        log_level="ERROR"
        log_message="[LINK INTERNAL SERVER ERROR]";;
    503)
        log_level="ERROR"
        log_message="[LINK SERVICE UNAVAILABLE]";;
    *)
        log_level="ERROR"
        log_message="[LINK UNKNOWN STATUS CODE ($http_code)]";;
    esac
    log "$log_level" "$log_message - $link" "${files[@]}"
}

# Export functions for parallel execution
export -f log
export -f check_link
export -f handle_curl_error
export -f handle_http_code

# ------------------------------------------------ Main Execution -------------------------------------------------

echo "OK! Let's do this. Link Checker is running..."
echo "Selected parameters: Directory: $SCAN_DIRECTORY, Error Only: $ERROR_ONLY, Links with File: $LINKS_WITH_FILE, Thread Count: $THREAD_COUNT"

links_and_files=$(find_links "$SCAN_DIRECTORY")
if [[ -z "$links_and_files" ]]; then
    echo "No links found to check."
    exit 0
fi

declare -A link_files_map

# Process the links and group by link
while IFS= read -r line; do
    link=$(echo "$line" | cut -d'|' -f1)
    file=$(echo "$line" | cut -d'|' -f2)
    if [[ -n "$link" && -n "$file" ]]; then
        if [[ -z "${link_files_map[$link]}" ]]; then
            link_files_map[$link]="$file"
        else
            link_files_map[$link]="${link_files_map[$link]} $file"
        fi
    fi
done <<<"$links_and_files"

# Check links in parallel
for link in "${!link_files_map[@]}"; do
    files=("${link_files_map["$link"]}")
    check_link "$link" "${files[@]}" &
    if (($(jobs -r -p | wc -l) >= THREAD_COUNT)); then
        wait -n
    fi
done
wait

echo "Link Checker has finished. Have a nice day!"