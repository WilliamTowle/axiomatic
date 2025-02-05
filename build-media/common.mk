#!/usr/bin/make

.PHONY: media-prepare media-deploy

#MEDIA_TYPE?=biosefi
#MEDIA_TYPE?=gptimg
MEDIA_TYPE?=livesfs

media-prepare:
	@printf '%s: Reached '%s' at %s\n' \
		$(firstword ${MAKEFILE_LIST}) $@ "`date '+%F %T'`"
	[ ! -r ./build-media/${MEDIA_TYPE}-prepare.sh ] || \
		./build-media/${MEDIA_TYPE}-prepare.sh ${IMAGE_NAME} ${IMAGE_SIZE}


media-deploy:
	@printf '%s: Reached '%s' at %s\n' \
		$(firstword ${MAKEFILE_LIST}) $@ "`date '+%F %T'`"
	./build-media/${MEDIA_TYPE}-deploy.sh ${IMAGE_NAME} ${OS_TEMPDIR}
