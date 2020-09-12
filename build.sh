#! /bin/bash

set -e
set -x

NAME="jasonish/suricata"
VERSION="master"
BUILD_DATE="$(date)"

for arg in $@; do
    case "${arg}" in
        push|--push)
            push=yes
            ;;
        *)
            echo "error: bad argument: ${arg}"
            exit 1
    esac
done

# Get the number of cores, defaulting to 2 if unable to get.
cores=$(cat /proc/cpuinfo | grep ^processor | wc -l)
if [ "${cores}" = "0" ]; then
    cores=2
fi

docker build \
       --build-arg CORES="${cores}" \
       --build-arg BUILD_DATE="${BUILD_DATE}" \
       --tag ${NAME}:${VERSION}-amd64 \
       -f Dockerfile.centos-amd64 \
       .

docker build \
       --build-arg CORES="${cores}" \
       --build-arg BUILD_DATE="${BUILD_DATE}" \
       --tag ${NAME}:${VERSION}-arm32v6 \
       -f Dockerfile.alpine-arm32v6 \
       .

if [ "${push}" = "yes" ]; then

    docker push ${NAME}:${VERSION}-amd64
    docker push ${NAME}:${VERSION}-arm32v6
    
    docker manifest create ${NAME}:${VERSION} \
           -a ${NAME}:${VERSION}-amd64 \
           -a ${NAME}:${VERSION}-arm32v6       
    
    docker manifest annotate --arch arm --variant v6 \
           ${NAME}:${VERSION} ${NAME}:${VERSION}-arm32v6
    
    docker manifest push ${NAME}:${VERSION}
fi
