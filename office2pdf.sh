#!/bin/bash

# This script converts Microsoft Office documents to PDF files.
# It requires Microsoft Office for macOS to be installed.
# Usage: office2pdf.sh <input-file> [<input-file> ...]

for input_file in "$@"; do
    mime_type=$(file -b --mime-type "$input_file")

    # Determine the application to use based on the file type
    if echo $mime_type | grep -q 'presentation'; then
        app="PowerPoint"
        save="save active presentation in pdfPath as save as PDF"
        close="close active presentation"
    elif echo $mime_type | grep -q 'spreadsheet'; then
        app="Excel"
        save="save as active sheet filename pdfPath file format PDF file format"
        close="close active workbook"
    elif echo $mime_type | grep -q 'word'; then
        app="Word"
        save="save as active document file name pdfPath file format format PDF"
        close="close active document"
    else
        echo "Skipping non-office file: $input_file"
        continue
    fi

    # Check if app is installed
    if ! [ -d "/Applications/Microsoft $app.app" ]; then
        echo "$app is not installed. Please install Microsoft Office for macOS."
        continue
    fi

    # Get the input file name
    input_file_name=$(basename "$input_file")

    # Get the output file path by replacing the extension with ".pdf"
    output_file="${input_file%.*}.pdf"

    echo "Converting '$input_file_name' to PDF using $app..."

    # Convert the file and save it to the output path
    osascript <<EOF
set inputFile to POSIX file "$input_file" as string
set pdfPath to POSIX file "$output_file" as string
tell application "Microsoft $app"
	activate
	open file inputFile
    $save
    $close
end tell
EOF

    echo "Conversion complete. The PDF file is located at: $output_file"
done