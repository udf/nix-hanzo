{
  lib,
  fetchFromGitHub,
  wrapGAppsHook,
  gdk-pixbuf,
  gettext,
  gobject-introspection,
  gtk3,
  glib,
  python3Packages,
}:
let
  pname = "nicotine-plus";
  version = "3.3.10";
  unstablePkgs = import <nixpkgs-unstable> { };
in
assert unstablePkgs.nicotine-plus.version == version;
python3Packages.buildPythonApplication {
  inherit pname version;
  pyproject = true;
  src = fetchFromGitHub {
    owner = "nicotine-plus";
    repo = "nicotine-plus";
    tag = version;
    hash = "sha256-ic/+Us56UewMjD8vgmxxCisoId96Qtaq8/Ll+CCFR3Y=";
  };

  patches = [ ./nicotine-plus-3.3.10-userbrowse-fix.patch ];

  nativeBuildInputs = [
    gettext
    wrapGAppsHook
    gobject-introspection
    glib
    gdk-pixbuf
    gtk3
  ];

  dependencies = [
    python3Packages.pygobject3
  ];

  build-system = [
    python3Packages.setuptools
  ];

  postInstall = ''
    ln -s $out/bin/nicotine $out/bin/nicotine-plus
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    )
  '';

  doCheck = false;
  meta = with lib; {
    description = "Graphical client for the SoulSeek peer-to-peer system";
    longDescription = ''
      Nicotine+ aims to be a pleasant, free and open source (FOSS) alternative
      to the official Soulseek client, providing additional functionality while
      keeping current with the Soulseek protocol.
    '';
    homepage = "https://www.nicotine-plus.org";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      klntsky
      amadaluzia
    ];
  };
}
