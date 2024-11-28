#!/bin/bash

# Prompt for the Authorization token
read -p "Enter your Authorization token (Bearer format): " authToken

# Prompt for the text file containing the URLs
read -p "Enter the path to the text file containing the URLs: " filePath

# Check if the file exists
if [[ ! -f "$filePath" ]]; then
  echo "Error: File not found at '$filePath'"
  exit 1
fi

# Base API URL
apiBaseUrl="https://api.noods.io/recipeConversion"

# Read the file line by line
while IFS= read -r line; do
  # Trim whitespace
  url=$(echo "$line" | xargs)

  # Skip empty lines
  if [[ -z "$url" ]]; then
    echo "Skipping empty line"
    continue
  fi

  # Create the JSON payload
  payload=$(jq -n --arg url "$url" '{url: $url}')

  # Encode the payload
  encodedPayload=$(jq -rn --argjson payload "$payload" '($payload|@uri)')

  # Construct the full URL
  fullUrl="$apiBaseUrl?input=$encodedPayload"

  # Make the GET request
  echo "Fetching data for URL: $url..."
  response=$(curl -s -H "Authorization: $authToken" -H "Accept: text/event-stream" "$fullUrl")

  # Print the response
  echo "Response for URL $url:"
  echo "$response"
  echo "------------------------------------"

done < "$filePath"
