{ pkgs, ... }:

{
  # See https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4
  #hardware = {
  #  raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  #  deviceTree = {
  #    enable = true;
  #    filter = "*rpi-4-*.dtb";
  #  };
  #};

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];
}
