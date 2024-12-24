#!/usr/bin/make

.PHONY: media-prepare media-deploy

MEDIA_TYPE?=livesfs

media-prepare:
	[ ! -r ./build-media/${MEDIA_TYPE}-prepare.sh ] || \
		./build-media/${MEDIA_TYPE}-prepare.sh ${IMAGE_NAME} ${IMAGE_SIZE}


media-deploy:
	./build-media/${MEDIA_TYPE}-deploy.sh ${IMAGE_NAME} ${OS_TEMPDIR}
