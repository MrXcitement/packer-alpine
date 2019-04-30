VAGRANT_USER := $(or $(VAGRANT_CLOUD_USERNAME), mrbarker)
VERSION := 1.0.$(shell date +%s)
PUBLISH_OPTIONS := "--force"

.PHONY: install-boxes install-boxes-amd64 install-boxes-i386
all: install-boxes

install-boxes: install-boxes-amd64 install-boxes-i386

install-boxes-amd64: install-box-amd64-virtualbox

install-boxes-i386: install-box-i386-virtualbox

install-box-amd64-virtualbox: alpine-amd64-virtualbox.box
	vagrant box add -f --name $(VAGRANT_USER)/alpine-amd64 --provider virtualbox alpine-amd64-virtualbox.box

install-box-i386-virtualbox: alpine-i386-virtualbox.box
	vagrant box add -f --name $(VAGRANT_USER)/alpine-i386 --provider virtualbox alpine-i386-virtualbox.box

alpine-amd64-virtualbox.box: alpine-amd64.json *.sh
	PACKER_LOG=1 packer build -force -only virtualbox-iso alpine-amd64.json

alpine-i386-virtualbox.box: alpine-i386.json *.sh
	PACKER_LOG=1 packer build -force -only virtualbox-iso alpine-i386.json

.PHONY: publish-boxes publish-boxes-amd64 publish-boxes-i386 publish-box-amd64-virtualbox publish-box-i386-virtualbox
publish-boxes: publish-boxes-amd64 publish-boxes-i386

publish-boxes-amd64: publish-box-amd64-virtualbox

publish-boxes-i386: publish-box-i386-virtualbox

publish-box-amd64-virtualbox: alpine-amd64-virtualbox.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/alpine-amd64 $(VERSION) virtualbox ./alpine-amd64-virtualbox.box $(PUBLISH_OPTIONS)

publish-box-i386-virtualbox: alpine-i386-virtualbox.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/alpine-i386 $(VERSION) virtualbox ./alpine-i386-virtualbox.box $(PUBLISH_OPTIONS)

.PHONY: clean clean-boxes clean-vagrant clean-artifacts
clean: clean-boxes clean-vagrant clean-artifacts

clean-boxes:
	-rm *.box

clean-vagrant:
	-rm -rf .vagrant

clean-artifacts:
	-rm -rf packer_cache

.PHONY: lint packer-validate shfmt
lint: packer-validate shfmt

packer-validate:
	find . -name '*.json' -exec packer validate {} \;

shfmt:
	find . -name '*.sh' -print | xargs shfmt -w -i 4
