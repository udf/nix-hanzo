{ config, lib, pkgs, ... }:
let
  userId = toString config.users.users.nicotine.uid;
  XDisplay = "100";
  nicotinePkg = pkgs.nicotine-plus.overrideAttrs (oldAttrs: rec {
    version = "3.2.9";
    src = pkgs.fetchFromGitHub {
      owner = "nicotine-plus";
      repo = "nicotine-plus";
      rev = "refs/tags/${version}";
      sha256 = "sha256-PxtHsBbrzcIAcLyQKD9DV8yqf3ljzGS7gT/ZRfJ8qL4=";
    };

    postInstall = ''
      ln -s $out/bin/nicotine $out/bin/nicotine-plus
    '';
  });
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
          --pulseaudio=no \
          --html=off \
          --printing=no \
          --env="XDG_DATA_DIRS=${pkgs.gnome.adwaita-icon-theme}/share" \
          --env="XCURSOR_PATH=/home/nicotine/.icons:${pkgs.gnome.adwaita-icon-theme}/share/icons" \
          --env="GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
          --start-child="${nicotinePkg}/bin/nicotine-plus" \
          --exit-with-children=yes \
          :${XDisplay}
      '';
      UMask = "0002";
    };
  };

  fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk ];

  networking.firewall.allowedTCPPorts = [ 2234 ];

  users.users.nicotine = {
    isNormalUser = true;
    createHome = true;
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
    packages = [ pkgs.xpra ];
    group = "cl_music";
  };
}
