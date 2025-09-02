#!/run/current-system/sw/bin/bash
nix flake init -t github:barnaby0x0/nixos-templates#iso-standard && \
  nix run nixpkgs#nixos-generators -- -f iso -c ./configuration.nix
