# gsd-flake

A Nix flake for [GSD (get-shit-done-cc)](https://github.com/gsd-build/get-shit-done) v1.39.0 — a meta-prompting and context-engineering framework for Claude Code, OpenCode, Gemini, Cursor, and other AI coding agents.

## What you get

Three CLI binaries:

- `get-shit-done-cc` — the main installer (also exposed as `nix run .`)
- `gsd-sdk` — programmatic interface to run GSD plans via the Agent SDK
- `gsd-tools` — alias of `gsd-sdk`

## Quick start

Run without installing:

```bash
nix run github:neosam/gsd-flake -- --help
```

Install into a profile:

```bash
nix profile install github:neosam/gsd-flake
```

Use the SDK directly:

```bash
nix run github:neosam/gsd-flake#gsd-sdk -- run "your prompt here"
```

## Use as a flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gsd.url = "github:neosam/gsd-flake";
    gsd.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, gsd, ... }: {
    # NixOS:
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [ gsd.packages.x86_64-linux.default ];
      }];
    };

    # Home-Manager:
    # home.packages = [ gsd.packages.${pkgs.system}.default ];
  };
}
```

## Build strategy

GSD is published as an npm package whose `prepublishOnly` script runs `build:sdk`, which in turn calls `npm install` inside the `sdk/` subdirectory. That step is impossible inside the network-isolated Nix sandbox.

This flake works around that by combining two sources:

1. **GitHub source** at tag `v1.39.0` — provides the root `package-lock.json` so `buildNpmPackage` can install the runtime dependencies (`@anthropic-ai/claude-agent-sdk`, `ws`).
2. **Pre-built npm tarball** from the registry — the `sdk/dist/` directory it contains was already compiled by the publisher's `prepublishOnly` step. We extract just that directory in `postPatch` and skip running `build:sdk` ourselves.

Only the local `build:hooks` script runs during the build (it's a pure Node script that copies hook files).

## Updating to a new version

Three hashes are pinned in `package.nix`:

- `src.hash` — GitHub source tarball
- `npmDepsHash` — root `node_modules` derivation
- `prebuiltTarball.hash` — npm registry tarball

When bumping `version`, replace each with `lib.fakeHash` and run `nix build` repeatedly; Nix will print the correct hash on each mismatch. Patch them in one at a time.

## Files

- `flake.nix` — flake inputs (`nixpkgs`, `flake-utils`) and outputs (`packages`, `apps`)
- `package.nix` — the `buildNpmPackage` derivation
- `flake.lock` — pinned input revisions

## License

This flake is licensed under the [MIT License](LICENSE). GSD itself is MIT-licensed by TÂCHES (see [upstream](https://github.com/gsd-build/get-shit-done)).
