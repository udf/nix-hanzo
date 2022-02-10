# Generates uid/gid for users based on the hash of the user/group name
# only users/groups without a id will have one generated
# 65536 <= id <= 4294967296
{ lib, ... }:
with lib;
with builtins;
let
  userFilter = v: filterAttrs (user: opts: (opts.uid == null)) v;
  groupFilter = v: filterAttrs (group: opts: (opts.gid == null)) v;

  hexChars = listToAttrs (imap0 (i: v: { name = v; value = i; }) (stringToCharacters "0123456789abcdef"));
  hexToInt = s: foldl (a: b: a * 16 + hexChars."${b}") 0 (stringToCharacters s);

  genHash = s: (hexToInt (substring 0 8 (hashString "sha1" s))) * 65535 / 65536 + 65536;
  genId = outAttr: name: opts: opts // { "${outAttr}" = genHash name; };
  genIds = outAttr: sets: mapAttrs (genId outAttr) sets;
in
{
  options.users.users = mkOption {
    apply = v: v // (genIds "uid" (userFilter v));
  };
  options.users.groups = mkOption {
    apply = v: v // (genIds "gid" (groupFilter v));
  };
}
