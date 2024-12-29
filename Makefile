#!/usr/bin/make

# "Axiomatic" - build system for basic Debian-family live system images
# (c) and GPLv2 William Towle <william_towle@yahoo.co.uk> 2017-2024
# Debian, Devuan, and related projects have their own copyright/licences

#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *


.PHONY: default
default: all


# Configuration

TOPLEV=${CURDIR}
export DOWNLOAD_DIR?=${TOPLEV}/downloads
export STAGING_DIR?=${TOPLEV}/staging
export GRUBISO_STAGING_DIR?=${STAGING_DIR}/grubiso
export LIVESFS_STAGING_DIR?=${STAGING_DIR}/livesfs

export MEDIA_TYPE?=livesfs
#export MEDIA_TYPE?=grubiso

export IMAGE_NAME?=${STAGING_DIR}/${MEDIA_TYPE}.img
#export IMAGE_SIZE?=$(shell echo "$$(( 0x76d00000 ))")
export IMAGE_SIZE?=$(shell echo "$$(( 0x78000000 ))")

export OS_DISTRIBUTION?=debian
export OS_TEMPDIR?=${STAGING_DIR}/${OS_DISTRIBUTION}-rootfs


##

DOWNLOAD_TARGETS:=

include build-media/common.mk
include build-os/common.mk


.PHONY: download-file
download-file:
	[ -r ${DESTFILE} ] || wget ${URL} -O ${DESTFILE}


.PHONY: downloads
downloads:
ifneq (${DOWNLOAD_TARGETS},)
	mkdir -p ${DOWNLOAD_DIR}
	make ${DOWNLOAD_TARGETS}
endif


.PHONY: all
all: downloads
	mkdir -p ${STAGING_DIR}
	make media-prepare
	mkdir -p ${OS_TEMPDIR}
	make os-init
	make media-deploy


.PHONY: clean
clean:
	-[ "${STAGING_DIR}" ] && rm -rf ${STAGING_DIR}

.PHONY: distclean
distclean: clean
	-[ "${DOWNLOAD_DIR}" ] && rm -rf ${DOWNLOAD_DIR}
