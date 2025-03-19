{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.msmtp-gmail;
in
{
  options.custom.msmtp-gmail = {
    enable = mkEnableOption "Enable msmtp using gmail";
  };

  config = mkIf cfg.enable {
    environment.etc."aliases" = {
      text = ''
        root: tabhooked@gmail.com
      '';
      mode = "0644";
    };

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults.aliases = "/etc/aliases";
      accounts = {
        default = {
          host = "smtp.gmail.com";
          tls = true;
          auth = true;
          port = 587;
          user = "swiftyswindler";
          from = "swiftyswindler@gmail.com";
          passwordeval = "${pkgs.coreutils}/bin/cat /var/lib/secrets/gmail-pw.txt";
        };
      };
    };
  };
}
