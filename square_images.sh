#!/bin/bash

# This script trims and squares images.
# The squared images will have a transparent background and centred content.
# Useful for creating icons or album covers.
# It requires ImageMagick to be installed.
# Usage: square_images.sh <input-file> [<input-file> ...]

# Set use_output_folder to true if you want to use the specified output folder.
# Otherwise, the squared images will be saved in the same folder as the input files.
use_output_folder=true
output_folder="$(eval echo ~)/Library/Containers/me.damir.dropover-mac/Data/Action Generated Files/Squared Images"

if [ $# -eq 0 ]; then
    echo "Usage: square_images.sh <input-file> [<input-file> ...]"
    exit 1
fi

# Create the output folder if it doesn't exist
if $use_output_folder; then
    mkdir -p "$output_folder"
fi

for img in "$@"; do
    mime_type=$(file -b --mime-type "$img")

    if ! echo "$mime_type" | grep -q 'image'; then
        echo "Skipping non-image file: $img"
        continue
    fi

    # Get the filename, path and extension
    filename=$(basename -- "$img")
    filename_without_extension="${filename%.*}"
    extension="${filename##*.}"
    path=$(dirname -- "$img")

    # Set the output file path
    if $use_output_folder; then
        output_path="$output_folder/${filename_without_extension}_squared.${extension}"
    else
        output_path="${path}/${filename_without_extension}_squared.${extension}"
    fi

    echo "Squaring '$filename'..."

    # Copy the input file to the output path
    cp "$img" "$output_path"

    # Trim and repage the image at the output path
    mogrify -trim +repage "$output_path"

    # Calculate the maximum dimension (width or height) of the image
    max_dimension=$(convert "$output_path" -format "%[fx:max(w,h)]" info:)

    # Create the squared version of the image with a transparent background and centered content
    convert "$output_path" -background transparent -gravity center -extent "${max_dimension}x${max_dimension}" "$output_path"

    echo "Done. Saved to: $output_path"
done

# Open the output folder in Finder
if $use_output_folder; then
    open "$output_folder"
fi