{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, fetchNpmDeps
, cacert
, git
, go
, enumer
, mockgen
, nodejs
, npmHooks
, nix-update-script
, nixosTests
}:

buildGoModule rec {
  pname = "evcc";
  version = "0.131.5";

  src = fetchFromGitHub {
    owner = "evcc-io";
    repo = "evcc";
    rev = version;
    hash = "sha256-CRqxxbPkcjswntMgGkIrPFEbnjI90sfTmG6D1eCo45w=";
  };

  vendorHash = "sha256-x0EWFsR/O2Ztg39DL+yZx2ZDzJHADo2aPAeg/i+5KqM=";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-4PBlN2pbr7dzZNQzh/P0kBlsg6ut2XPwsfFB132hWO0=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  overrideModAttrs = _: {
    nativeBuildInputs = [
      enumer
      go
      git
      cacert
      mockgen
    ];

    preBuild = ''
      make assets
    '';
  };

  tags = [
    "release"
    "test"
  ];

  ldflags = [
    "-X github.com/evcc-io/evcc/server.Version=${version}"
    "-X github.com/evcc-io/evcc/server.Commit=${src.rev}"
    "-s"
    "-w"
  ];

  preBuild = ''
    make ui
  '';

  doCheck = !stdenv.hostPlatform.isDarwin; # darwin sandbox limitations around network access, access to /etc/protocols and likely more

  checkFlags = let
    skippedTests = [
      # network access
      "TestOctopusConfigParse"
      "TestTemplates"
      "TestOcpp"
    ];
  in
  [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];

  passthru = {
    tests = {
      inherit (nixosTests) evcc;
    };
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "EV Charge Controller";
    homepage = "https://evcc.io";
    changelog = "https://github.com/evcc-io/evcc/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
