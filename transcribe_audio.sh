#!/bin/bash

# This script converts audio files into text using OpenAI's Speech to text API.
# Useful for transcribing voice messages, podcasts, interviews, lectures, etc.
# Requires an OpenAI API key.
# Usage: transcribe_audio.sh <input-file> [<input-file> ...]

# Set USE_OUTPUT_FOLDER to true if you want to use the specified output folder.
# Otherwise, the files will be saved in the same folder as the input.

USE_OUTPUT_FOLDER=true
OUTPUT_FOLDER="$(eval echo ~)/Library/Containers/me.damir.dropover-mac/Data/Action Generated Files/Transcriptions"
API_KEY=""         # Replace with your OpenAI API key
LANGUAGE=""        # Optional, leave blank for auto-detect
MODEL="whisper-1"

if [ -z "$API_KEY" ]; then
    echo "Please set your OpenAI API key in the script."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: transcribe_audio.sh <input-file> [<input-file> ...]"
    exit 1
fi

# Create the output folder if it doesn't exist
if $USE_OUTPUT_FOLDER; then
    mkdir -p "$OUTPUT_FOLDER"
fi

for audio in "$@"; do
    mime_type=$(file -b --mime-type "$audio")

    if ! echo "$mime_type" | grep -q 'audio'; then
        echo "Skipping non-audio file: $audio"
        continue
    fi

    # Get the filename, path and extension
    filename=$(basename -- "$audio")
    filename_without_extension="${filename%.*}"

    # Set the output file path
    if $USE_OUTPUT_FOLDER; then
        output_path="$OUTPUT_FOLDER/${filename_without_extension}.txt"
    else
        output_path="${path}/${filename_without_extension}.txt"
    fi

    echo "Converting '$filename' to text..."

    # Set the API command
    api_command="curl https://api.openai.com/v1/audio/transcriptions -H 'Authorization: Bearer ${API_KEY}' -F 'file=@${audio}' -F 'model=${MODEL}' -F 'response_format=text'"

    if [ ! -z "$LANGUAGE" ]; then
        api_command="${api_command} -F 'language=${LANGUAGE}'"
    fi

    eval "${api_command}" > "$output_path"

    echo "Done. Saved to: $output_path"
done

# Open the output folder in Finder
if $USE_OUTPUT_FOLDER; then
    open "$OUTPUT_FOLDER"
fi