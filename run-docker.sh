#!/bin/bash

# Configuration
IMAGE=$(jq -r '.config.sandboxImageUri' package.json)

if [ -z "$IMAGE" ] || [ "$IMAGE" == "null" ]; then
  echo "Error: sandboxImageUri not found in package.json"
  exit 1
fi

# Run the container with all the necessary mappings
docker run --rm -it 
  -u $(id -u):$(id -g) 
  -e HOME=/home/node 
  -e TERM=$TERM 
  -e COLORTERM=${COLORTERM:-truecolor} \

  -v ~/.gemini:/home/node/.gemini 
  -v "$(pwd)":/app 
  -w /app 
  $IMAGE gemini "$@"
