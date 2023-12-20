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
repos=$(gh repo list $ORGANIZATION --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | sort)

# Check if repos are empty
if [ -z "$repos" ]; then
    echo "No repositories found for organization: $ORGANIZATION"
    exit 1
fi

# Determine the longest repository name
max_length=0
for repo in $repos; do
    length=${#repo}
    if [ $length -gt $max_length ]; then
        max_length=$length
    fi
done

# Define a format for the table
format="%-${max_length}s | %-20s\n"

# Print table header
printf "$format" "Repository" "Latest Release"
printf "$format" $(printf "%-${max_length}s" | tr " " "-") "--------------------"

# Loop through each repository
for repo in $repos; do
    skip=0

    # Filter out repositories based on substrings
    for substr in $EXCLUDE_SUBSTRINGS; do
        if [[ "$repo" == *"$substr"* ]]; then
            skip=1
            break
        fi
    done

    # Filter for repositories based on substrings
    if [ -n "$INCLUDE_SUBSTRINGS" ]; then
        skip=1
        for substr in $INCLUDE_SUBSTRINGS; do
            if [[ "$repo" == *"$substr"* ]]; then
                skip=0
                break
            fi
        done
    fi

    if [ $skip -eq 0 ]; then
        # Fetch the latest release
        release=$(gh release view --repo "$repo" --json tagName --jq '.tagName' 2>/dev/null)

        # If release is not empty, print repo and release
        if [ -n "$release" ]; then
            printf "$format" "$repo" "$release"
        fi
    fi
done

