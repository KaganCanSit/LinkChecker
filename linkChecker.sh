#!/bin/bash

# Outside parameter
SCAN_DIRECTORY="$1"
THREAD_COUNT="$2"

# Script Requirements Check
# ------------------------------------------------------------------------------------------------------------
if [ "$#" -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 <directory> <thread_count>"
    echo "Parameters:" 
    echo "* <directory> - The directory to scan for links."
    echo "* <thread_count> - The number of threads to use for scanning. (Optional)"
    exit 1
fi

# Set the default thread count to 10 if not provided
if [ "$#" -eq 1 ]; then
    THREAD_COUNT=10
fi

# Check if the directory exists
if [[ ! -d "$SCAN_DIRECTORY" ]]; then
    echo "$SCAN_DIRECTORY is not a directory or could not be found. Please provide a valid directory."
    exit 1;
fi

# curl package is required to run this 
if ! command -v curl &> /dev/null; then
    echo "'curl' is not installed. Do you want to install it now? (yes/no)"
    read -r response
    if [[ "$response" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
        # Operation system check 
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get install curl
            elif command -v yum &> /dev/null; then
                sudo yum install curl
            elif command -v pacman &> /dev/null; then
                sudo pacman -S curl
            else
                echo "Unsupported package manager. Please install curl manually."
                exit 1
            fi
        else
            echo "Unsupported operating system. Please install curl manually."
            exit 1
        fi
    else
        echo "curl is required for this script to run. Please install curl and try again."
        exit 1
    fi
fi

# parallel package is required to run this 
if ! command -v parallel &> /dev/null; then
    echo "'parallel' is not installed. Do you want to install it now? (yes/no)"
    read -r response
    if [[ "$response" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
        # Operation system check 
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get install parallel
            elif command -v yum &> /dev/null; then
                sudo yum install parallel
            elif command -v pacman &> /dev/null; then
                sudo pacman -S parallel
            else
                echo "Unsupported package manager. Please install parallel manually."
                exit 1
            fi
        else
            echo "Unsupported operating system. Please install parallel manually."
            exit 1
        fi
    else
        echo "parallel is required for this script to run. Please install parallel and try again."
        exit 1
    fi
fi
# ------------------------------------------------------------------------------------------------------------

# Functions
# ------------------------------------------------------------------------------------------------------------

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
                    found_links+=("$link")
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

    case $error_code in
        6)
            log "ERROR" "[LINK COULD NOT RESOLVE HOST] - $link"
            ;;
        7)
            log "ERROR" "[LINK FAILED TO CONNECT TO HOST] - $link"
            ;;
        23)
            log "ERROR" "[LINK FAILED WRITING BODY] - $link"
            ;;
        35)
            log "ERROR" "[SSL HANDSHAKE FAILED] - $link"
            ;;
        60)
            log "ERROR" "[SSL CERTIFICATE PROBLEM] - $link - More details: https://curl.se/docs/sslcerts.html"
            ;;
        *)
            log "ERROR" "[LINK]\t CURL ERROR($error_code) - $link"
            ;;
    esac
}

# Function to handle HTTP status codes
function handle_http_code() {
    local http_code="$1"
    local link="$2"

    case $http_code in
        103)
            log "INFO" "[LINK EARLY HITS] - $link"
            ;;
        200|201|202)
            log "INFO" "[LINK OK] - $link"
            ;;
        204)
            log "WARN" "[LINK NO CONTENT] - $link"
            ;;
        301|302|303|304|308)
            log "INFO" "[LINK STATUS MOVED ($http_code)] - $link"
            ;;
        400)
            log "WARN" "[LINK BAD REQUEST] - $link"
            ;;
        401|999) # 999 is a custom status code for unauthorized access(Linkedin)
            log "WARN" "[LINK UNAUTHORIZED] - $link"
            ;;
        403)
            log "WARN" "[LINK FORBIDDEN] - $link"
            ;;
        404)
            log "ERROR" "[LINK NOT FOUND] - $link"
            ;;
        429)
            log "WARN" "[LINK TOO MANY REQUESTS] - $link"
            ;;
        500)
            log "ERROR" "[LINK INTERNAL SERVER ERROR] - $link"
            ;;
        503)
            log "ERROR" "[LINK SERVICE UNAVAIBLE] - $link"
            ;;
        *)
            log "ERROR" "[LINK UNKNOWN STATUS CODE ($http_code)] - $link"
            ;;
    esac
}
# ------------------------------------------------------------------------------------------------------------

export -f check_link
export -f log
export -f handle_curl_error
export -f handle_http_code

# Main Script
echo "--------------------------------------------- LINK CHECKER ---------------------------------------------"
mapfile -t link_list < <(find_links "$SCAN_DIRECTORY")
printf "%s\n" "${link_list[@]}" | parallel -j "$THREAD_COUNT" check_link {} | awk -F '\t' '{ if ($1 ~ /\[ERROR\]/) { printf "\033[31m%s\033[0m\t%s\n", $1, $2 } else if ($1 ~ /\[INFO\]/) { printf "\033[32m%s\033[0m\t%s\n", $1, $2 } else if ($1 ~ /\[WARN\]/) { printf "\033[33m%s\033[0m\t%s\n", $1, $2 } else { print $0 } }'
echo "--------------------------------------------------------------------------------------------------------"
exit 0