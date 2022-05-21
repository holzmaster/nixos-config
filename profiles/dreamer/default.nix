{ config, pkgs, ... }:

{
  imports = [
    # User applications
    ../../applications/alacritty.nix
    ../../applications/user_apps.nix

    # ui
    ../../ui/x11/x11.nix

    # General purpose
    ../../general_purpose/nvim.nix
    ../../general_purpose/zsh.nix

    # development
    ../../development/developing.nix
  ];
}
