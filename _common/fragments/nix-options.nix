{ pkgs, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      keep-outputs = true;
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    # Free up to 4GiB whenever there is less than 1GiB left.
    extraOptions = ''
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      extra-experimental-features = nix-command
    '';

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 4;
  };
}
