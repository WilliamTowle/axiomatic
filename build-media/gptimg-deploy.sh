#!/bin/sh

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected IMAGE_NAME[, OS_TEMPDIR]' 1>&2
	exit 1
else
	IMAGE_NAME=$1
	shift
fi

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_TEMPDIR' 1>&2
	exit 1
else
	OS_TEMPDIR=$1
	shift
fi


set -e

STAGING_DIR=${PWD}/staging
LOOPBACK_ESPTWIN=${STAGING_DIR}/mnt-esp
LOOPBACK_ROOTFS=${STAGING_DIR}/mnt-root


IMAGE_LOOPDEV=`sudo losetup --find --partscan ${IMAGE_NAME} --show`
if [ -z "${IMAGE_LOOPDEV}" ] ; then
	printf '%s: %s\n' $0 "Unexpected 'losetup' exit" 1>&2
	exit 1
fi
sudo mkfs -t vfat -F 16 -n 'ESP' ${IMAGE_LOOPDEV}p2
sudo mkfs -t ext2 ${IMAGE_LOOPDEV}p3


mkdir -p ${LOOPBACK_ESPTWIN} ${LOOPBACK_ROOTFS}
# Needs /dev/loop<n> to prevent "cannot find a GRUB drive for /dev/loopXpY"
sudo mount -o loop ${IMAGE_LOOPDEV}p2 ${LOOPBACK_ESPTWIN}


## GrUB for BIOS boot

sudo grub-install --target=i386-pc --modules='part_gpt' \
	--boot-directory=${LOOPBACK_ESPTWIN}/boot \
	${IMAGE_LOOPDEV}


## GrUB for EFI boot

mkdir -p ${LOOPBACK_ESPTWIN}/EFI/boot
grub-mkimage --format=x86_64-efi --prefix='/EFI/boot' \
	--output=${LOOPBACK_ESPTWIN}/EFI/boot/bootx64.efi	\
	normal configfile chain loopback halt \
	efifwsetup efi_gop efi_uga \
	part_gpt part_msdos fat ext2 \
	linux linuxefi boot \
	ls search search_label search_fs_uuid search_fs_file \
	gfxterm gfxterm_background gfxterm_menu test all_video loadenv


## Populate rootfs
sudo mount ${IMAGE_LOOPDEV}p3 ${LOOPBACK_ROOTFS}
( cd ${OS_TEMPDIR} && sudo tar cvf - [a-z]?? [a-z]??? lib64 media ) \
	| ( cd ${LOOPBACK_ROOTFS} && sudo tar xvf - )

make -f Makefile os-build OS_DESTDIR=${LOOPBACK_ROOTFS}


## Clean up

mountpoint -q ${LOOPBACK_ROOTFS} && sudo umount ${LOOPBACK_ROOTFS}
mountpoint -q ${LOOPBACK_ESPTWIN} && sudo umount ${LOOPBACK_ESPTWIN}
rmdir ${LOOPBACK_ESPTWIN}
rmdir ${LOOPBACK_ROOTFS}

sudo losetup -d ${IMAGE_LOOPDEV}
