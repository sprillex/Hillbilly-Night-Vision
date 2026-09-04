# Kali Linux on GPi Case 2 - Raspberry Pi Scripts

This directory contains the core script to prepare a Kali Linux image for the Retroflag GPi Case 2.

## Features & Usage

For full project documentation, prerequisites, tech stack details, and flashing instructions, please refer to the main [README.md](../README.md).

For detailed CLI execution contract, parameters, exit codes, and interface details, see [API.md](../API.md).

### Quick Start

1. Install dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y wget xz-utils kpartx parted unzip
   ```

2. Run the preparation script:
   ```bash
   chmod +x prepare_kali_gpi2.sh
   sudo ./prepare_kali_gpi2.sh
   ```
