#!/bin/bash

# URL to retrieve response from
URL="https://statsapi.mlb.com/api/v1/attendance"

# Temporary file to store response
TMP_FILE="/tmp/response.json"

# Curl command to retrieve response
curl -s "$URL" -o "$TMP_FILE"

# Check if curl command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve response."
  exit 1
fi

# Generate Unix timestamp
TIMESTAMP=$(date +%s)

# Generate TypeScript interface
INTERFACE=$(jq -r 'to_entries | map("  \"" + .key + "\": " + (.value|type)) | join(",\n")' "$TMP_FILE")

# Create TypeScript interface file
INTERFACE_FILE="/tmp/response_${TIMESTAMP}.ts"

echo "export interface Response {" > "$INTERFACE_FILE"
echo -e "$INTERFACE" >> "$INTERFACE_FILE"
echo "}" >> "$INTERFACE_FILE"

echo "TypeScript interface generated: $INTERFACE_FILE"
