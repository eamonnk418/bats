#!/usr/bin/env bash

# URL of the API
API_URL="https://example.com/api/v1/data"

# Send GET request to the API and store the response
response=$(curl -s "$API_URL")

# Check if there's an error in the response
if [[ "$response" =~ "error" ]]; then
    echo "Error: Unable to retrieve code freeze information from the API."
    exit 1
fi

# Get current UTC timestamp
current_time=$(date -u +%s)

# Extract restrictions from the response
restrictions=$(echo "$response" | jq -r '.restrictions[]')

# Flag to track if code freeze is active
code_freeze_active=false

# Loop through each restriction
while IFS= read -r restriction; do
    start_time=$(echo "$restriction" | jq -r '.start_time')
    end_time=$(echo "$restriction" | jq -r '.end_time')

    # Check if current time is within the start and end time of the restriction
    if [[ "$current_time" -ge "$start_time" && "$current_time" -le "$end_time" ]]; then
        code_freeze_active=true
        break
    fi
done <<< "$restrictions"

# Set environment variable or flag to inform GitHub Action
if [ "$code_freeze_active" = true ]; then
    echo "::set-env name=CODE_FREEZE_ACTIVE::true"  # Inform GitHub Action about code freeze
    echo "Code freeze is active."
else
    echo "::set-env name=CODE_FREEZE_ACTIVE::false"  # Inform GitHub Action that code freeze is not active
    echo "Code freeze is not active."
fi
