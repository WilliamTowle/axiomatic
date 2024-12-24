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
export DEBIAN_FRONTEND=noninteractive

#sed -i 's/main/main universe/' /etc/apt/sources.list
sed 's/^/# /' /etc/apt/sources.list

apt update
# FIXME: kernel and/or live-{boot|config} may be specific to media type
# ...bionic install advises live-config -> open-infrastructure-system-config
# TODO: 'init' and 'linux-firmware' desirable?
# TODO: tzdata, locales, keyboard-configuration useful (...w/ defaults)
# TODO: efibootmgr desirable for amd64 platforms
apt install --no-install-recommends -y \
	linux-generic linux-image-generic \
	live-boot open-infrastructure-system-config \
	\
	debootstrap dosfstools fdisk \
	grub-efi grub-common grub-pc-bin grub-efi-amd64-bin \
	sudo eject file \
	less screen vim
apt-get clean

groupadd -g 1000 guest
useradd -u 1000 -g guest -m guest -s /bin/bash
chpasswd <<< 'guest:guest'
usermod -a -G sudo guest
__EOF
