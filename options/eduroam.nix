{ config, lib, ... }:

let cfg = config.custom.eduroam;
in {
  options.custom.eduroam = {
    enable = lib.mkEnableOption "Enable connecting to eduroam";
    identity = lib.mkOption {
      type = lib.types.str;
      description = "username@domain";
    };
    password = lib.mkOption { type = lib.types.str; };
  };
  config = lib.mkIf cfg.enable {
    networking.wireless.enable = true;
    networking.wireless.networks."eduroam" = {
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        password="${cfg.password}"
        identity="${cfg.identity}"
        pairwise=CCMP
        phase1="peapver=0"
        phase2="auth=MSCHAPV2"
        ca_cert="/etc/ssl/certs/ca-bundle.crt"
      '';
    };
  };
}
