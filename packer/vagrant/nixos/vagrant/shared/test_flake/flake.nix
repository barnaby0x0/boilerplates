{
  description = "Flake qui wrappe un script Bash";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.x86_64-linux.hello-script = pkgs.stdenv.mkDerivation {
        pname = "hello-script";
        version = "1.0";
        src = ./.;

        installPhase = ''
          mkdir -p $out/bin
          cp hello.sh $out/bin/hello-script
          chmod +x $out/bin/hello-script
        '';
        meta = {
          description = "Un petit script Bash wrappé";
        };
      };

      # Permet d'exécuter directement avec nix run
      apps.x86_64-linux.hello-script = {
        type = "app";
        program = "${self.packages.x86_64-linux.hello-script}/bin/hello-script";
      };

      # DevShell optionnelle
      devShells.x86_64-linux.default = pkgs.mkShell { };
    };
}

