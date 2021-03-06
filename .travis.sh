#!/bin/bash
REVISION=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
REVISION=$(git rev-parse --short HEAD)
LAST_COMMIT_DATE=$(git log -1 --date=short --format="%cd")
TARGET_FILE=obj/cleanflight_${TARGET}

# A hacky way of running the unit tests at the same time as the normal builds.
if [ $RUNTESTS ] ; then
	cd ./src/test && make test

elif [ $PUBLISHMETA ] ; then
	if [ $PUBLISH_URL ] ; then
		RECENT_COMMITS=$(git shortlog -n25)
		curl -k \
			--form "recent_commits=${RECENT_COMMITS}" \
			--form "revision=${REVISION}" \
			--form "branch=${BRANCH}" \
			--form "last_commit_date=${LAST_COMMIT_DATE}" \
			--form "travis_build_number=${TRAVIS_BUILD_NUMBER}" \
			${PUBLISH_URL}
	fi
else
	if [ $PUBLISH_URL ] ; then
		make -j2
		if   [ -f ${TARGET_FILE}.bin ] ; then
                        TARGET_FILE=${TARGET_FILE}.bin
		elif [ -f ${TARGET_FILE}.hex ] ; then
                        TARGET_FILE=${TARGET_FILE}.hex
		else
			echo "build artifact (hex or bin) for ${TARGET_FILE} not found, aborting";
			exit 1
		fi
	
		curl -k \
			--form "file=@${TARGET_FILE}" \
			--form "revision=${REVISION}" \
			--form "branch=${BRANCH}" \
			--form "last_commit_date=${LAST_COMMIT_DATE}" \
			--form "travis_build_number=${TRAVIS_BUILD_NUMBER}" \
			${PUBLISH_URL}
	else
		make -j2
	fi
fi
