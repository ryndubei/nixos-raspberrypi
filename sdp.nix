{ lib, ... }:

{
  # don't think inf would react well to tailscale, will have to just
  # SSH through student.ssh.inf.ed.ac.uk -> sdp-ranger
  services.tailscale.enable = lib.mkForce false;

  # altenatively: connect over the advertised AP
  services.hostapd.enable = true;
  services.hostapd.radios.wlan0.networks.wlan0.authentication.wpaPassword =
    "group13_";

  # Enable password login over the terminal
  users.users.raspbius.password = "group13";
  console.enable = lib.mkForce true;
}
