{
  description = "Get Shit Done (GSD) — Meta-prompting framework for Claude Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gsd = pkgs.callPackage ./package.nix { };
      in
      {
        packages.default = gsd;
        packages.gsd = gsd;

        apps.default = {
          type = "app";
          program = "${gsd}/bin/get-shit-done-cc";
        };
        apps.gsd-sdk = {
          type = "app";
          program = "${gsd}/bin/gsd-sdk";
        };
        apps.gsd-tools = {
          type = "app";
          program = "${gsd}/bin/gsd-tools";
        };
      }
    );
}
