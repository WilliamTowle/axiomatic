#!/bin/sh

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected IMAGE_NAME[, OS_TEMPDIR]' 1>&2
	exit 1
else
	## FIXME: not required? maybe influence filename?
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

[ "${LIVESFS_STAGING_DIR}" ] || LIVESFS_STAGING_DIR=${PWD}/`basename $0`.d

mkdir -p ${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}-sfsroot
cp -ar ${OS_TEMPDIR}/* ${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}-sfsroot/

make -f Makefile os-build OS_DESTDIR=${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}-sfsroot


# Copy files (only - not /boot/grub, if present):
find ${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}-sfsroot/boot/ -maxdepth 1 -type f -exec cp '{}' ${LIVESFS_STAGING_DIR} \;


# builds as regular user might want -all-root here?
mksquashfs ${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}-sfsroot ${LIVESFS_STAGING_DIR}/${OS_DISTRIBUTION}.squashfs -e boot -nopad
