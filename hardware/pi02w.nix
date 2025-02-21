{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_rpi02w;

  # no ACS on pi zero
  services.hostapd.radios.wlan0.channel = 7;
  services.hostapd.radios.wlan0.wifi4.capabilities =
    [ "HT40" "SHORT-GI-20" "DSSS_CCK-40" ];
}
