{ lib, ... }:

{
  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;
  networking.wireless.allowAuxiliaryImperativeNetworks = true;

  networking.wireless.networks."SDProbots".psk = "robotsRus";

  # don't think inf would react well to tailscale, will have to just
  # SSH through student.ssh.inf.ed.ac.uk -> sdp-ranger
  services.tailscale.enable = lib.mkForce false;

  # Enable password login over the terminal
  users.users.raspbius.password = "group13";
  console.enable = lib.mkForce true;
}
