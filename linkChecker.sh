#!/bin/bash

# Outside parameter
SCAN_DIRECTORY="$1"
THREAD_COUNT=${2:-10}

# --------------------------------------- Script Requirements Check ----------------------------------------------
if [ "$#" -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 <directory> <thread_count>"
    echo "Parameters:" 
    echo "* <directory> - The directory to scan for links."
    echo "* <thread_count> - The number of threads to use for scanning. (Optional/Default: 10)"
    exit 1
fi

# Check if SCAN_DIRECTORY is provided and exists
if [ -z "$SCAN_DIRECTORY" ] || [ ! -d "$SCAN_DIRECTORY" ]; then
    echo "Error: Please provide a valid directory to scan."
    exit 1
fi

# Check if THREAD_COUNT is provided and is a positive integer
if ! [[ "$THREAD_COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: THREAD_COUNT must be a positive integer."
    exit 1
fi

# Check required packages
check_and_install_package() {
    local package_name="$1"

    if ! command -v "$package_name" &> /dev/null; then
        echo "'$package_name' is not installed. Do you want to install it now? (yes/no)"
        read -r response
        if [[ "$response" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
            # Operation system check 
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                if command -v apt-get &> /dev/null; then
                    sudo apt-get install "$package_name"
                elif command -v yum &> /dev/null; then
                    sudo yum install "$package_name"
                elif command -v pacman &> /dev/null; then
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
}

# curl package is required to run this 
check_and_install_package "curl"

# parallel package is required to run this 
check_and_install_package "parallel"

# ------------------------------------------------ Functions -------------------------------------------------
function log() {
    local level="$1"
    local message="$2"
    echo -e "[$level]\t" "$message"
}

# Function to find links in files within a directory
function find_links() {
    local dir="$1"
    local found_links=()

    #ShellCheck warning - Declare and assign separately to avoid masking return values
    local file
    local links

    while IFS= read -r -d '' file;do
        if [[ -f "$file" ]]; then
            links=$(grep -soP 'https?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+(?![\w\/:%#\$&\?\(\)~\.=\+\-])' "$file")
            if [[ -n "$links" ]]; then
                while IFS= read -r link; do
                    link=$(echo "$link" | sed 's/)//g' | sed 's/\.$//')
                    if [ -n "$link" ];then
                        found_links+=("$link")
                    fi
                done <<< "$links"
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

    # Get the response header and capture the error code
    response=$(curl -IsS "$link" 2>&1)
    curl_exit_code=$?

    # Check for common curl error codes and provide meaningful messages
    if [[ $curl_exit_code -ne 0 ]]; then
        handle_curl_error "$curl_exit_code" "$link"
        return 1
    fi

    # If the response is empty, the server is unreachable
    if [[ -z "$response" ]]; then
        log "ERROR" "Unable to connect to the server: $link"
        return 1
    fi

    # Get the HTTP status code
    http_code=$(echo "$response" | awk 'NR==1{print $2}')

    # Handle specific HTTP status codes that indicate the link is still valid
    handle_http_code "$http_code" "$link"
    return 0
}

# Function to handle common curl errors
function handle_curl_error() {
    local error_code="$1"
    local link="$2"

    local log_level="ERROR"
    local log_message=""

    case $error_code in
        6)
            log_message="[LINK COULD NOT RESOLVE HOST]"
            ;;
        7)
            log_message="[LINK FAILED TO CONNECT TO HOST]"
            ;;
        23)
            log_message="[LINK FAILED WRITING BODY]"
            ;;
        35)
            log_message="[SSL HANDSHAKE FAILED]"
            ;;
        60)
            log_message="[SSL CERTIFICATE PROBLEM]"
            ;;
        *)
            log_message="[LINK]\t CURL ERROR($error_code)"
            ;;
    esac
    log "$log_level" "$log_message - $link"
}

# Function to handle HTTP status codes
function handle_http_code() {
    local http_code="$1"
    local link="$2"

    local log_level="WARN"
    local log_message=""

    case $http_code in
        103)
            log_level="INFO"
            log_message="[LINK EARLY HINTS]"
            ;;
        200|201|202)
            log_level="INFO"
            log_message="[LINK OK]"
            ;;
        204)
            log_message="[LINK NO CONTENT]"
            ;;
        301|302|303|304|308)
            log_level="INFO"
            log_message="[LINK REDIRECT ($http_code)]"
            ;;
        400)
            log_message="[LINK BAD REQUEST]"
            ;;
        401|999) # 999 is a custom status code for unauthorized access(Linkedin)
            log_message="[LINK UNAUTHORIZED]"
            ;;
        403)
            log_message="[LINK FORBIDDEN]"
            ;;
        404)
            log_level="ERROR"
            log_message="[LINK NOT FOUND]"
            ;;
        429)
            log_message="[LINK TOO MANY REQUESTS]"
            ;;
        500)
            log_level="ERROR"
            log_message="[LINK INTERNAL SERVER ERROR]"
            ;;
        503)
            log_level="ERROR"
            log_message="[LINK SERVICE UNAVAIBLE]"
            ;;
        *)
            log_level="ERROR"
            log_message="[LINK UNKNOWN STATUS CODE ($http_code)]"
            ;;
    esac
    log "$log_level" "$log_message - $link"
}

# Export functions for parallel execution
export -f log
export -f check_link
export -f handle_curl_error
export -f handle_http_code

# -------------------------------------------------- Main Script ---------------------------------------------
echo "--------------------------------------------- LINK CHECKER ---------------------------------------------"
mapfile -t link_list < <(find_links "$SCAN_DIRECTORY")
printf "%s\n" "${link_list[@]}" | \
parallel -j "$THREAD_COUNT" check_link {} | \
awk -F '\t' '{
    if ($1 ~ /\[ERROR\]/) {
        printf "\033[31m%s\033[0m\t%s\n", $1, $2
    } else if ($1 ~ /\[INFO\]/) {
        printf "\033[32m%s\033[0m\t%s\n", $1, $2
    } else if ($1 ~ /\[WARN\]/) {
        printf "\033[33m%s\033[0m\t%s\n", $1, $2
    } else { 
        print $0 
    }
}'
echo "--------------------------------------------------------------------------------------------------------"
exit 0