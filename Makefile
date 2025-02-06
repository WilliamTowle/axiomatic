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
SU_ENV=

export DOWNLOAD_DIR?=${TOPLEV}/downloads
SU_ENV+=DOWNLOAD_DIR=${DOWNLOAD_DIR}
export STAGING_DIR?=${TOPLEV}/staging
SU_ENV+= STAGING_DIR=${STAGING_DIR}
export GRUBISO_STAGING_DIR?=${STAGING_DIR}/grubiso
SU_ENV+= GRUBISO_STAGING_DIR=${GRUBISO_STAGING_DIR}
export LIVESFS_STAGING_DIR?=${STAGING_DIR}/livesfs
SU_ENV+= LIVESFS_STAGING_DIR=${LIVESFS_STAGING_DIR}

#export MEDIA_TYPE?=biosefi
#export MEDIA_TYPE?=gptimg
export MEDIA_TYPE?=livesfs
TRACE:=$(shell echo "[WmT] env has MEDIA_TYPE=${MEDIA_TYPE}" 1>&2)
#export MEDIA_TYPE?=grubiso
SU_ENV+= MEDIA_TYPE=grubiso

export IMAGE_NAME?=${STAGING_DIR}/${MEDIA_TYPE}.img
SU_ENV+= IMAGE_NAME=${IMAGE_NAME}
#export IMAGE_SIZE?=$(shell echo "$$(( 0x76d00000 ))")
export IMAGE_SIZE?=$(shell echo "$$(( 0x78000000 ))")
SU_ENV+= IMAGE_SIZE=${IMAGE_SIZE}

export OS_DISTRIBUTION?=debian
#export OS_DISTRIBUTION?=ubuntu
SU_ENV+= OS_DISTRIBUTION=${OS_DISTRIBUTION}
export OS_TEMPDIR?=${STAGING_DIR}/${OS_DISTRIBUTION}-rootfs
SU_ENV+= OS_TEMPDIR=${OS_TEMPDIR}

##

DOWNLOAD_TARGETS:=

include build-media/common.mk
include build-os/common.mk


.PHONY: download-file
download-file:
	wget --spider ${URL} && wget ${URL} -O ${DESTFILE}


.PHONY: downloads
downloads:
ifneq (${DOWNLOAD_TARGETS},)
	mkdir -p ${DOWNLOAD_DIR}
	make ${DOWNLOAD_TARGETS}
endif

##

.PHONY: help
help:
	@printf '%s: %s\n' \
		$(firstword ${MAKEFILE_LIST})
	@printf '\t%s\n' \
		"'make' builds ${MEDIA_TYPE} type image for ${OS_DISTRIBUTION}" \
		"'clean' removes the staging tree" \
		"'distclean' cleans staging and download trees"

.PHONY: all
all: downloads
	mkdir -p ${STAGING_DIR}
	make media-prepare
	mkdir -p ${OS_TEMPDIR}
	sudo env ${SU_ENV} make os-init media-deploy


.PHONY: clean
clean:
	-[ "${STAGING_DIR}" ] && { rm -rf ${STAGING_DIR} || sudo rm -rf ${STAGING_DIR} ; }

.PHONY: distclean
distclean: clean
	-[ "${DOWNLOAD_DIR}" ] && rm -rf ${DOWNLOAD_DIR}
