{ config, lib, pkgs, ... }:
{
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    accounts = {
      default = {
        host = "smtp.gmail.com";
        tls = true;
        auth = true;
        port = 587;
        user = "tabhooked";
        from = "tabhooked@gmail.com";
        passwordeval = "${pkgs.coreutils}/bin/cat /var/lib/secrets/gmail-pw.txt";
      };
    };
  };
}