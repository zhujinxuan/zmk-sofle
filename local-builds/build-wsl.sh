#!/bin/bash
set -e

# ZMK Build Script for Docker (WSL-compatible version)
# This script is called inside the Docker container

# Configuration
BOARD="${BOARD:-eyelash_sofle}"
BUILD_DIR="/workspace/build"
OUTPUT_DIR="/workspace/output"
CONFIG_DIR="/workspace/config"
BUILD_LEFT="${BUILD_LEFT:-1}"
BUILD_RIGHT="${BUILD_RIGHT:-1}"
BUILD_RESET="${BUILD_RESET:-0}"

echo "=========================================="
echo "ZMK Firmware Build Script (Docker/WSL)"
echo "=========================================="
echo ""
echo "Board: $BOARD"
echo "Build Left: $BUILD_LEFT"
echo "Build Right: $BUILD_RIGHT"
echo "Build Reset: $BUILD_RESET"
echo ""

# Check if config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Config directory not found at $CONFIG_DIR"
    exit 1
fi

echo "Config directory found: $CONFIG_DIR"
echo ""

# Clean previous build if requested
if [ "$CLEAN_BUILD" = "1" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Navigate to ZMK app directory
cd /workspace/zmk/app

# Build left side
if [ "$BUILD_LEFT" = "1" ]; then
    echo "=========================================="
    echo "Building Left Half..."
    echo "=========================================="
    west build -d "$BUILD_DIR/left" -b "${BOARD}_left" -- -DZMK_CONFIG="$CONFIG_DIR" || {
        echo "Error: Left half build failed!"
        exit 1
    }
    
    # Copy left firmware to output
    if [ -f "$BUILD_DIR/left/zephyr/zmk.uf2" ]; then
        cp "$BUILD_DIR/left/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_left.uf2"
        echo "Created: $OUTPUT_DIR/${BOARD}_left.uf2"
    elif [ -f "$BUILD_DIR/left/zephyr/zmk.hex" ]; then
        cp "$BUILD_DIR/left/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_left.hex"
        echo "Created: $OUTPUT_DIR/${BOARD}_left.hex"
    fi
fi

# Build right side
if [ "$BUILD_RIGHT" = "1" ]; then
    echo ""
    echo "=========================================="
    echo "Building Right Half..."
    echo "=========================================="
    west build -d "$BUILD_DIR/right" -b "${BOARD}_right" -- -DZMK_CONFIG="$CONFIG_DIR" || {
        echo "Error: Right half build failed!"
        exit 1
    }
    
    # Copy right firmware to output
    if [ -f "$BUILD_DIR/right/zephyr/zmk.uf2" ]; then
        cp "$BUILD_DIR/right/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_right.uf2"
        echo "Created: $OUTPUT_DIR/${BOARD}_right.uf2"
    elif [ -f "$BUILD_DIR/right/zephyr/zmk.hex" ]; then
        cp "$BUILD_DIR/right/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_right.hex"
        echo "Created: $OUTPUT_DIR/${BOARD}_right.hex"
    fi
fi

# Build settings reset firmware
if [ "$BUILD_RESET" = "1" ]; then
    echo ""
    echo "=========================================="
    echo "Building Settings Reset..."
    echo "=========================================="
    west build -d "$BUILD_DIR/reset" -b "${BOARD}_left" -- -DZMK_CONFIG="$CONFIG_DIR" -DCONFIG_ZMK_BLE_CLEAR_BONDS_ON_START=y || {
        echo "Warning: Settings reset build failed (non-critical)"
    }
    
    if [ -f "$BUILD_DIR/reset/zephyr/zmk.uf2" ]; then
        cp "$BUILD_DIR/reset/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_settings_reset.uf2"
        echo "Created: $OUTPUT_DIR/${BOARD}_settings_reset.uf2"
    elif [ -f "$BUILD_DIR/reset/zephyr/zmk.hex" ]; then
        cp "$BUILD_DIR/reset/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_settings_reset.hex"
        echo "Created: $OUTPUT_DIR/${BOARD}_settings_reset.hex"
    fi
fi

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Output files:"
ls -lh "$OUTPUT_DIR/"
echo ""
echo "Firmware files are available in: $OUTPUT_DIR"
