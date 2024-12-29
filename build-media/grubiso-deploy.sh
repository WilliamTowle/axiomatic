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

[ "${GRUBISO_STAGING_DIR}" ] || GRUBISO_STAGING_DIR=${PWD}/`basename $0`.d

mkdir -p ${GRUBISO_STAGING_DIR}/grubiso-sfsroot
cp -ar ${OS_TEMPDIR}/* ${GRUBISO_STAGING_DIR}/grubiso-sfsroot/

make -f Makefile os-build OS_DESTDIR=${GRUBISO_STAGING_DIR}/grubiso-sfsroot


mkdir -p ${GRUBISO_STAGING_DIR}/iso-content/boot/grub

# Copy files (only - not /boot/grub, if present):
find ${GRUBISO_STAGING_DIR}/grubiso-sfsroot/boot/ -maxdepth 1 -type f -exec cp '{}' ${GRUBISO_STAGING_DIR}/iso-content/boot/ ';'

cat > ${GRUBISO_STAGING_DIR}/iso-content/boot/grub/grub.cfg <<__EOF
menuentry 'Axiomatic ${OS_DISTRIBUTION} ${OS_SUITE} livesfs' {
	linux /boot/$(cd ${GRUBISO_STAGING_DIR}/grubiso-sfsroot/boot && echo vmlinuz*) boot=live root=/dev/cd0 live-media-path=/boot live-config.noautologin
	initrd /boot/$(cd ${GRUBISO_STAGING_DIR}/grubiso-sfsroot/boot && echo initrd*)
}

menuentry 'Halt System' {
	halt
	}
__EOF


# builds as regular user might want -all-root here?
mksquashfs ${GRUBISO_STAGING_DIR}/grubiso-sfsroot ${GRUBISO_STAGING_DIR}/iso-content/boot/${OS_DISTRIBUTION}.squashfs -e boot -nopad -noappend

grub-mkrescue --verbose -o ${STAGING_DIR}/${OS_DISTRIBUTION}-rescue.iso ${GRUBISO_STAGING_DIR}/iso-content
