# `nix-clab`

`nix-clab` provides a tightly-integrated working environment for [`containerlab`](https://containerlab.srlinux.dev), utilizing [Visual Studio Code](https://code.visualstudio.com) and [NixOS](https://nixos.org). It offers a reproducible, sandboxed workspace that simplifies tooling setup and version management, allowing you to focus on building and managing your network labs.

## Setup

### Requirements

- NixOS host
  - `nix-ld`
  - `nix-direnv`
- VSCode
  - Remote (SSH) extension
  - `direnv` extension

To start using this project, clone the repository:

```bash
git clone https://github.com/etedor/nix-clab.git
```

### `nix-ld` and VSCode

Set up VSCode using the [`nix-ld`](https://nixos.wiki/wiki/Visual_Studio_Code#nix-ld) method by adding the following settings to your NixOS host's `configuration.nix` file:

```nix
  programs.nix-ld.enable = true;
  environment.variables = {
      NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
      ];
      NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };
```

Enable `nix-ld` by running `nixos-rebuild switch`, then install [VSCode Remote (SSH)](https://code.visualstudio.com/docs/remote/ssh) as you normally would from your VSCode client.

### `nix-direnv` and VSCode

`nix-clab` also uses [`nix-direnv`](https://github.com/nix-community/nix-direnv) in conjunction with the [`direnv`](https://direnv.net) VSCode extension to automatically build and manage the working environment.

Include the following settings in your NixOS host's `configuration.nix` file:

```nix
  environment.systemPackages = with pkgs; [ direnv nix-direnv ];
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [ "/share/nix-direnv" ];
```

Enable `nix-direnv` by running `nixos-rebuild switch`.

## Usage

From VSCode's integrated terminal, you'll have access to the following commands:

- `containerlab` or `clab`: Control your lab, with full auto-completion.
- `cli`: Quickly access the CLI of any of your lab containers.
- `dimport`: Automatically import container images into Docker.

### Importing Docker images

The `dimport` script offers a quick way to import Docker images located in your `images` directory. It currently only supports `linux` and `ceos`, but it's designed to be easily extendable to recognize other [kinds](https://containerlab.dev/manual/kinds) supported by containerlab.

### Lab management

If working in VSCode, you'll be in the `topos` working directory upon entering the integrated terminal. Here, you can start [defining your topology](https://containerlab.dev/manual/topo-def-file) and deploy it with:

```bash
clab deploy <your-topology.clab.yml>
```

You can access the CLI of a running node with:

```bash
cli <container-name>
```

For a full list of `containerlab` commands, refer to containerlab's [documentation](https://containerlab.dev/cmd/deploy).

## Contributing

You can help improve this project by reporting issues or submitting pull requests.
