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
    bundler.enable = false;
    version = "3.4";
  };
}
