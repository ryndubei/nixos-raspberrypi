# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2daa10c2-8624-45b7-853b-aa8690e7b736";
      fsType = "ext4";
    };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
