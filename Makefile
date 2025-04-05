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

DOWNLOAD_DIR?=${TOPLEV}/downloads
STAGING_DIR?=${TOPLEV}/staging


## Build rules

.PHONY: help
help:
	@printf '%s: %s\n' \
		$(firstword ${MAKEFILE_LIST})
	@printf '\t%s\n' \
		"'all' target builds image for ${OS_DISTRIBUTION}" \
		"'clean' target removes the staging tree" \
		"'distclean' target cleans staging and download trees"


#

${DOWNLOAD_DIR}: ; @mkdir -p $@

${STAGING_DIR}: ; @mkdir -p $@


#

.PHONY: all
all: | ${DOWNLOAD_DIR} ${STAGING_DIR}

#

.PHONY: clean
clean:
	[ ! -d "${STAGING_DIR}" ] || sudo rm -rf "${STAGING_DIR}"
	-rm -rf wget-log*

.PHONY: distclean
distclean: clean
	[ ! -d "${DOWNLOAD_DIR}" ] || rm -rf "${DOWNLOAD_DIR}"
