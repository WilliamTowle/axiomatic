#!/usr/bin/make

# "Axiomatic" - build system for basic Debian-family system images
# (c) and GPLv2 William Towle <william_towle@yahoo.co.uk> 2017-2024
# Debian, Devuan, et al have their own copyright/licences

#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *


.PHONY: default
default: help


## Configuration

TOPLEV=${CURDIR}
export DOWNLOAD_DIR?=${TOPLEV}/downloads
export STAGING_DIR?=${TOPLEV}/staging
export GRUBISO_STAGING_DIR?=${STAGING_DIR}/grubiso
export LIVESFS_STAGING_DIR?=${STAGING_DIR}/livesfs

export MEDIA_TYPE?=livesfs
#export MEDIA_TYPE?=grubiso

export IMAGE_NAME?=${STAGING_DIR}/${MEDIA_TYPE}.img
export IMAGE_SIZE?=$(shell echo "$$(( 0x80000000 ))")

export OS_DISTRIBUTION?=debian
export OS_TEMPDIR?=${STAGING_DIR}/${OS_DISTRIBUTION}-rootfs

DOWNLOAD_TARGETS:=


include build-media/common.mk
include build-os/common.mk


## Build rules

.PHONY: help
help:
	@printf '%s: %s\n' \
		$(firstword ${MAKEFILE_LIST})
	@printf '\t%s\n' \
		"'all' target builds ${MEDIA_TYPE} type image for ${OS_DISTRIBUTION}" \
		"'clean' target removes the staging tree" \
		"'distclean' target cleans staging and download trees"

#

${DOWNLOAD_DIR}: ; @mkdir -p $@

${STAGING_DIR}: ; @mkdir -p $@

${OS_TEMPDIR}: ; @mkdir -p $@

#

.PHONY: download-file
download-file:
	wget --spider ${URL} && wget ${URL} -O ${DESTFILE}


#

.PHONY: downloads
downloads: | ${DOWNLOAD_DIR}
ifneq (${DOWNLOAD_TARGETS},)
	make ${DOWNLOAD_TARGETS}
endif


#

.PHONY: all
all: | ${STAGING_DIR} ${OS_TEMPDIR}
	make downloads
	make media-prepare
	make os-init
	make media-deploy

#

.PHONY: clean
clean:
	[ ! -d "${STAGING_DIR}" ] || sudo rm -rf "${STAGING_DIR}"
	-rm -rf wget-log*

.PHONY: distclean
distclean: clean
	[ ! -d "${DOWNLOAD_DIR}" ] || rm -rf "${DOWNLOAD_DIR}"
