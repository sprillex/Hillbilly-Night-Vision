# Kali Linux on GPi Case 2

An automated image preparation tool for running Kali Linux on the Retroflag GPi Case 2 handheld device powered by the Raspberry Pi Compute Module 4 (CM4). It downloads official Kali Linux ARM64 builds, applies hardware-specific screen and audio patches, and installs safe shutdown scripts to ensure seamless handheld operation.

## Features

- **Automated Image Customization**: Downloads the official Kali Linux Raspberry Pi ARM64 disk image and decompresses it automatically.
- **Hardware Patch Integration**: Applies screen display and audio patches for the Retroflag GPi Case 2 display directly to the boot partition.
- **Safe Shutdown Mechanism**: Integrates Retroflag safe shutdown Python scripts into system startup (`/etc/rc.local`) to prevent file corruption on power off.
- **Automatic Cleanup**: Mounts and cleans up loopback devices and temporary partition mount points safely using shell traps.

## Tech Stack & Architecture

- **Operating System / Target**: Kali Linux ARM64 (Debian-based Linux for Raspberry Pi CM4)
- **Scripting Language**: GNU Bash (`/bin/bash`)
- **System Utilities**: `wget`, `xz-utils` (`xzcat`), `losetup`, `kpartx`, `parted`, `unzip`, `mount`, `umount`
- **Hardware Target**: Retroflag GPi Case 2 (Raspberry Pi Compute Module 4)

## Repository Layout

```text
.
├── API.md                      # Detailed CLI execution interface & environment specification
├── README.md                   # Primary project documentation
└── raspberry_pi/
    ├── README.md               # Subdirectory guide for Raspberry Pi scripts
    └── prepare_kali_gpi2.sh    # Main image preparation Bash script
```

## Prerequisites & Setup

Before running the image preparation script, ensure you are running a Linux system (Debian/Ubuntu recommended, or WSL2 with loop device support) and install required system utilities:

```bash
# Update package list and install required dependencies
sudo apt-get update
sudo apt-get install -y wget xz-utils kpartx parted unzip shellcheck
```

Make the script executable:

```bash
chmod +x raspberry_pi/prepare_kali_gpi2.sh
```

## Configuration

The script uses default URLs for downloading official image artifacts and patches. You can customize these variables directly in `raspberry_pi/prepare_kali_gpi2.sh` or override them in the environment:

| Variable | Description | Default Value |
| --- | --- | --- |
| `KALI_IMAGE_URL` | Download URL for Kali Linux ARM64 `.img.xz` file | `https://kali.download/arm-images/kali-2024.2/kali-linux-2024.2-raspberry-pi-arm64.img.xz` |
| `GPI_PATCH_URL` | Download URL for Retroflag GPi Case 2 zip patch | `https://github.com/RetroFlag/GPiCase2-Script/raw/main/GPi_Case2_patch.zip` |

## Running the Application

### 1. Generate Custom Kali Linux Image

Run the script with `sudo` privileges to allow loop device creation and partition mounting:

```bash
cd raspberry_pi
sudo ./prepare_kali_gpi2.sh
```

Upon completion, the modified image `kali-linux-2024.2-raspberry-pi-arm64.img` will be generated in the `raspberry_pi` directory.

### 2. Flash Image to MicroSD Card

Identify your SD card device path using `lsblk` (e.g., `/dev/sdX`), then flash the image using `dd` or a tool like BalenaEtcher:

```bash
sudo dd if=kali-linux-2024.2-raspberry-pi-arm64.img of=/dev/sdX bs=4M status=progress conv=fsync
```

*Note: Replace `/dev/sdX` with the correct device identifier for your microSD card.*

## Testing & Linting

To verify script quality, run `shellcheck` against the shell script:

```bash
shellcheck raspberry_pi/prepare_kali_gpi2.sh
```

## API Reference

For detailed CLI interface contracts, required environment variables, system dependencies, error handling, exit codes, and output artifacts, please refer to [API.md](./API.md).
