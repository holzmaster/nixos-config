{ config, pkgs, ... }:

{
  imports = [
    # ui
    ../../ui/x11/x11.nix

    # General purpose
    ../../general_purpose/nvim.nix
    ../../general_purpose/zsh.nix
    ../../general_purpose/misc.nix

    # User applications
    ../../applications/alacritty.nix
    ../../applications/user_apps.nix

    # development
    ../../development/developing.nix
  ];
}
