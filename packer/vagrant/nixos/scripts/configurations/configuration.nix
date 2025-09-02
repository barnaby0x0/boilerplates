{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-builder.nix
      ./bootloader.nix
      ./custom-configuration.nix
      ./vagrant-network.nix
      ./vagrant-hostname.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # remove the fsck that runs at startup. It will always fail to run, stopping
  # your boot until you press *.
  boot.initrd.checkJournalingFS = false;

  networking.hostName = "vagrant";
  # Services to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.extraConfig =
    ''
      PubkeyAcceptedKeyTypes +ssh-rsa
    '';

  # Enable DBus
  services.dbus.enable    = true;

  # Replace ntpd by timesyncd
  services.timesyncd.enable = true;

  
  ## Minimal setup to make it works with Vagrant next to this build
  # Minimal configuration for NFS support with Vagrant.
  #services.nfs.server.enable = true;
  
  ## Add firewall exception for VirtualBox provider 
  #networking.firewall.extraCommands = ''
  #  ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  #'';

  ## Add firewall exception for libvirt provider when using NFSv4 
  #networking.firewall.interfaces."virbr1" = {                                   
  #  allowedTCPPorts = [ 2049 ];                                               
  #  allowedUDPPorts = [ 2049 ];                                               
  #};  

  # Packages for Vagrant
  environment.systemPackages = with pkgs; [
    findutils
    git
    gnumake
    htop
    iputils
    jq
    netcat
    nettools
    nfs-utils
    rsync
    vim
    zsh
  ];

  users.users.root = { password = "vagrant"; };
  # Creates a "vagrant" group & user with password-less sudo access
  users.groups = {
    vagrant = {
      name = "vagrant";
      members = [ "vagrant" ];
    };
  };
  
  users.users = {

    vagrant = {
      description     = "Vagrant User";
      name            = "vagrant";
      group           = "vagrant";
      extraGroups     = [ "users" "wheel" ];
      #password        = "vagrant";
      hashedPasswordFile = "/etc/nixos/secrets/passwords/vagrant/hashed_password";
      home            = "/home/vagrant";
      createHome      = true;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y vagrant insecure public key"
      ];
      isNormalUser = true;
    };

  };

  security.sudo.extraConfig =
    ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=NIX_PATH
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture = never
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

}

