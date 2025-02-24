{ lib, ... }:

{
  networking.wireless.enable = true;

  networking.wireless.networks."SDProbots".psk = "robotsRus";

  # SDProbots has no DHCP, must use static IP
  networking.interfaces.wlan0.useDHCP = false;
  networking.interfaces.wlan0.ipv4.addresses = [{
    address = "192.168.105.169";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.105.243";

  # don't think inf would react well to tailscale, will have to just
  # SSH through student.ssh.inf.ed.ac.uk -> sdp-ranger
  services.tailscale.enable = lib.mkForce false;

  # syncthing will use ~6% of RAM otherwise
  home-manager.users.raspbius.services.syncthing.enable = lib.mkForce false;

  # Enable password login over the terminal
  users.users.raspbius.password = "group13";
  console.enable = lib.mkForce true;
}
