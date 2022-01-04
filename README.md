# Change whitelisted ThinkPads for dual fan mode
The thinkpad_acpi kernel module doesn't allow every ThinkPad with dual fans to control them seperatly. Only some whitelisted models are allowed for compatbility reasons.

This dmks module manipulates the list to include multiple newer ThinkPad models.

## Usage
1. Copy the files inside this repository into the `/usr/src/thinkpad_acpi-1.0` folder.
2. Install the modified module for the currently running kernel version with `sudo dkms install thinkpad_acpi/1.0`.
3. Restart your computer afterwards.

## Code sources
The development of this module was made possible with code from the following sources:
- Basic construct of patch-thinkpad_acpi.sh: https://www.collabora.com/news-and-blog/blog/2021/05/05/quick-hack-patching-kernel-module-using-dkms/
- Makefile: https://github.com/tsprlng/thinkpad_acpi_dkms
