#!/bin/bash

# Configuration
IMAGE="ghcr.io/e-kotov/gemini-cli-sandbox:latest"

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
