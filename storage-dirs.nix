{ config, lib, pkgs, ... }:
with lib;
let
  dirCfgOpts = {...}: {
    options = {
      users = mkOption {
        description = "List of users that will be part of this storage group";
        type = types.listOf (types.str);
        default = [ ];
      };
      gid = mkOption {
        description = "The group ID for the generated group";
        type = types.nullOr types.int;
        default = null;
      };
    };
  };
  storageDirsCfg = config.utils.storageDirs;
in
{
  options.utils.storageDirs = {
    storagePath = mkOption {
      description = "Base storage directory (without trailing slash)";
      type = types.str;
    };
    adminUsers = mkOption {
      description = "List of users that will be part of every storage group";
      type = types.listOf (types.str);
    };
    dirs = mkOption {
      description = "Set of directories to create";
      type = types.attrsOf (types.submodule dirCfgOpts);
    };
  };

  config = {
    users.groups = attrsets.mapAttrs' (
      dir: opts: {
        name = "st_${dir}";
        value = {
          members = storageDirsCfg.adminUsers ++ opts.users;
          gid = opts.gid;
        };
      }) storageDirsCfg.dirs;

    system.activationScripts = {
      storageDirCreator = {
        deps = [ "specialfs" ];
        text = let
          buildLine = (dir: opts:
            let
              path = "${storageDirsCfg.storagePath}/${dir}";
              group = "st_${dir}";
            in
              "mkdir -p ${path} && chgrp ${group} ${path}"
          );
        in
          concatStringsSep "\n" (lib.attrsets.mapAttrsToList buildLine storageDirsCfg.dirs);
      };
    };
  };
}
