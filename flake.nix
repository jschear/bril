{
  description = "Development environment for bril.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      formatter = forAllSystems ({ pkgs }: pkgs.nixpkgs-fmt);

      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages =
            [
              (pkgs.python311.withPackages (ps: with ps; [
                virtualenv
                pip
              ]))
              pkgs.deno
            ];

          shellHook = ''
            # Install deno tools within .deno/ directory.
            mkdir -p .deno/
            export DENO_INSTALL_ROOT=.deno/
            export PATH="$PATH:$DENO_INSTALL_ROOT/bin"

            deno install brili.ts

            # Create and activate python virtual environment, and install bril-txt tools.
            python -m venv .venv
            source .venv/bin/activate

            cd bril-txt/
            python -m pip install flit
            flit install --symlink .
            cd -
          '';
        };
      });
    };
}
