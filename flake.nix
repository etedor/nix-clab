{
  description = "A containerlab environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        containerlabSrc = pkgs.fetchFromGitHub {
          owner = "srl-labs";
          repo = "containerlab";
          rev = "v0.42.0";
          sha256 = "sha256-Vs3+5lnHy1QOisyq8heHlkE+Ezd6jDTFiTZUPxNQDnA=";
        };

        cli = pkgs.writeShellScriptBin "cli" (builtins.readFile ./.bin/cli.sh);
        dimport = pkgs.writeShellScriptBin "dimport" (builtins.readFile ./.bin/dimport.sh);

        wrapCommand = name: containerlab:
          let
            script = builtins.replaceStrings
              [ "%%CONTAINERLAB_PATH%%" ]
              [ "${containerlab}" ]
              (builtins.readFile ./.bin/wrap-command.sh);
          in
            pkgs.writeShellScriptBin name script;

        devEnvironment = pkgs.buildEnv {
          name = "clab";
          paths = [
            cli
            dimport
            (wrapCommand "containerlab" pkgs.containerlab)
            (wrapCommand "clab" pkgs.containerlab)
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [ devEnvironment ];
          shellHook = ''
            # Set environment variables
            export PROJECT_ROOT=`pwd`

            # Prepare workarounds for hardcoded containerlab paths
            mkdir -p $PROJECT_ROOT/.etc
            touch $PROJECT_ROOT/.etc/hosts
            mkdir -p $PROJECT_ROOT/.templates

            # Copy containerlab templates to project dir
            cp -r ${containerlabSrc}/templates/* $PROJECT_ROOT/.templates
          '';
        };
      in
      {
        devShell = devShell;
        defaultPackage = devEnvironment;
      }
    );
}
