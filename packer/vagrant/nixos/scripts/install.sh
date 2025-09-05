#!/bin/sh -e

export MACHINE_TYPE=$([ -d /sys/firmware/efi/efivars ] && echo "UEFI" || echo "Legacy")

echo $MACHINE_TYPE
echo $INSTALL_LOCAL
echo $CONFIG_BRANCH

# Partition disk
echo "Partition disk"

if [ $MACHINE_TYPE == "Legacy" ];then
  parted /dev/sda -- mklabel msdos
  parted /dev/sda -- mkpart primary 1MB -8GB
  parted /dev/sda -- set 1 boot on
  parted /dev/sda -- mkpart primary linux-swap -8GB 100%
elif [ $MACHINE_TYPE == "UEFI" ];then
  parted /dev/sda -- mklabel gpt
  parted /dev/sda -- mkpart root ext4 512MB 100%
  parted /dev/sda -- mkpart ESP fat32 1MB 512MB
  parted /dev/sda -- set 2 esp on
fi

# Create filesystem
echo "Create filesystem"
 
if [ $MACHINE_TYPE == "Legacy" ];then
  mkfs.ext4 -j -L nixos /dev/sda1
elif [ $MACHINE_TYPE == "UEFI" ];then
  mkfs.fat -F 32 -n esp /dev/sda2
  mkfs.ext4 -L nixos /dev/sda1
fi

# Mount filesystem
echo "Mount file systems"
mount LABEL=nixos /mnt
if [ $MACHINE_TYPE == "UEFI" ];then
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
fi

if [ "$INSTALL_LOCAL" = "true" ]; then
  # Setup system
  echo "Setup system"
  nixos-generate-config --root /mnt
  
  if [ $MACHINE_TYPE == "Legacy" ];then
    curl -sf "$PACKER_HTTP_ADDR/configurations/grub-bios.nix" > /mnt/etc/nixos/bootloader.nix
  elif [ $MACHINE_TYPE == "UEFI" ];then
    curl -sf "$PACKER_HTTP_ADDR/configurations/grub-efi.nix" > /mnt/etc/nixos/bootloader.nix
  fi

  curl -sf "$PACKER_HTTP_ADDR/configurations/vagrant-network.nix" > /mnt/etc/nixos/vagrant-network.nix
  curl -sf "$PACKER_HTTP_ADDR/configurations/vagrant-hostname.nix" > /mnt/etc/nixos/vagrant-hostname.nix
  curl -sf "$PACKER_HTTP_ADDR/configurations/builders/$PACKER_BUILDER_TYPE.nix" > /mnt/etc/nixos/hardware-builder.nix
  curl -sf "$PACKER_HTTP_ADDR/configurations/configuration.nix" > /mnt/etc/nixos/configuration.nix
  curl -sf "$PACKER_HTTP_ADDR/configurations/custom-configuration.nix" > /mnt/etc/nixos/custom-configuration.nix
  ### Install ###
  echo "Install system"
  nixos-install

else
  ### Install ###
  echo "Install system"
  # nixos-install --flake github:barnaby0x0/nixos#vagrant
  nixos-install --flake github:barnaby0x0/nixos?ref=${CONFIG_BRANCH}#vagrant

fi

### Cleanup ###
curl "$PACKER_HTTP_ADDR/postinstall.sh" | nixos-enter

