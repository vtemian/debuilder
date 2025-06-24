# Makefile for building and pushing debuilder Docker images

# Docker namespace
NAMESPACE = vtemian
IMAGE_NAME = debuilder

# Supported Ubuntu versions
VERSIONS = bionic focal jammy noble

# Default target
.PHONY: all
all: build

# Build all images
.PHONY: build
build: $(addprefix build-,$(VERSIONS))

# Generic build target
.PHONY: build-%
build-%:
	docker build -f Dockerfile.$* -t $(NAMESPACE)/$(IMAGE_NAME):$* .

# Push all images
.PHONY: push
push: $(addprefix push-,$(VERSIONS))

# Generic push target
.PHONY: push-%
push-%:
	docker push $(NAMESPACE)/$(IMAGE_NAME):$*

# Build and push all images
.PHONY: release
release: build push

# Clean local images
.PHONY: clean
clean:
	@for version in $(VERSIONS); do \
		docker rmi $(NAMESPACE)/$(IMAGE_NAME):$$version 2>/dev/null || true; \
	done

# Show available targets
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make build          - Build all Docker images"
	@echo "  make build-VERSION  - Build specific version (e.g., make build-focal)"
	@echo "  make push           - Push all Docker images to Docker Hub"
	@echo "  make push-VERSION   - Push specific version (e.g., make push-focal)"
	@echo "  make release        - Build and push all images"
	@echo "  make clean          - Remove all local images"
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Supported versions: $(VERSIONS)"

# Test a specific version
.PHONY: test-%
test-%:
	@echo "Testing with $* version..."
	docker run --rm -v $(PWD)/test:/source -v $(PWD)/test-output:/target $(NAMESPACE)/$(IMAGE_NAME):$* || echo "No test directory found"