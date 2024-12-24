#!/bin/sh

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_TEMPDIR[, OS_SUITE, OS_MIRROR, OS_ARCH]' 1>&2
	exit 1
else
	OS_TEMPDIR=$1
	shift
fi

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_SUITE[, OS_MIRROR, OS_ARCH]' 1>&2
	exit 1
else
	OS_SUITE=$1
	shift
fi

if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_MIRROR[, OS_ARCH]' 1>&2
	exit 1
else
	OS_MIRROR=$1
	shift
fi


if [ -z "$1" ] ; then
	printf '%s: %s\n' $0 'Expected OS_ARCH' 1>&2
	exit 1
else
	OS_ARCH=$1
	shift
fi


set -e

## deprecated - see DOWNLOAD_TARGETS
#[ "${DOWNLOAD_DIR}" ] || DOWNLOAD_DIR=${PWD}/`basename $0`.d
#
#DEBOOTSTRAP_VER=1.0.137
#DEBOOTSTRAP_DIR=debootstrap
#DEBOOTSTRAP_SOURCE=${DOWNLOAD_DIR}/${DEBOOTSTRAP_DIR}_${DEBOOTSTRAP_VER}.tar.gz
#DEBOOTSTRAP_URL=http://ftp.uk.debian.org/debian/pool/main/d/debootstrap/${DEBOOTSTRAP_DIR}_${DEBOOTSTRAP_VER}.tar.gz
#
#[ -r ${DEBOOTSTRAP_SOURCE} ] || { \
#	mkdir -p `dirname ${DEBOOTSTRAP_SOURCE}` && \
#	wget ${DEBOOTSTRAP_URL} -O ${DEBOOTSTRAP_SOURCE} ;\
#	}
#
#[ -r ${DEBOOTSTRAP_DIR} ] || tar xvzf ${DEBOOTSTRAP_SOURCE}

[ -r ${OS_TEMPDIR}/etc/issue ] || {
	# "minbase" variant is just "Required:" and apt (omits "Important:")
	sudo DEBOOTSTRAP_DIR=${STAGING_DIR}/debootstrap-devuan \
		${STAGING_DIR}/debootstrap-devuan/debootstrap \
		--arch=${OS_ARCH} --variant=minbase \
		--keyring ${STAGING_DIR}/debootstrap-devuan/usr/share/keyrings/devuan-archive-keyring.gpg \
		${OS_SUITE} ${OS_TEMPDIR} ${OS_MIRROR}
	}

[ -r ${OS_TEMPDIR}/etc/hosts ] || {
	# rewrite /etc/hostname and introduce /etc/hosts
	HOSTNAME=${OS_DISTRIBUTION}
	cd ${OS_TEMPDIR}

	printf '%s: %s\n' $0 'Configuring /etc/hostname' &&
	printf '%s\n' "${HOSTNAME}" | tee etc/hostname &&
	printf '%s: %s\n' $0 'Configuring /etc/hosts' &&
	sed "s/_HOSTNAME_/${HOSTNAME}/g" <<__EOH | tee etc/hosts
127.0.0.1	localhost _HOSTNAME_
127.0.1.1	_HOSTNAME_.localdomain.localnet _HOSTNAME_.localdomain

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
__EOH
	}
