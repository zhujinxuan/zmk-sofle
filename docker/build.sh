#!/bin/bash

# Exit on error
set -e

# Build the Docker image if it doesn't exist
docker build -t zmk-build-local -f "$(dirname "$0")/Dockerfile" "$(dirname "$0")"

# Run the container with the current directory mounted
docker run --rm -it \
  -v "$(pwd):/workspace" \
  zmk-build-local \
  /bin/bash -c '
    # Initialize west if not already initialized
    if [ ! -f ".west/config" ]; then
      west init -l config
    fi
    
    # Update west modules
    west update
    
    # Export Zephyr
    west zephyr-export
    
    # Read build matrix
    matrix_content=$(yaml2json build.yaml | jq -c .)
    
    # Parse the build matrix and build each configuration
    echo "$matrix_content" | jq -c ".include[]" | while read -r config; do
      board=$(echo "$config" | jq -r ".board")
      shield=$(echo "$config" | jq -r ".shield // empty")
      
      echo "Building for board: $board, shield: $shield"
      
      build_dir="build_$(echo "${shield:+$shield-}$board" | tr "/" "-")"
      
      # Construct build command
      build_cmd="west build -s zmk/app -d $build_dir -b $board"
      if [ -n "$shield" ]; then
        build_cmd="$build_cmd -- -DSHIELD=$shield"
      fi
      build_cmd="$build_cmd -- -DZMK_CONFIG=/workspace/config"
      
      # Execute build
      eval "$build_cmd"
      
      # Copy artifacts
      mkdir -p artifacts
      if [ -f "$build_dir/zephyr/zmk.uf2" ]; then
        cp "$build_dir/zephyr/zmk.uf2" "artifacts/${shield:+$shield-}$board-zmk.uf2"
      elif [ -f "$build_dir/zephyr/zmk.bin" ]; then
        cp "$build_dir/zephyr/zmk.bin" "artifacts/${shield:+$shield-}$board-zmk.bin"
      fi
    done
' 