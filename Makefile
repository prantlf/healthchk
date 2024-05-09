VFLAGS=
ifeq (1,${RELEASE})
	VFLAGS:=$(VFLAGS) -prod
endif
ifeq (1,${MACOS_ARM})
	VFLAGS:=-cflags "-target arm64-apple-darwin" $(VFLAGS)
endif
ifeq (1,${LINUX_ARM})
	VFLAGS:=-cc aarch64-linux-gnu-gcc $(VFLAGS)
endif
ifeq (1,${WINDOWS})
	VFLAGS:=-os windows $(VFLAGS)
endif

all: check build test

check:
	v fmt -w .
	v vet .

build:
	v $(VFLAGS) -o healthchk .

test:
	./test.sh

docker: docker-lint docker-build docker-test

docker-lint:
	docker run --rm -i \
		-v ${PWD}/.hadolint.yaml:/bin/hadolint.yaml \
		-e XDG_CONFIG_HOME=/bin hadolint/hadolint \
		< Dockerfile

docker-build:
	docker build -t healthchk .

docker-test:
	docker build -t healthchk-test -f Dockerfile.test .

docker-enter:
	docker run --rm -it --entrypoint sh healthchk-test
