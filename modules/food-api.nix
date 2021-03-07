{config, lib, pkgs, ...}:
with lib;
let
  # Helper script to clone/checkout master and run
  # Ideally, the git clone would be done declaritively from this .nix file
  # but since we want to always run the latest master branch instead of a fixed version
  # we need to do the clone outside of the nixos build environment
  runScript = pkgs.writeShellScript "fetchAndRun" ''
    set -e

    REPO_SRC=git@github.com:udf/food-info-api.git
    REPO_DST=food-info-api

    GIT=${pkgs.git}/bin/git

    if [ ! -d "$REPO_DST" ]
    then
      $GIT clone $REPO_SRC $REPO_DST
      cd $REPO_DST
    else
      cd $REPO_DST
      $GIT fetch --all
      $GIT reset --hard origin/master
    fi

    ${pkgs.dotnetCorePackages.sdk_3_1}/dotnet run -c Release
  '';

  cfg = config.services.foodAPI;

  defaultLocationOpts = {
    proxyPass = "https://127.0.0.1:5001";
    extraConfig = ''
      rewrite /${cfg.webPath}/(.*) /$1 break;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Prefix ${cfg.webPath};
      ${cfg.extraConfig}
    '';
  };
in
{
  options.services.foodAPI = {
    enable = lib.mkEnableOption "Enable Food API service";
    webHostDomain = mkOption {
      description = "The virtualHost (domain) for the NginX configuration";
      type = types.str;
    };
    webPath = mkOption {
      default = "food";
      description = "The path in webHostName where the API will be available (without leading or trailing slash)";
      type = types.str;
    };
    adminAuthFile = mkOption {
      default = "/var/www/food/.htpasswd";
      description = "The htpasswd file used for authenticating /admin/ routes";
      type = types.str;
    };
    extraConfig = mkOption {
      default = "";
      description = "Extra config options for the location sections";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
   systemd.services.foodAPI = {
     description = "Food API";
     after = ["network.target"];
     wantedBy = ["multi-user.target"];

     serviceConfig = {
       Type = "simple";
       WorkingDirectory = "/home/foodAPI";
       ExecStart = runScript;
       Restart = "always";
       RestartSec = 3;
       User = "foodAPI";
     };
   };

    users.extraUsers.foodAPI = {
      description = "foodAPI";
      home = "/home/foodAPI";
      createHome = true;
      useDefaultShell = true;
    };

    services.nginx = {
      virtualHosts."${cfg.webHostDomain}" = {
        locations."/${cfg.webPath}/" = defaultLocationOpts;

        locations."/${cfg.webPath}/admin/" = defaultLocationOpts // {
          extraConfig = defaultLocationOpts.extraConfig + ''
            auth_basic "What are you doing in my swamp?!";
            auth_basic_user_file ${cfg.adminAuthFile};
          '';
        };
      };
    };
  };
}
