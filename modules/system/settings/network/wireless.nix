{
  flake.modules.nixos.wireless = {
    # Ensure group exists
    users.groups.network = {};
    systemd.services.wpa_supplicant.preStart = "touch /etc/wpa_supplicant.conf";

    networking.wireless = {
      enable = true;
      # fallbackToWPA2 = false;
      # Declarative
      # environmentFile = config.sops.secrets.wireless.path;
      # networks = {
      # "eduroam" = { # TODO: eduroam
      #   authProtocols = [ "WPA-EAP" ];
      #   auth = ''
      #     pairwise=CCMP
      #     group=CCMP TKIP
      #     eap=TTLS
      #     domain_suffix_match=""
      #     ca_cert="${./eduroam-cert.pem}"
      #     identity=""
      #     password="@EDUROAM@"
      #     phase2="auth=MSCHAPV2"
      #   '';
      # };
      # };

      # Imperative
      allowAuxiliaryImperativeNetworks = true;
      userControlled = {
        enable = true;
        group = "network";
      };
      extraConfig = ''
        ctrl_interface=DIR=/run/wpa_supplicant GROUP=network
        update_config=1
      '';
    };
  };
}
