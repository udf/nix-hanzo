{ config, lib, pkgs, ... }:
let
  userId = toString config.users.users.nicotine.uid;
  XDisplay = "100";
in
{
  # TODO: move this to a generic module if more gui users are needed
  systemd.services.xpra-nicotine = {
    description = "Xpra for nicotine";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "nicotine";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/home/nicotine";
      ExecStart = ''
        ${pkgs.xpra}/bin/xpra start \
          --daemon=off \
          --opengl=on \
          --clipboard=on \
          --notifications=on \
          --speaker=off \
          --mdns=no \
          --webcam=no \
          --pulseaudio=no \
          --html=off \
          --printing=no \
          :${XDisplay}
      '';
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 30";
    };
  };

  fonts.fonts = with pkgs; [ noto-fonts noto-fonts-cjk ];

  systemd.services.nicotine-plus = {
    description = "nicotine-plus running on Xpra";
    requires = [ "xpra-nicotine.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      DISPLAY = ":${XDisplay}";
      XDG_DATA_DIRS = "${pkgs.gnome.adwaita-icon-theme}/share";
      XCURSOR_PATH = "/home/nicotine/.icons:${pkgs.gnome.adwaita-icon-theme}/share/icons";
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };

    serviceConfig = {
      User = "nicotine";
      EnvironmentFile = "/run/user/${userId}/xpra/${XDisplay}/dbus.env";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/home/nicotine";
      ExecStart = "${pkgs.nicotine-plus}/bin/nicotine-plus";
      UMask = "0002";
    };
  };

  networking.firewall.allowedTCPPorts = [ 2234 ];

  users.users.nicotine = {
    isNormalUser = true;
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlWx6yy2nWV8fYcIm9Laap8/KxAlLJd943TIrcldSY archdesktop"
    ];
    packages = [ pkgs.xpra ];
  };
  utils.storageDirs.dirs.music.users = [ "nicotine" ];
  services.backup-root.excludePaths = [ "/home/nicotine" ];
}
