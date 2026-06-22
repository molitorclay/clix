{
  description = "A portable configured shell environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tsplit = pkgs.writeShellScriptBin "tsplit" ''
            if [ -z "''${TMUX:-}" ]; then
              echo "tsplit: not inside a tmux session" >&2
              exit 1
            fi
            tmux split-window -h \; split-window -v \; send-keys -t 2 'nix run nixpkgs#fastfetch -- --logo NixOS --logo-color-1 "#FF0018" --logo-color-2 "#FF8C00" --logo-color-3 "#FFFF41" --logo-color-4 "#008018" --logo-color-5 "#0000F9" --logo-color-6 "#86007D"' C-m \; resize-pane -t 2 -y 31
          '';
        in
        {
          packages = {
            default = (
              pkgs.symlinkJoin {
                name = "clix";
                buildInputs = [ pkgs.makeWrapper ];
                paths = with pkgs; [
                  fish
                  nushell
                  tmux
                  tmuxPlugins.better-mouse-mode
                  bat
                  broot
                  tree
                  pstree
                  tsplit
                ];
                postBuild = ''
                  wrapProgram $out/bin/fish --add-flags "--init-command 'fish_config theme choose Bay\ Cruise'"
                  wrapProgram $out/bin/bat --add-flags "--theme 1337 --style header"
                  wrapProgram $out/bin/tmux \
                    --add-flags "-f ${./config/tmux.conf} -L clix" \
                    --set SHELL "$out/bin/fish"
                '';
              }
            );
          };
        };
    };
}
