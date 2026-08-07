{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  pymodbus,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "0.3.1";
  domain = "fronius_modbus";
  owner = "callifo";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = finalAttrs.domain;
    tag = "${finalAttrs.version}";
    hash = "sha256-1JkFOO/fWw/ehglQH3lzK0cDgSU+5IUsi+Rk8ZQhOhs=";
  };

  dependencies = [
    pymodbus
  ];

  meta = {
    changelog = "https://github.com/callifo/fronius_modbus/releases/tag/v${finalAttrs.version}";
    description = "Home Assistant component for reading data from Fronius inverters, connected smart meters and battery storage through modbus TCP";
    homepage = "https://github.com/callifo/fronius_modbus";
    maintainers = with lib.maintainers; [ implr ];
    license = lib.licenses.asl20;
  };
})
