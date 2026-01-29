#!/bin/bash
set -e

# ZMK Build Script for Local Docker Environment
# This script builds ZMK firmware for the eyelash_sofle keyboard

# Configuration
BOARD="eyelash_sofle"
BUILD_DIR="/workspace/build"
OUTPUT_DIR="/workspace/output"
CONFIG_DIR="/workspace/config"

echo "=========================================="
echo "ZMK Firmware Build Script"
echo "=========================================="
echo ""

# Check if config directory is mounted
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Config directory not found at $CONFIG_DIR"
    echo "Please mount your config directory to /workspace/config"
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

echo "Building firmware for board: $BOARD"
echo ""

# Navigate to ZMK app directory
cd /workspace/zmk/app

# Build left side
echo "=========================================="
echo "Building Left Half..."
echo "=========================================="
west build -d "$BUILD_DIR/left" -b "${BOARD}_left" -- -DZMK_CONFIG="$CONFIG_DIR" || {
    echo "Error: Left half build failed!"
    exit 1
}

# Copy left firmware to output
cp "$BUILD_DIR/left/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_left.uf2" 2>/dev/null || \
cp "$BUILD_DIR/left/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_left.hex" 2>/dev/null || \
cp "$BUILD_DIR/left/zephyr/zmk.bin" "$OUTPUT_DIR/${BOARD}_left.bin" 2>/dev/null || {
    echo "Warning: Could not find left firmware output file"
}

# Build right side
echo ""
echo "=========================================="
echo "Building Right Half..."
echo "=========================================="
west build -d "$BUILD_DIR/right" -b "${BOARD}_right" -- -DZMK_CONFIG="$CONFIG_DIR" || {
    echo "Error: Right half build failed!"
    exit 1
}

# Copy right firmware to output
cp "$BUILD_DIR/right/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_right.uf2" 2>/dev/null || \
cp "$BUILD_DIR/right/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_right.hex" 2>/dev/null || \
cp "$BUILD_DIR/right/zephyr/zmk.bin" "$OUTPUT_DIR/${BOARD}_right.bin" 2>/dev/null || {
    echo "Warning: Could not find right firmware output file"
}

# Build settings reset firmware (optional)
echo ""
echo "=========================================="
echo "Building Settings Reset..."
echo "=========================================="
west build -d "$BUILD_DIR/reset" -b "${BOARD}_left" -- -DZMK_CONFIG="$CONFIG_DIR" -DZMK_EXTRA_MODULES="" -DCONFIG_ZMK_BLE_CLEAR_BONDS_ON_START=y || {
    echo "Warning: Settings reset build failed (non-critical)"
}

if [ -f "$BUILD_DIR/reset/zephyr/zmk.uf2" ]; then
    cp "$BUILD_DIR/reset/zephyr/zmk.uf2" "$OUTPUT_DIR/${BOARD}_settings_reset.uf2"
elif [ -f "$BUILD_DIR/reset/zephyr/zmk.hex" ]; then
    cp "$BUILD_DIR/reset/zephyr/zmk.hex" "$OUTPUT_DIR/${BOARD}_settings_reset.hex"
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
