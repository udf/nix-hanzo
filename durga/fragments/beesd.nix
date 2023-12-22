{ config, lib, pkgs, ... }:

{
  services.beesd.filesystems.root = {
    spec = "UUID=098aab8a-579b-4376-b268-fba317eab5d1";
    hashTableSizeMB = 1024;
    verbosity = "crit";
  };
}
