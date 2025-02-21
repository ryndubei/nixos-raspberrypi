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
    services.create_ap = {
      enable = true;
      settings = {
        INTERNET_IFACE = "wlan0";
        PASSPHRASE = cfg.password;
        SSID = cfg.ssid;
        WIFI_IFACE = "wlan0";
      };
    };
  };
}
