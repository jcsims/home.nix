{
  config,
  pkgs,
  lib,
  system,
  ...
}: {
  home.packages = with pkgs; [];

  home.file.".authinfo.gpg".source = ./files/authinfo.gpg;
}
