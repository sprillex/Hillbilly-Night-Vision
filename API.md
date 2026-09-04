# API & Execution Interface Specification

This document provides the specification for the CLI interfaces, configuration environment variables, system execution contracts, input/output artifacts, and error handling mechanisms for the Kali Linux GPi Case 2 image preparation tool.

---

## Overview

- **Interface Type**: POSIX / GNU Bash Command Line Interface (CLI)
- **Protocol / Interpreter**: `/bin/bash`
- **Execution Mode**: Synchronous batch process
- **Target Platform**: Linux x86_64 / ARM64 with loop device kernel support (`/dev/loop*`, `/dev/mapper/*`)

---

## Authentication & Privileges

### Required Privileges

- **Access Level**: Superuser / `root` (`sudo`)
- **Reasoning**: The image preparation process requires raw block device loopback mapping (`losetup`, `kpartx`), filesystem mounting (`mount`, `umount`), and partition table manipulation (`parted`).

```bash
# Example Invocation
sudo ./raspberry_pi/prepare_kali_gpi2.sh
```

If invoked without superuser privileges, block device manipulation commands will fail and exit with non-zero status code.

---

## Standard Execution Envelopes & Exit Codes

The preparation tool uses standard POSIX exit status codes and streams diagnostic output to `stdout` and error details to `stderr`.

### Status Codes

| Code | Status | Description |
| --- | --- | --- |
| `0` | Success | Script completed successfully; output disk image is created and ready for flashing. |
| `1` | Dependency / Execution Error | Missing required system binaries (`wget`, `kpartx`, etc.) or execution failed during download/mounting. |
| `>1` | Shell / Signal Termination | Interrupted by user (e.g., `SIGINT` / Ctrl+C) or command error handled by `set -e`. |

### Standard Output Schema (Logs)

Standard logging format produced by execution:

```text
Checking for required dependencies...
All dependencies are satisfied.
Downloading required files...
Kali image already downloaded.
GPi Case 2 patch already downloaded.
Decompressing Kali image...
Setting up loop device...
Waiting for device nodes to be created...
.Device nodes created.
Mounting partitions...
Applying GPi Case 2 patch...
Installing safe shutdown script...
Configuring rc.local for safe shutdown...
rc.local configured.
Unmounting partitions...
Image preparation complete!
You can now flash 'kali-linux-2024.2-raspberry-pi-arm64.img' to your SD card.
```

---

## Script Interface Specification

### Resource: `prepare_kali_gpi2.sh`

#### Command Syntax
```bash
sudo ./raspberry_pi/prepare_kali_gpi2.sh
```

#### Description
Automates downloading the raw compressed Kali Linux image for Raspberry Pi CM4, decompresses it, mounts boot/root partitions via loop devices, applies GPi Case 2 LCD/audio overlays, installs Retroflag safe shutdown Python services, updates `/etc/rc.local`, and safely unmounts all devices.

#### Environment Variables / Parameters

| Parameter | Type | Required | Default Value | Description |
| --- | --- | --- | --- | --- |
| `KALI_IMAGE_URL` | String (URL) | Optional | `https://kali.download/arm-images/kali-2024.2/kali-linux-2024.2-raspberry-pi-arm64.img.xz` | Source URL for official Kali ARM64 compressed disk image (`.img.xz`). |
| `GPI_PATCH_URL` | String (URL) | Optional | `https://github.com/RetroFlag/GPiCase2-Script/raw/main/GPi_Case2_patch.zip` | Source URL for Retroflag GPi Case 2 hardware patch archive. |

#### Required External System Dependencies

The host system must have the following executables present in `$PATH`:

- `wget`: HTTP file retrieval
- `xzcat`: XZ decompression stream processing
- `losetup`: Loop device controller
- `kpartx`: Partition table device mapper manager
- `parted`: Partition table manipulator
- `mount` / `umount`: Filesystem mounting tools
- `unzip`: Archive extractor

---

## Inputs, Outputs, & Filesystem Artifacts

### Input Artifacts (Remote / Local)

1. **Kali Linux Image Archive**: `kali-linux-2024.2-raspberry-pi-arm64.img.xz` (compressed XZ archive).
2. **Retroflag Patch Archive**: `GPi_Case2_patch.zip` (contains display config overlays and `/boot` files).
3. **Safe Shutdown Script**: `retropie_SafeShutdown_gpi2.py` (downloaded from RetroFlag repository).
4. **Display Toggle Scripts**: `retropielcdfirst.sh`, `retropielcdnext.sh`.
5. **ALSA Audio Config**: `alsa-base.conf`.

### Generated Output Artifacts

Upon successful completion (`0`), the following disk image is produced:

- **Path**: `raspberry_pi/kali-linux-2024.2-raspberry-pi-arm64.img`
- **Format**: Raw Partitioned Disk Image (`.img`)
- **Partition Layout**:
  - Partition 1 (`/boot`): FAT32 boot partition containing Raspberry Pi device tree overlays and GPi Case 2 LCD configuration.
  - Partition 2 (`/root`): Ext4 Linux root filesystem containing customized `/etc/rc.local`, `/opt/RetroFlag/SafeShutdown.py`, and `/etc/modprobe.d/alsa-base.conf`.

---

## Error Handling & Cleanup Traps

The script implements a POSIX `trap` on `EXIT` to guarantee cleanup of system resources regardless of success or failure.

### Cleanup Contract

Whenever the script exits (normally or due to errors/signals):
1. Flushes pending disk writes via `sync`.
2. Checks if `mnt/root` or `mnt/boot` are mounted and unmounts them via `umount`.
3. Detaches loopback device partition mappings via `kpartx -d`.

### Sample Error Scenarios

#### Missing Dependency
```json
{
  "status": "error",
  "exit_code": 1,
  "message": "Error: 'kpartx' is not installed. Please install it and try again."
}
```

#### Permission Denied (Non-root execution)
```json
{
  "status": "error",
  "exit_code": 1,
  "message": "losetup: cannot open /dev/loop-control: Permission denied"
}
```

---

## Pagination & Querying

Not applicable for batch CLI image preparation scripts. Execution runs as a continuous linear pipeline.
