#!/bin/bash

# Read the hex string from the JSON file using jq
hex_string=$(jq -r '.data' example.json)

# Remove "0x" prefix
hex_string=${hex_string#0x}

# Split into two-character chunks, convert each chunk from hex to decimal and join with commas
data=$(echo $hex_string | sed -r 's/(..)/0x\1, /g' | xargs -n1 printf "%d, ")

# Remove trailing comma
data=${data%,}

# Calculate the number of chunks processed
count=$(echo $data | tr -cd ',' | wc -c)
count=$((count + 1)) # Add one because the number of commas is one less than the number of chunks

# Create a new JSON file with the processed data and the count
echo "{\"data\": [$data], \"count\": $count}" > buffer.json
