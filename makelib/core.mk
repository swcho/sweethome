
HOST_NAME ?= $(shell hostname)

# ref: http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
IMAGE_NAME ?= $(notdir $(shell pwd))

DOCKER_IMAGE := $(HOST_NAME)/$(IMAGE_NAME)

TEMP_BASE := /tmp/docker_builder/$(IMAGE_NAME)

ALL_FILES := $(shell find -type f)

TARGET_FILES := $(addprefix $(TEMP_BASE)/,$(ALL_FILES))

$(TEMP_BASE):
	@mkdir -p $(TEMP_BASE)

$(TEMP_BASE)/%: % $(TEMP_BASE)
	@echo "copy: $< => $@"
	@mkdir -p $(@D)
	@cp $< $@

$(TEMP_BASE)/.built: $(TARGET_FILES)
	@echo "Build [$(IMAGE_NAME)]"
	@docker build -t $(DOCKER_IMAGE) $(TEMP_BASE)
	@touch $(TEMP_BASE)/.built

build: $(TEMP_BASE)/.built

test: build rm
	docker run -h $(IMAGE_NAME) --name $(IMAGE_NAME) -p 80:80 --rm -it $(DOCKER_IMAGE) bash

rm:
	-docker stop $(IMAGE_NAME)
	-docker rm $(IMAGE_NAME)

run: build rm
	docker run -h $(IMAGE_NAME) --name $(IMAGE_NAME) -p 80:80 -d -it $(DOCKER_IMAGE)

push: build

all: push

clean:
	@rm -rf $(TEMP_BASE)
