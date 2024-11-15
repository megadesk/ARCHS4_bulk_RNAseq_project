#!/bin/bash

# Set the download destination path
DESTINATION_PATH="/home/ubuntu/data/ARCHS4/"
CHECKSUM_PATH="${DESTINATION_PATH}checksum/"
BASE_URL="https://s3.dev.maayanlab.cloud/archs4/files/"

# List of filenames to download
FILENAMES=(
    "human_gene_v2.2.h5"
    "human_gene_v2.3.h5"
    "human_gene_v2.4.h5"
    "mouse_gene_v2.2.h5"
    "mouse_gene_v2.3.h5"
    "mouse_gene_v2.4.h5"
    "human_transcript_v2.2.h5"
    "mouse_transcript_v2.2.h5"
)

# Create the destination and checksum directories if they do not exist
mkdir -p "$DESTINATION_PATH"
mkdir -p "$CHECKSUM_PATH"

# Function to download a file and generate its checksum
download_and_checksum() {
    local FILENAME=$1
    local URL="${BASE_URL}${FILENAME}"

    # Download the file
    echo "Downloading $FILENAME to $DESTINATION_PATH"
    curl -o "${DESTINATION_PATH}${FILENAME}" "$URL"

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Download of $FILENAME completed successfully."

        # Generate SHA256 checksum and save it in the checksum directory
        echo "Generating checksum for $FILENAME"
        shasum -a 256 "${DESTINATION_PATH}${FILENAME}" > "${CHECKSUM_PATH}${FILENAME}.shasum"
        echo "Checksum saved in ${CHECKSUM_PATH}${FILENAME}.shasum"
    else
        echo "Download of $FILENAME failed. Please check the URL and try again."
    fi
}

# Loop through each filename in the list and start a background task
for FILENAME in "${FILENAMES[@]}"; do
    download_and_checksum "$FILENAME" &
done

# Wait for all background tasks to complete
wait

echo "All downloads and checksums are complete."