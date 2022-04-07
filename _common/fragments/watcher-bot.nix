{ ... }:
{
  imports = [
    ../modules/watcher-bot.nix
  ];

  services.watcher-bot.enable = true;
}