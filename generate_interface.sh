#!/bin/bash

# URL to retrieve response from
URL=""

# Default values
FILENAME=""
INTERFACE_NAME=""
INTERFACE_COUNT=1

# Parse command-line arguments
while getopts ":f:i:u:" opt; do
  case $opt in
    f)
      FILENAME=$OPTARG
      ;;
    i)
      INTERFACE_NAME=$OPTARG
      ;;
    u)
      URL=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Temporary file to store response
TMP_FILE="/tmp/response.json"

# Curl command to retrieve response
curl -s "$URL" -o "$TMP_FILE"

# Check if curl command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve response."
  exit 1
fi

# Generate TypeScript interface
generate_interface() {
  local prefix=$1
  local json_file=$2
  local interface_name=$3

  local json_type=$(jq -r 'type' "$json_file")

  case $json_type in
    "object")
      local properties=$(jq -r 'keys_unsorted | .[]' "$json_file")
      echo "export interface $interface_name {" >> "$INTERFACE_FILE"
      while IFS= read -r property; do
        local property_type=$(jq -r ".$property | type" "$json_file")
        local nested_interface_name="${interface_name}_${property}"

        if [ "$property_type" == "object" ]; then
          echo "  $property: $nested_interface_name;" >> "$INTERFACE_FILE"
          generate_interface "$prefix$property." "$json_file" "$nested_interface_name"
        else
          echo "  $property: $property_type;" >> "$INTERFACE_FILE"
        fi
      done <<< "$properties"
      echo "}" >> "$INTERFACE_FILE"
      ;;
    "array")
      local item_type=$(jq -r '.[0] | type' "$json_file")
      local nested_interface_name="${interface_name}Item$INTERFACE_COUNT"

      echo "export type $nested_interface_name = { $(jq -r '.[0] | to_entries | map("\(.key): \(.value | type)") | join(", ")' "$json_file") }" >> "$INTERFACE_FILE"
      echo "export type $interface_name = $nested_interface_name[]" >> "$INTERFACE_FILE"

      INTERFACE_COUNT=$((INTERFACE_COUNT + 1))
      ;;
    *)
      echo "export type $interface_name = $json_type;" >> "$INTERFACE_FILE"
      ;;
  esac
}

# Determine the final filename
if [ -z "$FILENAME" ] && [ -z "$INTERFACE_NAME" ]; then
  TIMESTAMP=$(date +%s)
  FILENAME="response_${TIMESTAMP}"
elif [ -z "$FILENAME" ]; then
  FILENAME="$INTERFACE_NAME"
fi

if [ -z "$INTERFACE_NAME" ]; then
  INTERFACE_NAME="Response"
fi

# Create TypeScript interface file
INTERFACE_FILE="/tmp/${FILENAME}.ts"

# Generate TypeScript interface recursively
generate_interface "" "$TMP_FILE" "$INTERFACE_NAME"

echo "TypeScript interface generated: $INTERFACE_FILE"
cat $INTERFACE_FILE
