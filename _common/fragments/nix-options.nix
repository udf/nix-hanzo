{ pkgs, ... }:

{
  nix = {
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      extra-experimental-features = nix-command
    '';

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 4;
  };
}
