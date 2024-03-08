{ config, lib, pkgs, ... }:

let
  inherit (lib) const mapAttrs' mkEnableOption mkIf mkOption types;

  cfg = config.services.uniborg;

  attrPackageType =
    let
      inherit (types) attrs coercedTo either nullOr package path
        submodule str unspecified;
      pkgType = either package (either path str);
      coercePkg = pkg: { inherit pkg; };
    in
    coercedTo pkgType coercePkg (submodule {
      options = {
        pkg = mkOption {
          description = ''Package to use.'';
          type = pkgType;
        };
        override = mkOption {
          description = ''Overrides to apply.'';
          default = null;
          type = nullOr attrs;
        };
        overrideAttrs = mkOption {
          description = ''Attribute overrides to apply.'';
          default = null;
          type = nullOr unspecified;
        };
      };
    });
  callAttrPackage = pkgs: { pkg, override, overrideAttrs, ... }:
    let
      isPackage = types.package.check pkg;
      isPath = !isPackage && types.path.check pkg;
      isStr = !isPath && types.str.check pkg;
      isOverridden = isPackage || isStr;
      override' = if override == null then { } else override;
      pkg' =
        if isPackage then
          pkg
        else if isPath then
          pkgs.callPackage pkg override'
        else if isStr then
          pkgs.${pkg}
        else throw "unreachable";
      pkg'' = if isOverridden then pkg'.override override' else pkg';
    in
    if overrideAttrs == null then
      pkg''
    else
      pkg''.overrideAttrs overrideAttrs;

  userOptions =
    let
      inherit (types) either listOf nullOr package str;
    in
    { name, config, ... }: {
      options = {
        enable = mkEnableOption "this borg";
        extraPackages = mkOption {
          default = [ ];
          description = ''
            Additional packages to make available to this borg.
          '';
          type = listOf package;
        };
        extraPythonPackages = mkOption {
          default = [ ];
          description = ''
            Additional Python packages to make available to this borg.
          '';
          type = listOf attrPackageType;
        };
        name = mkOption {
          default = name;
          description = ''Name of this borg.'';
          type = str;
        };
        python = mkOption {
          default = pkgs.python311;
          defaultText = "pkgs.python311";
          description = ''Python package to use.'';
          type = package;
        };
        telethon = mkOption {
          default = ../packages/telethon.nix;
          description = ''Telethon package to use.'';
          type = attrPackageType;
        };
        user = mkOption {
          default = config.name;
          description = ''
            User account under which this borg runs. Defaults to this borg's
            name.
          '';
          type = str;
        };
        subdir = mkOption {
          default = "uniborg";
          description = ''
            Subdirectory (of user's home) in which this borg runs. Defaults to "uniborg"
          '';
          type = str;
        };
      };
    };

  borg-service =
    { enable
    , extraPackages
    , extraPythonPackages
    , name
    , python
    , telethon
    , user
    , subdir
    , ...
    }:
    let
      python-pkg = python.withPackages (ps:
        let
          callPackage = callAttrPackage ps; in
        [ (callPackage telethon) (ps.jsonpickle) ] ++ (map callPackage extraPythonPackages));
    in
    {
      name = "uniborg-${name}";
      value = {
        inherit enable;
        description = "${user}'s borg (${name})";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [ python-pkg ] ++ extraPackages;

        serviceConfig = {
          WorkingDirectory = "/home/${user}/${subdir}";
          ExecStart = "${python-pkg}/bin/python stdborg.py";
          Restart = "always";
          User = "${user}";
        };
      };
    };
in
{
  options.services.uniborg = {
    enable = mkEnableOption "uniborg";
    users = mkOption {
      default = { };
      description = "Set of users with uniborg services.";
      type = types.attrsOf (types.submodule userOptions);
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (_: borg-service) cfg.users;
  };
}
