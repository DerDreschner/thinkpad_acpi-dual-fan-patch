#!/bin/bash

# kernelver is not set on kernel upgrade from apt, but DPKG_MAINTSCRIPT_PACKAGE
# contains the kernel image or header package upgraded
if [ -z "$kernelver" ] ; then
  echo "using DPKG_MAINTSCRIPT_PACKAGE instead of unset kernelver"
  kernelver=$( echo $DPKG_MAINTSCRIPT_PACKAGE | sed -r 's/linux-(headers|image)-//')
fi

vers=(${kernelver//./ })   # split kernel version into individual elements
major="${vers[0]}"
minor="${vers[1]}"
version="$major.$minor"    # recombine as needed
subver=$(grep "SUBLEVEL =" /usr/src/linux-headers-${kernelver}/Makefile | tr -d " " | cut -d "=" -f 2)


echo "Downloading kernel source $version.$subver for $kernelver"
wget https://cdn.kernel.org/pub/linux/kernel/v$major.x/linux-$version.$subver.tar.xz


echo "Extracting original source"
tar -xf linux-$version.$subver.tar.* linux-$version.$subver/drivers/platform/x86 --exclude="Makefile" --xform=s,linux-$version.$subver/drivers/platform/x86,.,

# Increase module version to prevent sanity check error
echo "Increase module version"
sed -i 's/\(#define TPACPI_VERSION "0\.26\)/\1\.1/' thinkpad_acpi.c

# Make changes to whitelisted bios versions for dual fan mode
echo "Make changes to thinkpad_acpi.c"

sed -i 's|P15 (1st gen) / P15v (1st gen)|P15 / P17 / T15g / T15p / P15v (1st gen)|' thinkpad_acpi.c
sed -i "/X1 Carbon (9th gen)/a \	TPACPI_Q_LNV3('N', '3', '7', TPACPI_FAN_2CTL),  /* P15 / P17 / T15g (2nd gen) */" thinkpad_acpi.c
sed -i "/P15 \/ P17 \/ T15g (2nd gen)/a \	TPACPI_Q_LNV3('N', '3', '8', TPACPI_FAN_2CTL),  /* P15v / T15p (2nd gen) */" thinkpad_acpi.c

# Check if changes were applied correctly
echo "Check if changes were applied correctly..."

if
   grep -iq "TPACPI_Q_LNV3('N', '3', '7', TPACPI_FAN_2CTL)," thinkpad_acpi.c && 
   grep -iq "TPACPI_Q_LNV3('N', '3', '8', TPACPI_FAN_2CTL)," thinkpad_acpi.c ;
then
   echo "Changes were applied correctly"
   exit 0
else
   echo "Error: Changes were not applied correctly!"
   echo "Deleting Makefile to force abort"
   echo "as exit code isn't evaluated by dkms"
   
   rm Makefile
   exit 1
fi

