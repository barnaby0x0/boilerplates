.PHONY: all build add clean

all: build_base add clean

build_base:
	export PACKER_LOG_PATH="./packer.log" && export PACKER_LOG=10 && packer build -var-file=vars/nixos.base.pkrvars.hcl nixos.pkr.hcl

add:
	@vagrant box add ./metadata.json

raw-convert:
	@qemu-img convert -f qcow2 -O raw ~/releases/packer/base_boxes/nixos25.05/base/nixos25.05-base.qcow2 ~/releases/packer/base_boxes/nixos25.05/base/nixos25.05-base.raw
	@gzip ~/releases/packer/base_boxes/nixos25.05/base/nixos25.05-base.raw

clean:
	@rm -rf "/home/user/releases/packer/base_boxes/nixos25.05/base"

