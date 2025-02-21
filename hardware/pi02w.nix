{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_rpi02w;

  # no ACS on pi zero
  services.hostapd.radios.wlan0-ap.channel = 7;
  services.hostapd.radios.wlan0-ap.wifi4.capabilities =
    [ "HT40" "SHORT-GI-20" "DSSS_CCK-40" ];
}
