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
      readOnlyUsers = mkOption {
        description = "List of users that will have read only access to the storage directory";
        type = types.listOf (types.str);
        default = [ ];
      };
    };
  };
  storageDirsCfg = config.utils.storageDirs;
  setfacl = "${pkgs.acl}/bin/setfacl";
  mkFACLScript = isDefault: dirs: concatStringsSep "\n" (lib.attrsets.mapAttrsToList (
    dir: opts:
    let
      path = "${storageDirsCfg.storagePath}/${dir}";
      group = "st_${dir}";
      getROUserFACL = user: "${setfacl} -R ${optionalString isDefault "-d"} -m u:${user}:r-x ${path}";
    in
      ''
        mkdir -p ${path}
        ${setfacl} -R ${optionalString isDefault "-d"} -m g:${group}:rwx ${path}
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
        name = "st_${dir}";
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
            path = "${storageDirsCfg.storagePath}/${dir}";
            group = "st_${dir}";
            getROUserFACL = user: "${setfacl} -R -d -m u:${user}:r-x ${path}";
          in
            ''
              if mkdir ${path} 2>/dev/null ; then
                ${setfacl} -R -d -m g:${group}:rwx ${path}
                ${concatMapStringsSep "\n" getROUserFACL opts.readOnlyUsers}
              fi
            ''
        ) storageDirsCfg.dirs);
      };
    };
  };
}
