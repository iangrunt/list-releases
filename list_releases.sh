#!/bin/bash

# Function to split a string into an array
split_string() {
    local IFS=','
    read -ra ADDR <<< "$1"
    echo "${ADDR[@]}"
}

# Usage display function
usage() {
    echo "Usage: $0 <organization_name> [-e exclude_substrings] [-i include_substrings]"
    exit 1
}

# Check if organization name is provided
if [ "$#" -lt 1 ]; then
    usage
fi

ORGANIZATION=$1
shift

# Optional flags for filtering
EXCLUDE_SUBSTRINGS=""
INCLUDE_SUBSTRINGS=""

# Parse optional flags
while getopts ":e:i:" opt; do
  case $opt in
    e) EXCLUDE_SUBSTRINGS=$(split_string "$OPTARG") ;;
    i) INCLUDE_SUBSTRINGS=$(split_string "$OPTARG") ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Fetch and sort the list of repositories for the given organization
# Adjust '--limit' as needed
repo_data=$(gh repo list $ORGANIZATION --limit 100 --json nameWithOwner,url --jq '.[] | "\(.nameWithOwner) \(.url)"' | sort)

# Check if repos are empty
if [ -z "$repo_data" ]; then
    echo "No repositories found for organization: $ORGANIZATION"
    exit 1
fi

# Determine the longest repository name and URL
max_name_length=0
max_url_length=0
while IFS=' ' read -r repo url; do
    repo_name=${repo#$ORGANIZATION/}
    name_length=${#repo_name}
    url_length=${#url}

    if [ $name_length -gt $max_name_length ]; then
        max_name_length=$name_length
    fi
    if [ $url_length -gt $max_url_length ]; then
        max_url_length=$url_length
    fi
done <<< "$repo_data"

# Define a format for the table
format="| %-${max_name_length}s | %-20s | %-${max_url_length}s |\n"
line_format="| $(printf "%-${max_name_length}s" | tr " " "-") | -------------------- | $(printf "%-${max_url_length}s" | tr " " "-") |"

# Print table header with distinct styling
printf "\n"
printf "%s\n" "$line_format"
printf "| %-${max_name_length}s | %-20s | %-${max_url_length}s |\n" "   Repository   " "   Latest Release   " "   URL   "
printf "%s\n" "$line_format"

# Loop through each line of repository data
while IFS=' ' read -r repo url; do
    skip=0
    repo_info=($repo)
    repo_name=${repo_info[0]#$ORGANIZATION/}

    # Filter out repositories based on substrings
    for substr in $EXCLUDE_SUBSTRINGS; do
        if [[ "$repo_name" == *"$substr"* ]]; then
            skip=1
            break
        fi
    done

    # Filter for repositories based on substrings
    if [ -n "$INCLUDE_SUBSTRINGS" ]; then
        skip=1
        for substr in $INCLUDE_SUBSTRINGS; do
            if [[ "$repo_name" == *"$substr"* ]]; then
                skip=0
                break
            fi
        done
    fi

    if [ $skip -eq 0 ]; then
        # Fetch the latest release
        release=$(gh release view --repo "${repo_info[0]}" --json tagName --jq '.tagName' 2>/dev/null)

        # If release is not empty, print repo and release
        if [ -n "$release" ]; then
            printf "$format" "$repo_name" "$release" "$url"
            printf "%s\n" "$line_format"
        fi
    fi
done <<< "$repo_data"

printf "\n"

