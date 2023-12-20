# GitHub Repository Release Tracker

## Overview
This script, `list_releases.sh`, is designed to efficiently track the latest releases of repositories within a specified GitHub organization. It provides a command-line interface to list repositories and their latest release versions, with options to filter results based on specific criteria.

## Features
- **Dynamic Listing:** Retrieves and lists repositories from a specified GitHub organization.
- **Latest Release Information:** Displays the latest release version for each repository.
- **Dynamic Column Width:** Automatically adjusts the column width based on the longest repository name.
- **Substring Filtering:** Includes options to filter repositories based on the presence or absence of specified substrings.

## Prerequisites
- GitHub CLI (`gh`) must be installed and configured on your system.
- `jq` command-line JSON processor for parsing JSON data.

## Usage
Run the script with the organization name and optional flags for filtering:

- Basic Usage: `./list_releases.sh <organization_name>`
- Exclude Substrings: `./list_releases.sh <organization_name> -e "exclude1,exclude2"`
- Include Substrings: `./list_releases.sh <organization_name> -i "include1,include2"`
- Combined Filtering: `./list_releases.sh <organization_name> -e "exclude1,exclude2" -i "include1,include2"`

## Arguments
- `<organization_name>`: Mandatory. The GitHub organization's name whose repositories you want to track.
- `-e`: Optional. A comma-separated list of substrings to exclude repositories.
- `-i`: Optional. A comma-separated list of substrings to include repositories.

## Installation
1. Ensure `gh` and `jq` are installed.
2. Download `list_releases.sh` script.
3. Make the script executable: `chmod +x list_releases.sh`.

## Examples
1. To list all repositories and their latest releases in the organization `exampleOrg`:
   ```
   ./list_releases.sh exampleOrg
   ```
2. To list repositories that do not contain `archive` or `old` in their names:
   ```
   ./list_releases.sh exampleOrg -e "archive,old"
   ```
3. To list only repositories that include `core` or `main` in their names:
   ```
   ./list_releases.sh exampleOrg -i "core,main"
   ```

## Note
This script interacts with the GitHub API via the GitHub CLI. Usage is subject to GitHub API rate limits and permissions associated with the authenticated GitHub account. 
