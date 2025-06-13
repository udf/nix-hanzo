{ config, lib, pkgs, ... }:
let
  userId = toString config.users.users.nicotine.uid;
  XDisplay = "100";
  nicotinePkg = (pkgs.callPackage ../../_common/packages/nicotine-plus-gtk3.nix { });
in
{
  # TODO: move this to a generic module if more gui users are needed
  systemd.services.xpra-nicotine = {
    description = "Xpra for nicotine";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      XDG_RUNTIME_DIR = "/run/user/${userId}";
      GTK_A11Y = "none";
    };

    unitConfig = {
      RequiresMountsFor = "/backup/music /backup/soulseek-downloads";
    };

    serviceConfig = {
      User = "nicotine";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      RestartMode = "direct";
      WorkingDirectory = "/home/nicotine";
      ExecStartPre = [
        "${pkgs.xpra}/bin/xpra list"
        "${pkgs.coreutils}/bin/rm -fr /run/user/${userId}/xpra/100"
      ];
      ExecStart = ''
        ${pkgs.xpra}/bin/xpra start \
          --daemon=off \
          --opengl=on \
          --clipboard=on \
          --notifications=on \
          --speaker=off \
          --mdns=no \
          --webcam=no \
          --audio=no \
          --html=off \
          --printing=no \
          --env="XDG_DATA_DIRS=${pkgs.adwaita-icon-theme}/share" \
          --env="XCURSOR_PATH=/home/nicotine/.icons:${pkgs.adwaita-icon-theme}/share/icons" \
          --env="GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
          --start-child="${nicotinePkg}/bin/nicotine --ci-mode" \
          --exit-with-children=yes \
          :${XDisplay}
      '';
      UMask = "0002";
    };
  };

  environment.etc."nicotine/plugins".source = "${../../_common/helpers/nicotine-plugins}";

  fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans ];

  programs.dconf.enable = true;

  networking.firewall.allowedTCPPorts = [ 2234 ];
  custom.ipset-block.exceptPorts = [ 2234 ];

  users.groups.nicotine = { };
  users.users.nicotine = {
    isNormalUser = true;
    createHome = true;
    linger = true;
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
    packages = [ pkgs.xpra ];
    group = "nicotine";
  };
}
