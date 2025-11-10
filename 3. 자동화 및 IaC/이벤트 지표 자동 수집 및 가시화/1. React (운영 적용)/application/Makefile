# Makefile
.PHONY: build run push clean

IMAGE_NAME = dashboard
TAG = latest
REGISTRY = 123456.dkr.ecr.ap-northeast-2.amazonaws.com/dashboard

build:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-f Dockerfiles/Dockerfile \
		-t $(REGISTRY)/$(IMAGE_NAME):$(TAG) \
		--push \
		.

run:
	docker run -p 8080:80 $(IMAGE_NAME):$(TAG)

push:
	docker tag $(IMAGE_NAME):$(TAG) $(REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG) || true
	docker rmi $(IMAGE_NAME):$(TAG)-arm64 || true
	docker rmi $(IMAGE_NAME):$(TAG)-amd64 || true