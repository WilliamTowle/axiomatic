#!/bin/sh

## Prepare simple VHD image


# Configuration

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected IMAGE_NAME[, IMAGE_SIZE]' 1>&2
	exit 1
else
	IMAGE_NAME=$1
	shift
fi

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected IMAGE_SIZE' 1>&2
	exit 1
else
	IMAGE_SIZE=$1
	shift
fi


set -e

# Create image (sparse)

truncate --size ${IMAGE_SIZE} ${IMAGE_NAME}

/usr/sbin/parted -s ${IMAGE_NAME} \
	mklabel gpt \
	mkpart "GRuB" fat16 1MiB 2MiB \
	set 1 bios_grub on \
	mkpart "ESP" fat32 2MiB 128MiB \
	set 2 esp on \
	mkpart "unspecified" ext2 128MiB 100% \
