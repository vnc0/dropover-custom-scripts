#!/bin/bash

# This script converts Microsoft Office documents to PDF files.
# It requires Microsoft Office for macOS to be installed.
# Usage: office2pdf.sh <input-file> [<input-file> ...]

# Set use_output_folder to true if you want to use the specified output folder.
# Otherwise the PDF will be saved in the same folder as the input file.
use_output_folder=true
output_folder="$(eval echo ~)/Library/Containers/me.damir.dropover-mac/Data/Action Generated Files/PDFs from Office"

if [ $# -eq 0 ]; then
    echo "Usage: office2pdf.sh <input-file> [<input-file> ...]"
    exit 1
fi

# Create the output folder if it doesn't exist
if $use_output_folder; then
    mkdir -p "$output_folder"
fi

for input_file in "$@"; do
    mime_type=$(file -b --mime-type "$input_file")

    # Determine the application to use based on the file type
    if echo $mime_type | grep -q 'presentation'; then
        app="Microsoft PowerPoint"
        save="save active presentation in pdfPath as save as PDF"
        close="close active presentation"
    elif echo $mime_type | grep -q 'spreadsheet'; then
        app="Microsoft Excel"
        save="save as active sheet filename pdfPath file format PDF file format"
        close="close active workbook"
    elif echo $mime_type | grep -q 'word'; then
        app="Microsoft Word"
        save="save as active document file name pdfPath file format format PDF"
        close="close active document"
    else
        echo "Skipping non-office file: $input_file"
        continue
    fi

    # Check if Microsoft Office is installed
    if ! [ -d "/Applications/$app.app" ]; then
        echo "$app is not installed. Please install Microsoft Office for macOS."
        continue
    fi

    # Get the input file name
    input_file_name=$(basename "$input_file")

    # Set the output file path
    if $use_output_folder; then
        output_file="$output_folder/${input_file_name%.*}.pdf"
    else
        output_file="${input_file%.*}.pdf"
    fi

    echo "Converting '$input_file_name' to PDF using $app..."
    echo "Saving to: $output_file"

    # Convert the file and save it to the output path
    osascript <<EOF
set inputFile to POSIX file "$input_file" as string
set pdfPath to POSIX file "$output_file" as string
tell application "$app"
	activate
	open file inputFile
    $save
    $close
end tell
EOF

    echo "Conversion complete."
done

# Open the output folder in Finder
if $use_output_folder; then
    open "$output_folder"
fi