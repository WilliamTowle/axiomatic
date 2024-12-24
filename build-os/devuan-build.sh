#!/bin/sh

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_ROOTDIR' 1>&2
	exit 1
else
	OS_ROOTDIR=$1
	shift
fi


set -e

sudo /usr/sbin/chroot ${OS_ROOTDIR} /bin/bash -x <<__EOF
apt update

# FIXME: kernel and/or live-{boot|config} may be specific to media type
# TODO: tailor for media type - ${MEDIA_TYPE} is usable
# TODO: tzdata, locales, keyboard-configuration useful (...w/ defaults)
# TODO: efibootmgr desirable for amd64 platforms
apt-get install --no-install-recommends -y -q \
	linux-image-$(echo ${OS_ARCH} | sed 's/i386/686-pae/') sysvinit-core \
	live-boot live-config \
	\
	debootstrap dosfstools fdisk \
	grub-efi grub-common grub-pc-bin grub-efi-amd64-bin \
	\
	sudo eject file \
	less screen vim
apt-get clean

groupadd -g 1000 guest
useradd -u 1000 -g guest -m guest -s /bin/bash
chpasswd <<< 'guest:guest'
usermod -a -G sudo guest
__EOF
