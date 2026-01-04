{ pkgs, ... }:

{
  packages = with pkgs; [
    libyaml
    openssl
    libffi
    pkg-config
    autoconf
    automake
    libtool
    gcc
    makeWrapper
  ];

  languages.ruby = {
    enable = true;
    bundler.enable = true;
    version = "4.0";
  };
}
