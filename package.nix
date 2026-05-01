{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  nodejs_22,
}:

let
  # The published npm tarball contains a pre-built sdk/dist/ produced by
  # `npm run build:sdk` during `prepublishOnly`. Re-running build:sdk inside
  # the Nix sandbox is not feasible because it executes `npm install` inside
  # sdk/, which has its own package-lock.json and would require network access.
  # Instead, we extract the already-compiled sdk/dist/ from the npm tarball.
  prebuiltTarball = fetchurl {
    url = "https://registry.npmjs.org/get-shit-done-cc/-/get-shit-done-cc-1.39.0.tgz";
    hash = "sha256-pNyj1ZaziAqTS2RZVHV26jbLj8rOuFnHFM1mIZyt8Lg=";
  };
in
buildNpmPackage rec {
  pname = "get-shit-done-cc";
  version = "1.39.0";

  src = fetchFromGitHub {
    owner = "gsd-build";
    repo = "get-shit-done";
    rev = "v${version}";
    hash = "sha256-DnGz/MecFy6FK4yQBCPeFmA8NgzZVrHHZPmRnU9Kyn8=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-Z7RpGJPm5w+Hx6b7YFJZXZPS3X0itRhd+k83RajLVxc=";

  postPatch = ''
    mkdir -p _prebuilt
    tar -xzf ${prebuiltTarball} -C _prebuilt --strip-components=1
    mkdir -p sdk/dist
    cp -r _prebuilt/sdk/dist/. sdk/dist/
    rm -rf _prebuilt
  '';

  # Run only the local build:hooks step. The full prepublishOnly script also
  # runs build:sdk, which would require network access (npm install in sdk/);
  # we instead bring in the pre-built sdk/dist/ via postPatch above.
  npmBuildScript = "build:hooks";

  dontNpmCheck = true;

  meta = {
    description = "Meta-prompting and context engineering framework for Claude Code";
    homepage = "https://github.com/gsd-build/get-shit-done";
    license = lib.licenses.mit;
    mainProgram = "get-shit-done-cc";
    platforms = lib.platforms.unix;
  };
}
