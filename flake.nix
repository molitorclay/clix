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
          lsp-servers = with pkgs; [
            nixd
            nixfmt
            nixfmt-tree
            pyright
            bash-language-server
            lua-language-server
            dockerfile-language-server
            yaml-language-server
            taplo
            terraform-ls
            systemd-language-server
          ];
          clix-neovim = pkgs.neovim.override {
            configure = {
              customRC = "luafile ${./config/vim.lua}";
            };
          };
          clix-vim = pkgs.symlinkJoin {
            name = "clix-vim";
            paths = [ clix-neovim ] ++ lsp-servers;
          };
          clix-bat = pkgs.symlinkJoin {
            name = "clix-bat";
            paths = [ pkgs.bat ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/bat --add-flags "--theme 1337 --style plain --paging never"
            '';
          };
          clix-fish = pkgs.symlinkJoin {
            name = "clix-fish";
            paths = [
              (pkgs.writeShellScriptBin "fish" ''
                exec ${pkgs.fish}/bin/fish --init-command "source ${./config/fish.fish}" "$@"
              '')
              pkgs.fish
              pkgs.fishPlugins.tide
            ];
            passthru.shellPath = "/bin/fish";
          };
          clix-tmux = pkgs.symlinkJoin {
            name = "clix-tmux";
            paths = with pkgs; [ tmux tmuxPlugins.better-mouse-mode ] ++ [ clix-fish ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/tmux \
                --add-flags "-f ${./config/tmux.conf} -L clix" \
                --set SHELL "${clix-fish}/bin/fish"
            '';
          };
        in
        {
          packages = {
            inherit tsplit clix-vim clix-bat clix-fish clix-tmux;
            default = (
              pkgs.symlinkJoin {
                name = "clix";
                buildInputs = [ pkgs.makeWrapper ];
                paths =
                  with pkgs;
                  [
                    nushell
                    broot
                    tree
                    pstree
                    tsplit
                  ]
                  ++ [ clix-vim clix-bat clix-tmux ];
                postBuild = ''
                '';
              }
            );
          };
        };
    };
}
