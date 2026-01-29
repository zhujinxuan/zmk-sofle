# ZMK Local Build with WSL

This directory contains Docker-based build environment for ZMK firmware, optimized for Windows with WSL.

## Prerequisites

1. **Windows with WSL2** (Ubuntu recommended)
2. **Docker installed in WSL** (not Docker Desktop)
3. **Nushell** (for the helper script)

## Setup

### 1. Install Docker in WSL

```bash
# In WSL terminal
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

### 2. Build Docker Image

From Windows (using Nushell):
```nu
nu build.nu setup
```

Or manually in WSL:
```bash
cd local-builds
wsl docker build -t zmk-builder .
```

## Usage

### Quick Build (Both Halves)

```nu
nu build.nu
# or
nu build.nu quick
```

### Build Options

```nu
# Clean build
nu build.nu clean

# Build only left half
nu build.nu left

# Build only right half
nu build.nu right

# Build settings reset firmware
nu build.nu reset

# Custom options
nu build.nu --board eyelash_sofle --left true --right false --clean
```

### Check Status

```nu
nu build.nu status
```

## Build Output

Firmware files will be created in `../temp/builds/`:
- `eyelash_sofle_left.uf2` - Left half firmware
- `eyelash_sofle_right.uf2` - Right half firmware
- `eyelash_sofle_settings_reset.uf2` - Settings reset firmware (optional)

## Manual Docker Commands (without helper script)

If you prefer to run Docker directly:

```bash
# In WSL
cd /mnt/c/path/to/zmk-sofle

# Build image
docker build -t zmk-builder ./local-builds

# Run build
docker run --rm \
  -v $(pwd)/config:/workspace/config \
  -v $(pwd)/temp/builds:/workspace/output \
  zmk-builder
```

## Troubleshooting

### Docker permission denied

```bash
# In WSL
sudo usermod -aG docker $USER
# Then log out and back in
```

### Path conversion issues

The helper script automatically converts Windows paths to WSL paths. If you run Docker manually, use `wslpath`:

```bash
wslpath -a 'C:\Users\username\workspace\zmk-sofle\config'
```

### Build fails

1. Check WSL is running: `wsl --list --verbose`
2. Check Docker in WSL: `wsl docker --version`
3. Try clean build: `nu build.nu clean`

## Notes

- The Docker image uses Huawei Cloud SWR mirror for faster downloads in China
- ZMK source is cloned from gitee mirror for better China connectivity
- Build cache is preserved between runs for faster subsequent builds
