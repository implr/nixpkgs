{
  lib,
  stdenvNoCC,
  fetchurl,
  nixosTests,
  nextcloud29Packages,
  nextcloud30Packages,
  nextcloud31Packages,
}:

let
  generic =
    {
      version,
      hash,
      eol ? false,
      extraVulnerabilities ? [ ],
      packages,
    }:
    stdenvNoCC.mkDerivation rec {
      pname = "nextcloud";
      inherit version;

      src = fetchurl {
        url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
        inherit hash;
      };

      passthru = {
        tests = lib.filterAttrs (
          key: _: (lib.hasSuffix (lib.versions.major version) key)
        ) nixosTests.nextcloud;
        inherit packages;
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/
        cp -R . $out/
        runHook postInstall
      '';

      meta = {
        changelog = "https://nextcloud.com/changelog/#${lib.replaceStrings [ "." ] [ "-" ] version}";
        description = "Sharing solution for files, calendars, contacts and more";
        homepage = "https://nextcloud.com";
        maintainers = lib.teams.nextcloud.members;
        license = lib.licenses.agpl3Plus;
        platforms = lib.platforms.linux;
        knownVulnerabilities =
          extraVulnerabilities ++ (lib.optional eol "Nextcloud version ${version} is EOL");
      };
    };
in
{
  nextcloud29 = generic {
    version = "29.0.15";
    hash = "sha256-iqvCDILYxxJk7oxAmXaaBbwzUWKAAd5aNHAswRKBfMA=";
    packages = nextcloud29Packages;
  };

  nextcloud30 = generic {
    version = "30.0.9";
    hash = "sha256-gkWL1whsCCqHrR8UldkjuJ4jMRCajZXosA5jm70OHxY=";
    packages = nextcloud30Packages;
  };

  nextcloud31 = generic {
    version = "31.0.3";
    hash = "sha256-koOuvY/aWtc5zaVvfKuqg1zDv5j3lTbDbczXMJ4rMFo=";
    packages = nextcloud31Packages;
  };

  # tip: get the sha with:
  # curl 'https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2.sha256'
}
