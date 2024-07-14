{
  description = "EctoBootMigration";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = import nixpkgs { inherit system; };

        beamPkg = pkgs.beam.packagesWith pkgs.erlang_26;

        elixir = beamPkg.elixir.override {
          version = "1.15.8";
          sha256 = "rjUt3gCUszCbzGE7BriwH3ptrV81dqNB/d0nVOXrcGI=";
        };
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            elixir
            elixir_ls
            glibcLocales
          ] ++ optional stdenv.isLinux inotify-tools
          ++ optional stdenv.isDarwin terminal-notifier
          ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
            CoreFoundation
            CoreServices
          ]);
          shellHook = ''
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
          '';
        };
      });
}
