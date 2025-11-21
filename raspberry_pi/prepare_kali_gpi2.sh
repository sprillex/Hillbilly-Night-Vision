#!/bin/bash

# This script prepares a Kali Linux image for the Retroflag GPi Case 2.
# It downloads the Kali image, applies the GPi Case 2 patch, and
# installs the safe shutdown script.

# Exit on error
set -e

# --- Configuration ---
# The URL for the Kali Linux image.
# Note: This URL may become outdated. If the script fails to download the image,
# please find the latest URL from the official Kali Linux website:
# https://www.kali.org/get-kali/#kali-arm
KALI_IMAGE_URL="https://kali.download/arm-images/kali-2024.2/kali-linux-2024.2-raspberry-pi-arm64.img.xz"
KALI_IMAGE_XZ="${KALI_IMAGE_URL##*/}"
KALI_IMAGE_IMG="${KALI_IMAGE_XZ%.xz}"
GPI_PATCH_URL="https://github.com/RetroFlag/GPiCase2-Script/raw/main/GPi_Case2_patch.zip"
GPI_PATCH_ZIP="${GPI_PATCH_URL##*/}"

# --- Cleanup ---
# Set up a trap to clean up on exit, ensuring we unmount partitions and
# detach the loopback device in case of an error or interruption.
cleanup() {
    echo -e "\n--- Cleaning up ---"
    # Wait for any pending write operations to complete
    sync

    # Unmount partitions, ignoring errors if they are not mounted
    if mountpoint -q mnt/root; then
        echo "Unmounting root partition..."
        sudo umount mnt/root
    fi
    if mountpoint -q mnt/boot; then
        echo "Unmounting boot partition..."
        sudo umount mnt/boot
    fi

    # Deactivate loopback device mappings
    if [ -f "$KALI_IMAGE_IMG" ]; then
        sudo kpartx -d "$KALI_IMAGE_IMG" &>/dev/null || true
    fi
    echo "Cleanup complete."
}
trap cleanup EXIT

# --- Functions ---
check_dependencies() {
    echo "Checking for required dependencies..."
    for cmd in wget xzcat losetup parted mount umount kpartx; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: '$cmd' is not installed. Please install it and try again."
            exit 1
        fi
    done
    echo "All dependencies are satisfied."
}

download_files() {
    echo "Downloading required files..."
    if [ ! -f "$KALI_IMAGE_XZ" ]; then
        wget "$KALI_IMAGE_URL"
    else
        echo "Kali image already downloaded."
    fi

    if [ ! -f "$GPI_PATCH_ZIP" ]; then
        wget "$GPI_PATCH_URL"
    else
        echo "GPi Case 2 patch already downloaded."
    fi
}

prepare_image() {
    echo "Decompressing Kali image..."
    if [ ! -f "$KALI_IMAGE_IMG" ]; then
        xzcat "$KALI_IMAGE_XZ" > "$KALI_IMAGE_IMG"
    else
        echo "Kali image already decompressed."
    fi

    echo "Setting up loop device..."
    LOOP_DEVICE_OUTPUT=$(sudo kpartx -av "$KALI_IMAGE_IMG")
    LOOP_DEVICE=$(echo "$LOOP_DEVICE_OUTPUT" | awk '{print $3}' | head -n1)

    BOOT_PART="/dev/mapper/${LOOP_DEVICE%p1}p1"
    ROOT_PART="/dev/mapper/${LOOP_DEVICE%p1}p2"

    echo "Waiting for device nodes to be created..."
    while [ ! -b "$BOOT_PART" ] || [ ! -b "$ROOT_PART" ]; do
        echo -n "."
        sleep 1
    done
    echo "Device nodes created."

    mkdir -p mnt/boot mnt/root

    echo "Mounting partitions..."
    sudo mount "$BOOT_PART" mnt/boot
    sudo mount "$ROOT_PART" mnt/root

    echo "Applying GPi Case 2 patch..."
    sudo unzip -o "$GPI_PATCH_ZIP" -d mnt/boot

    echo "Installing safe shutdown script..."
    sudo mkdir -p mnt/root/opt/RetroFlag
    sudo wget -O mnt/root/opt/RetroFlag/SafeShutdown.py "https://raw.githubusercontent.com/RetroFlag/GPiCase2-Script/main/retropie_SafeShutdown_gpi2.py"
    sudo wget -O mnt/root/opt/RetroFlag/lcdfirst.sh "https://raw.githubusercontent.com/RetroFlag/GPiCase2-Script/main/retropielcdfirst.sh"
    sudo wget -O mnt/root/opt/RetroFlag/lcdnext.sh "https://raw.githubusercontent.com/RetroFlag/GPiCase2-Script/main/retropielcdnext.sh"
    sudo wget -O mnt/root/etc/modprobe.d/alsa-base.conf "https://raw.githubusercontent.com/RetroFlag/GPiCase2-Script/main/alsa-base.conf"

    echo "Configuring rc.local for safe shutdown..."
    RC_LOCAL_PATH="mnt/root/etc/rc.local"
    if [ -f "$RC_LOCAL_PATH" ]; then
        if ! sudo grep -q "SafeShutdown.py" "$RC_LOCAL_PATH"; then
            sudo sed -i -e "s/^exit 0/sh \/opt\/RetroFlag\/lcdfirst.sh\& \nsleep 1\& \nsudo python \/opt\/RetroFlag\/SafeShutdown.py\& \n&/g" "$RC_LOCAL_PATH"
            echo "rc.local configured."
        else
            echo "rc.local already configured."
        fi
    else
        echo "Warning: /etc/rc.local not found. You will need to configure the safe shutdown script to run on boot manually."
    fi

    echo "Unmounting partitions..."
    sudo umount mnt/boot mnt/root
    sudo kpartx -d "$KALI_IMAGE_IMG"

    echo "Image preparation complete!"
    echo "You can now flash '$KALI_IMAGE_IMG' to your SD card."
}

# --- Main ---
check_dependencies
download_files
prepare_image
