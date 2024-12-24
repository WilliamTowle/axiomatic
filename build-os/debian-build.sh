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
#export DEBIAN_FRONTEND=noninteractive

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


debconf-set-selections <<__TZDATA
tzdata	tzdata/Areas	select	Europe
tzdata	tzdata/Zones/Africa	select	
tzdata	tzdata/Zones/America	select	
tzdata	tzdata/Zones/Antarctica	select	
tzdata	tzdata/Zones/Arctic	select	
tzdata	tzdata/Zones/Asia	select	
tzdata	tzdata/Zones/Atlantic	select	
tzdata	tzdata/Zones/Australia	select	
tzdata	tzdata/Zones/Etc	select	UTC
tzdata	tzdata/Zones/Europe	select	London
tzdata	tzdata/Zones/Indian	select	
tzdata	tzdata/Zones/Pacific	select	
tzdata	tzdata/Zones/US	select	
__TZDATA
#apt install --no-install-recommends tzdata && dpkg-reconfigure tzdata


debconf-set-selections <<__KEYBOARD_CONFIGURATION
keyboard-configuration	keyboard-configuration/altgr	select	The default for the keyboard layout
keyboard-configuration	keyboard-configuration/compose	select	No compose key
keyboard-configuration	keyboard-configuration/ctrl_alt_bksp	boolean	false
keyboard-configuration	keyboard-configuration/layout	select	
keyboard-configuration	keyboard-configuration/layoutcode	string	gb
keyboard-configuration	keyboard-configuration/model	select	Generic 104-key PC
keyboard-configuration	keyboard-configuration/modelcode	string	pc104
keyboard-configuration	keyboard-configuration/optionscode	string	
keyboard-configuration	keyboard-configuration/store_defaults_in_debconf_db	boolean	true
keyboard-configuration	keyboard-configuration/switch	select	No temporary switch
keyboard-configuration	keyboard-configuration/toggle	select	No toggling
keyboard-configuration	keyboard-configuration/unsupported_config_layout	boolean	true
keyboard-configuration	keyboard-configuration/unsupported_config_options	boolean	true
keyboard-configuration	keyboard-configuration/unsupported_layout	boolean	true
keyboard-configuration	keyboard-configuration/unsupported_options	boolean	true
keyboard-configuration	keyboard-configuration/variant	select	English (UK) - English (UK, extended, Windows)
keyboard-configuration	keyboard-configuration/variantcode	string	extd
keyboard-configuration	keyboard-configuration/xkb-keymap	select	gb(extd)
__KEYBOARD_CONFIGURATION
#apt install --no-install-recommends keyboard-configuration && dpkg-reconfigure keyboard-configuration


debconf-set-selections <<__LOCALES
locales	locales/default_environment_locale	select	None
locales	locales/locales_to_be_generated	multiselect	
__LOCALES
#apt install --no-install-recommends locales && dpkg-reconfigure locales


groupadd -g 1000 guest
useradd -u 1000 -g guest -m guest -s /bin/bash
chpasswd <<< 'guest:guest'
usermod -a -G sudo guest
__EOF
