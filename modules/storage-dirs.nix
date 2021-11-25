{ config, lib, pkgs, ... }:
with lib;
let
  dirCfgOpts = {name, ...}: {
    options = {
      users = mkOption {
        description = "List of users that will be part of this storage group";
        type = types.listOf (types.str);
        default = [ ];
      };
      group = mkOption {
        description = "The group name that will be allowed to access the folder";
        type = types.str;
        default = "st_${name}";
      };
      gid = mkOption {
        description = "The group ID for the generated group";
        type = types.nullOr types.int;
        default = null;
      };
      readOnlyUsers = mkOption {
        description = "List of users that will have read only access to the storage directory";
        type = types.listOf (types.str);
        default = [ ];
      };
      path = mkOption {
        description = "Full path of the storage directory";
        type = types.str;
        default = "${storageDirsCfg.storagePath}/${name}";
      };
    };
  };
  storageDirsCfg = config.utils.storageDirs;
  setfacl = "${pkgs.acl}/bin/setfacl";
  mkFACLScript = isDefault: dirs: concatStringsSep "\n" (lib.attrsets.mapAttrsToList (
    dir: opts:
    let
      getROUserFACL = user: "${setfacl} -R ${optionalString isDefault "-d"} -m u:${user}:r-x ${opts.path}";
    in
      ''
        mkdir -p ${opts.path}
        ${setfacl} -R ${optionalString isDefault "-d"} -m g:${opts.group}:rwx ${opts.path}
        ${concatMapStringsSep "\n" getROUserFACL opts.readOnlyUsers}
      ''
  ) dirs);
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
    environment.systemPackages = [
      (pkgs.writeScriptBin "storage-dirs-set-acl" (mkFACLScript false storageDirsCfg.dirs))
      (pkgs.writeScriptBin "storage-dirs-set-acl-default" (mkFACLScript true storageDirsCfg.dirs))
    ];

    users.groups = attrsets.mapAttrs' (
      dir: opts: {
        name = opts.group;
        value = {
          members = storageDirsCfg.adminUsers ++ opts.users;
          gid = opts.gid;
        };
      }) storageDirsCfg.dirs;

    system.activationScripts = {
      storageDirCreator = {
        deps = [ "specialfs" ];
        text = concatStringsSep "\n" (lib.attrsets.mapAttrsToList (
          dir: opts:
          let
            getROUserFACL = user: "${setfacl} -R -d -m u:${user}:r-x ${opts.path}";
          in
            ''
              if mkdir ${opts.path} 2>/dev/null ; then
                ${setfacl} -R -d -m g:${opts.group}:rwx ${opts.path}
                ${concatMapStringsSep "\n" getROUserFACL opts.readOnlyUsers}
              fi
            ''
        ) storageDirsCfg.dirs);
      };
    };
  };
}
