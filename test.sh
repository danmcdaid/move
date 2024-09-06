#!/bin/bash

# This script is to be used as a custom download method for apt
# It takes two arguments:
# $1: The URL of the package to download (which we'll ignore)
# $2: The filename where the package should be saved

if [ $# -ne 2 ]; then
    echo "Usage: $0 <url> <output_file>" >&2
    exit 1
fi

output_file="$2"
package_name=$(echo "$output_file" | cut -d '_' -f 1)

# Construct the packages.debian.org URL
debian_url="https://packages.debian.org/bullseye/all/${package_name}/download"

# Fetch the download page
download_page=$(curl -s "$debian_url")

# Extract the US HTTP mirror URL
deb_url=$(echo "$download_page" | grep -oP 'href="http://http\.us\.debian\.org/debian/pool/main/[^"]+\.deb"' | head -n 1 | sed 's/href="//;s/"$//')

if [ -n "$deb_url" ]; then
    echo "Downloading $output_file from $deb_url" >&2
    if curl -s -o "$output_file" "$deb_url"; then
        echo "Successfully downloaded $output_file" >&2
        exit 0
    else
        echo "Failed to download $output_file" >&2
        exit 1
    fi
else
    echo "Failed to find download URL for $output_file" >&2
    exit 1
fi
