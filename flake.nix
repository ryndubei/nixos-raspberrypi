{
  # https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html#registering-qemu-emulation-as-a-binfmt-wrapper
  # https://mtlynch.io/nixos-pi4/

  description = "Raspberry Pi system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs = { nixpkgs, nixos-hardware, ... }@inputs:
    let
      lib = nixpkgs.lib;
      raspi-4 = nixos-hardware.nixosModules.raspberry-pi-4;
    in
    {
      nixosConfigurations =
        {
          raspberrypi = lib.nixosSystem
            {
              system = "aarch64-linux";
              specialArgs = { inherit inputs; };
              modules =
                [
                  "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                  ({ ... }: {
                    # Set up for cross-compilation from x86_64 to aarch64
                    nixpkgs.buildPlatform.system = "x86-64-linux";
                    nixpkgs.hostPlatform.system = "aarch64-linux";

                    # Compression is on by default
                    # build.sdImage.compressImage = false;
                  })
                  ./configuration.nix
                  ./hardware-configuration.nix
                  ./encrypted/wifi.nix
                  raspi-4
                ];
            };
        };
    };
}
