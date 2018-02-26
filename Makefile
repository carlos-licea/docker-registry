run: build
	docker run --privileged -it -v ./images:/images docker-registry

build:
	docker build --label=docker-registry .
