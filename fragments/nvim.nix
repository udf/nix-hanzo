{ pkgs, ... }:
{
  environment.variables = { EDITOR = "nvim"; };

  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        customRC = ''
            set tabstop=2
            set shiftwidth=2
            set expandtab
            set number
            set mouse=a
          ;
        '';
      };
    }
    )
  ];
}
