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
  };

  outputs =
    { self, nixpkgs, nixos-hardware, home-manager, deploy-rs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      raspi-4 = nixos-hardware.nixosModules.raspberry-pi-4;
      raspi-3 = nixos-hardware.nixosModules.raspberry-pi-3;
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

      git-cfg = {
        home-manager.users.raspbius = {
          programs.git.userName = "ryndubei";
          programs.git.userEmail =
            "114586905+ryndubei@users.noreply.github.com";
        };
      };
    in {
      nixosConfigurations = {
        sdp = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./configuration.nix
            ./encrypted/wifi_sdp.nix
            raspi-3
            hm
            {
              networking.hostName = "sdp-ranger";
              # don't think inf would react well to tailscale, will have to just
              # SSH through student.ssh.inf.ed.ac.uk -> sdp-ranger
              services.tailscale.enable = lib.mkForce false;
              users.users.raspbius.password = "group13";
              console.enable = lib.mkForce true;
            }
          ];
        };
        pi-zero = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./configuration.nix
            ./encrypted/wifi.nix
            hm
            git-cfg
            {
              networking.hostName = "zero";
              boot.kernelPackages = pkgs.linuxPackages_rpi02w;
            }
          ];
        };
        raspberrypi = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./configuration.nix
            ./encrypted/wifi.nix
            raspi-4
            hm
            git-cfg
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
      deploy.nodes.sdp = {
        hostname = "192.168.193.174";
        profiles.system = {
          sshUser = "raspbius";
          user = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos
            self.nixosConfigurations.sdp;
        };
      };
    };
}
