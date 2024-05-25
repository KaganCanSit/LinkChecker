#!/bin/bash

# Function to check the status of a link
check_link() {
    local link="$1"
    
    #ShellCheck warning - Declare and assign separately to avoid masking return values
    local response
    local http_code

    # Get the response header
    response=$(curl -IsS "$link" | head -n 1)

    # If the response is empty, the server is unreachable
    if [[ -z "$response" ]]; then
        echo "[ LINK ERROR ] - Unable to connect to the server: $link"
        return 1
    fi
    
    # Get the HTTP status code
    http_code=$(echo "$response" | awk '{print $2}')
    
    # Connection successfull but context unreachable
    if [[ "$http_code" -ge 400 ]]; then
        echo "[ LINK ERROR ] - $link returned HTTP status code $http_code"
        return 1
    fi
    
    # SSL certificate error - unsafe link
    if [[ "$response" =~ ^HTTP/1\.[01]\s[45] ]]; then
        echo "[ SSL ERROR ] - SSL certificate error for $link"
        return 1
    fi
    
    echo "[ LINK OK ] - $link"
    return 0
}

# Function to find links in files within a directory
find_links() {
    local dir="$1"
    local found_links=()

    #ShellCheck warning - Declare and assign separately to avoid masking return values
    local file
    local links

    while IFS= read -r -d '' file;do
        if [[ -f "$file" ]]; then
            links=$(grep -oP '(https?|ftp):\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+(?![\w\/:%#\$&\?\(\)~\.=\+\-])' "$file")
            if [[ -n "$links" ]]; then
                while IFS= read -r link; do
                    link=$(echo "$link" | sed 's/)//g' | sed 's/\.$//')
                    found_links+=("$link")
                done <<< "$links"
            fi
        fi
    done < <(find "$dir" -type f -print0)

    sorted_unique_links=$(printf "%s\n" "${found_links[@]}" | sort -u)
    echo "$sorted_unique_links"
}

echo "--------------------------------- CHECKING LINKS ---------------------------------"
directory="/home/kagancansit/Desktop/Project/kagancansit.github.io"
mapfile -t link_list < <(find_links "$directory")
for link in "${link_list[@]}"; do
    check_link "$link"
done
echo "----------------------------------------------------------------------------------"
exit 0