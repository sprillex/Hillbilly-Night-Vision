# Kali Linux on GPi Case 2

This repository contains a script to prepare a Kali Linux image for the Retroflag GPi Case 2. The script will download the official Kali Linux image for the Raspberry Pi, apply the necessary patches for the GPi Case 2's screen and buttons, and install a safe shutdown script.

## Prerequisites

Before running the script, you will need to have the following tools installed on your system (Linux/macOS/WSL):

*   `wget`
*   `xz-utils` (for `xzcat`)
*   `losetup`
*   `kpartx`
*   `parted`
*   `unzip`

You can typically install these on a Debian-based system (like Ubuntu) with the following command:

```bash
sudo apt-get update
sudo apt-get install -y wget xz-utils kpartx parted unzip
```

## Instructions

1.  **Clone this repository:**

    ```bash
    git clone <repository_url>
    cd <repository_directory>/raspberry_pi
    ```

2.  **Make the script executable:**

    ```bash
    chmod +x prepare_kali_gpi2.sh
    ```

3.  **Run the script:**

    ```bash
    sudo ./prepare_kali_gpi2.sh
    ```

    The script will download the Kali Linux image (which is several gigabytes) and the GPi Case 2 patch, and then it will create a modified Kali Linux image file named `kali-linux-2024.2-raspberry-pi-arm64.img`.

4.  **Flash the image to your SD card:**

    Once the script has finished, you can use a tool like `dd` or Balena Etcher to flash the `kali-linux-2024.2-raspberry-pi-arm64.img` file to your microSD card.

    **Using `dd` (be very careful with this command):**

    First, identify the device name of your SD card (e.g., `/dev/sdX`). You can use `lsblk` or `fdisk -l` to find this.

    ```bash
    sudo dd if=kali-linux-2024.2-raspberry-pi-arm64.img of=/dev/sdX bs=4M status=progress
    ```

    **Replace `/dev/sdX` with the correct device name for your SD card.**

5.  **Boot your GPi Case 2:**

    Insert the microSD card into your GPi Case 2 and power it on. Kali Linux should now boot up with the screen and gamepad working correctly.
