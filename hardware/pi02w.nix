{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_rpi02w;
}
