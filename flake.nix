{
  # https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html#registering-qemu-emulation-as-a-binfmt-wrapper
  # https://mtlynch.io/nixos-pi4/

  description = "Raspberry Pi system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    nixos-user = {
      url = "github:ryndubei/nixos-user";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fps.url = "github:wamserma/flake-programs-sqlite";
    fps.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, nixos-user, home-manager, deploy-rs
    , fps, ... }:
    let
      lib = nixpkgs.lib;
      raspi-4 = nixos-hardware.nixosModules.raspberry-pi-4;
      hm = home-manager.nixosModules.home-manager;
      system = "aarch64-linux";

      pkgs = import nixpkgs { inherit system; };
      # Use nixpkgs binary cache for deploy-rs
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlay
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };

      programsdb = fps.packages.${system}.programs-sqlite;

      specialArgs = { inherit nixos-user programsdb; };
    in {
      nixosConfigurations = {
        pi-zero = lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./configuration.nix
            ./encrypted/wifi.nix
            ./hardware/pi02w.nix
            ./git.nix
            hm
            { networking.hostName = "zero"; }
          ];
        };
        raspberrypi = lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./configuration.nix
            ./encrypted/wifi.nix
            ./hardware/pi4.nix
            ./git.nix
            raspi-4
            hm
            { networking.hostName = "raspberrypi"; }
          ];
        };
      };

      # deploy-rs node configuration
      deploy.nodes.raspberrypi = {
        hostname = "raspberrypi"; # via ssh alias
        profiles.system = {
          sshUser = "raspbius";
          user = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos
            self.nixosConfigurations.raspberrypi;
        };
      };
      deploy.nodes.pi-zero = {
        hostname = "zero";
        profiles.system = {
          sshUser = "raspbius";
          user = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos
            self.nixosConfigurations.pi-zero;
        };
      };
    };
}
