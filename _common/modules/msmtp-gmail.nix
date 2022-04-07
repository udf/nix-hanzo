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
    programs.msmtp = {
      enable = true;
      setSendmail = true;
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
