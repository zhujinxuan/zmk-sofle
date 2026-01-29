#!/usr/bin/env nu

# ZMK Build Helper Script for Windows + WSL
# This script runs Docker builds using WSL's Docker installation

def main [
    --clean (-c) = false            # Clean build directory before building
    --board: string = "eyelash_sofle"  # Board name to build
    --left (-l) = true              # Build left half
    --right (-r) = true             # Build right half
    --reset (-s) = false            # Build settings reset firmware
] {
    let repo_root = ($env.FILE_PWD | path dirname)
    let config_dir = $repo_root + "/config"
    let output_dir = $repo_root + "/temp/builds"
    let local_builds_dir = $repo_root + "/local-builds"
    
    # Ensure output directory exists
    mkdir $output_dir
    
    # Build Docker image if needed
    print "Checking Docker image..."
    let image_exists = (wsl docker images zmk-builder -q | str trim | is-not-empty)
    
    if not $image_exists {
        print "Building Docker image..."
        cd $local_builds_dir
        wsl docker build -t zmk-builder .
    }
    
    # Convert Windows paths to WSL paths
    let wsl_config = (wsl wslpath -a $config_dir | str trim)
    let wsl_output = (wsl wslpath -a $output_dir | str trim)
    
    print $"Building ZMK firmware for board: ($board)"
    print $"Config: ($config_dir)"
    print $"Output: ($output_dir)"
    print ""
    
    # Prepare environment variables
    let clean_build = (if $clean { "1" } else { "0" })
    let build_left = (if $left { "1" } else { "0" })
    let build_right = (if $right { "1" } else { "0" })
    let build_reset = (if $reset { "1" } else { "0" })
    
    # Construct volume mounts
    let vol_config = $wsl_config + ":/workspace/config"
    let vol_output = $wsl_output + ":/workspace/output"
    let env_clean = "CLEAN_BUILD=" + $clean_build
    let env_board = "BOARD=" + $board
    let env_left = "BUILD_LEFT=" + $build_left
    let env_right = "BUILD_RIGHT=" + $build_right
    let env_reset = "BUILD_RESET=" + $build_reset
    
    # Run Docker build through WSL
    wsl docker run --rm -v $vol_config -v $vol_output -e $env_clean -e $env_board -e $env_left -e $env_right -e $env_reset zmk-builder
    
    print ""
    print "Build complete! Output files:"
    ls $output_dir
}

# Quick build command
def "main quick" [] {
    main --left true --right true
}

# Clean build command
def "main clean" [] {
    main --clean true
}

# Build only left half
def "main left" [] {
    main --left true --right false
}

# Build only right half
def "main right" [] {
    main --left false --right true
}

# Build settings reset firmware
def "main reset" [] {
    main --reset true --left true --right false
}

# Check WSL and Docker status
def "main status" [] {
    print "WSL Status:"
    wsl --list --verbose
    
    print ""
    print "Docker Status:"
    wsl docker --version
    
    print ""
    print "Docker Images:"
    wsl docker images zmk-builder
}

# Setup WSL Docker
def "main setup" [] {
    print "Setting up WSL Docker..."
    
    # Check if Docker is installed in WSL
    let docker_installed = (try { wsl docker --version | str trim | is-not-empty } catch { false })
    
    if not $docker_installed {
        print "Docker not found in WSL. Installing..."
        wsl -u root apt-get update
        wsl -u root apt-get install -y docker.io
        wsl -u root usermod -aG docker $env.USERNAME
        print "Docker installed. Please restart your terminal and run 'main setup' again."
        return
    }
    
    print "Docker is already installed in WSL."
    print ""
    print "Building ZMK builder image..."
    
    let repo_root = ($env.FILE_PWD | path dirname)
    cd ($repo_root + "/local-builds")
    wsl docker build -t zmk-builder .
    
    print ""
    print "Setup complete! You can now run: nu build.nu"
}
