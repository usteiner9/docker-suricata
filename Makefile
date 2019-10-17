NAME :=	jasonish/suricata
TAG ?=	$(shell git rev-parse --abbrev-ref HEAD)

CORES :=$(shell cat /proc/cpuinfo | grep ^processor | wc -l)

DOCKER ?=docker

all: build

build:
	${DOCKER} build --pull --rm -t ${NAME}:${TAG} --build-arg CORES="${CORES}" .

clean:
	find . -name \*~ -print0 | xargs -0 rm -f

push-branch: build
	${DOCKER} push ${NAME}:${TAG}

push-version: VERSION = $(shell expr "`docker run jasonish/suricata:${TAG} -V`" : ".*\([0-9]\.[0-9]\.[0-9]\).*")
push-version: build
	docker tag ${NAME}:${TAG} ${NAME}:${VERSION}
	docker push ${NAME}:${VERSION}

push: build push-branch push-version
