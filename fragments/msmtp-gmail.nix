{ config, lib, pkgs, ... }:
{
  programs.msmtp = {
    enable = true;
    accounts = {
      default = {
        host = "smtp.gmail.com";
        tls = true;
        auth = true;
        port = 587;
        user = "tabhooked";
        from = "tabhooked@gmail.com";
        passwordeval = "cat /var/lib/secrets/gmail-pw.txt";
      };
    };
  };
}