{ pkgs, config, ... }:

{
  imports = [
    # General purpose
    ../../general_purpose/nvim.nix
    ../../general_purpose/zsh.nix

    # development
    ../../development/developing.nix
  ];
}
