{pkgs}:
pkgs.swift.stdenv.mkDerivation {
  name = "utils";
  dontUnpack = true;
  nativeBuildInputs = [pkgs.swift];
  buildPhase = ''
    mkdir -p $out; cd $out
    swiftc ${./switch-layout.swift} -o switch-layout
    swiftc ${./usb-monitor.swift} -o usb-monitor
  '';
}
