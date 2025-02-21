{ config, lib, ... }:

let cfg = config.custom.ap;
in {
  options.custom.ap = {
    enable = lib.mkEnableOption "Enable AP";
    ssid = lib.mkOption {
      type = lib.types.string;
      default = config.networking.hostName + "-ap";
      description = "AP SSID";
    };
    password = lib.mkOption {
      type = lib.types.string;
      description = "AP password";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wlanInterfaces = {
      wlan0-client = { device = "wlan0"; };
      wlan0-ap = { device = "wlan0"; };
    };

    networking.wireless.interfaces = [ "wlan0-client" ];

    networking.interfaces.wlan0-ap.ipv4.addresses = [{
      address = "192.168.0.1";
      prefixLength = 24;
    }];

    services.hostapd = {
      enable = true;
      radios.wlan0-ap = {
        countryCode = "GB";
        networks.wlan0-ap = {
          ssid = cfg.ssid;
          authentication = {
            mode = "wpa2-sha256";
            wpaPassword = cfg.password;
          };
        };
      };
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        interface = "wlan0-ap";
        bind-interfaces = true;
        dhcp-range = [ "192.168.0.2,192.168.0.254,24h" ];
        dhcp-authoritative = true;
      };
    };

    networking.firewall.allowedUDPPorts = [ 67 ]; # DHCP
  };
}
