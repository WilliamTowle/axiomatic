#!/usr/bin/make

export OS_ARCH?=i386

## Configuration

ifeq (${OS_DISTRIBUTION},debian)
export OS_SUITE?=bookworm
export OS_MIRROR?=http://ftp.uk.debian.org/debian/

DEBIAN_DEBOOTSTRAP_VER=1.0.124
DEBIAN_DEBOOTSTRAP_TARBALL=${DOWNLOAD_DIR}/debootstrap_${DEBIAN_DEBOOTSTRAP_VER}.tar.gz
DEBIAN_DEBOOTSTRAP_URL=https://snapshot.debian.org/archive/debian/20210814T212851Z/pool/main/d/debootstrap/$(notdir ${DEBIAN_DEBOOTSTRAP_TARBALL})

DEBIAN_KEYRING_VER=2023.4
DEBIAN_KEYRING_PACKAGE=${DOWNLOAD_DIR}/debian-archive-keyring_${DEBIAN_KEYRING_VER}_all.deb
DEBIAN_KEYRING_URL=http://ftp.uk.debian.org/debian/pool/main/d/debian-archive-keyring/$(notdir ${DEBIAN_KEYRING_PACKAGE})


DOWNLOAD_TARGETS+= ${DEBIAN_DEBOOTSTRAP_TARBALL}
DOWNLOAD_TARGETS+= ${DEBIAN_KEYRING_PACKAGE}

${DEBIAN_DEBOOTSTRAP_TARBALL}:
	make download-file URL=${DEBIAN_DEBOOTSTRAP_URL} DESTFILE=$@

${DEBIAN_KEYRING_PACKAGE}:
	make download-file URL=${DEBIAN_KEYRING_URL} DESTFILE=$@
endif	## OS_DISTRIBUTION=debian

ifeq (${OS_DISTRIBUTION},devuan)
export OS_SUITE?=daedalus
export OS_MIRROR?=http://deb.devuan.org/merged

#DEVUAN_DEBOOTSTRAP_VER=1.0.89+devuan2.1
#DEVUAN_DEBOOTSTRAP_VER=1.0.114+devuan5
#DEVUAN_DEBOOTSTRAP_VER=1.0.123+devuan5
#DEVUAN_DEBOOTSTRAP_VER=1.0.134devuan2
DEVUAN_DEBOOTSTRAP_VER=1.0.138devuan1
DEVUAN_DEBOOTSTRAP_TARBALL=${DOWNLOAD_DIR}/debootstrap_${DEVUAN_DEBOOTSTRAP_VER}.tar.gz
DEVUAN_DEBOOTSTRAP_URL=http://deb.devuan.org/devuan/pool/main/d/debootstrap/$(notdir ${DEVUAN_DEBOOTSTRAP_TARBALL})

#DEVUAN_KEYRING_VER=2022.09.04
DEVUAN_KEYRING_VER=2023.10.07
#DEVUAN_KEYRING_PACKAGE=${DOWNLOAD_DIR}/devuan-keyring_${DEVUAN_KEYRING_VER}_all.deb
DEVUAN_KEYRING_PACKAGE=${DOWNLOAD_DIR}/devuan-keyring-udeb_${DEVUAN_KEYRING_VER}_all.udeb
#DEVUAN_KEYRING_TARBALL=${DOWNLOAD_DIR}/devuan-keyring_${DEVUAN_KEYRING_VER}.tar.xz
DEVUAN_KEYRING_URL=http://deb.devuan.org/devuan/pool/main/d/devuan-keyring/$(notdir ${DEVUAN_KEYRING_PACKAGE})
#DEVUAN_KEYRING_URL=http://deb.devuan.org/devuan/pool/main/d/devuan-keyring/$(notdir ${DEVUAN_KEYRING_TARBALL})


DOWNLOAD_TARGETS+= ${DEVUAN_DEBOOTSTRAP_TARBALL}
DOWNLOAD_TARGETS+= ${DEVUAN_KEYRING_PACKAGE}
#DOWNLOAD_TARGETS+= ${DEVUAN_KEYRING_TARBALL}

${DEVUAN_DEBOOTSTRAP_TARBALL}:
	make download-file URL=${DEVUAN_DEBOOTSTRAP_URL} DESTFILE=$@

${DEVUAN_KEYRING_PACKAGE}:
#${DEVUAN_KEYRING_TARBALL}:
	make download-file URL=${DEVUAN_KEYRING_URL} DESTFILE=$@
endif	## OS_DISTRIBUTION=devuan


.PHONY: os-init os-build

os-init:
ifeq (${OS_DISTRIBUTION},debian)
	mkdir -p ${STAGING_DIR}/debootstrap-debian
	[ -r ${STAGING_DIR}/debootstrap-debian/debootstrap ] || ( cd ${STAGING_DIR}/debootstrap-debian && tar xvzf ${DEBIAN_DEBOOTSTRAP_TARBALL} --strip-components=1 )
	[ -r ${STAGING_DIR}/debootstrap-debian/usr/share/keyrings/debian-archive-keyring.gpg ] || ( cd ${STAGING_DIR}/debootstrap-debian && dpkg -x ${DEBIAN_KEYRING_PACKAGE} ./ )
endif
ifeq (${OS_DISTRIBUTION},devuan)
	mkdir -p ${STAGING_DIR}/debootstrap-devuan
	[ -r ${STAGING_DIR}/debootstrap-devuan/debootstrap ] || ( cd ${STAGING_DIR}/debootstrap-devuan && tar xvzf ${DEVUAN_DEBOOTSTRAP_TARBALL} --strip-components=1 )
	[ -r ${STAGING_DIR}/debootstrap-devuan/usr/share/keyrings/devuan-archive-keyring.gpg ] || ( cd ${STAGING_DIR}/debootstrap-devuan && dpkg -x ${DEVUAN_KEYRING_PACKAGE} ./ )
endif
	sh ./build-os/${OS_DISTRIBUTION}-init.sh ${OS_TEMPDIR} ${OS_SUITE} ${OS_MIRROR} ${OS_ARCH}

os-build:
	[ "${OS_DESTDIR}" ] && ./build-os/${OS_DISTRIBUTION}-build.sh ${OS_DESTDIR}
