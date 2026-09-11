{
  description = "A portable configured shell environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      systems,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = (import systems) ++ [ "riscv64-linux" ];

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tsplit = pkgs.writeShellScriptBin "tsplit" ''
            if [ -z "''${TMUX:-}" ]; then
              echo "tsplit: not inside a tmux session" >&2
              exit 1
            fi
            if [ -n "$1" ]; then
              name="$1"
            else
              name="$(basename "$PWD")"
            fi
            tmux rename-window "$name" \; split-window -h \; split-window -v \; send-keys -t 2 'fastfetch' C-m \; resize-pane -t 2 -y 31
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
          clix-vim-light = pkgs.symlinkJoin {
            name = "clix-vim-light";
            paths = [ clix-neovim ];
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
                exec ${pkgs.fish}/bin/fish --init-command "source ${./config}/fish.fish" "$@"
              '')
              pkgs.fish
              pkgs.fishPlugins.tide
              pkgs.fishPlugins.z
            ];
            passthru.shellPath = "/bin/fish";
          };
          clix-git = pkgs.symlinkJoin {
            name = "clix-git";
            paths = [
              (pkgs.writeShellScriptBin "git" ''
                exec ${pkgs.git}/bin/git -c include.path=${./config/gitconfig} "$@"
              '')
              pkgs.git
              pkgs.delta
            ];
          };
          tmux-plugins = with pkgs.tmuxPlugins; [
            better-mouse-mode
            yank
          ];
          sysbar = pkgs.writeShellScript "sysbar" (builtins.readFile ./config/sysbar.sh);
          clix-tmux-conf = pkgs.writeText "tmux.conf" ''
            ${builtins.readFile ./config/tmux.conf}
            set -g status-right "#(${sysbar}) | %H:%M"
            set -g status-interval 2
            ${pkgs.lib.concatMapStrings (p: "run-shell ${p.rtp}\n") tmux-plugins}
          '';
          clix-tmux = pkgs.symlinkJoin {
            name = "clix-tmux";
            paths = [ pkgs.tmux ] ++ tmux-plugins ++ [ clix-fish ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/tmux \
                --add-flags "-f ${clix-tmux-conf} -L clix" \
                --set SHELL "${clix-fish}/bin/fish" \
            '';
          };
        in
        {
          apps.default = {
            type = "app";
            program = "${clix-fish}/bin/fish";
          };
          apps.light = {
            type = "app";
            program = "${clix-fish}/bin/fish";
          };
          packages =
            let
              commonPaths = with pkgs; [
                broot
                eza
                ripgrep
                fd
                pstree
                tsplit
                clix-bat
                clix-git
                clix-tmux
              ];
            in
            {
              inherit
                tsplit
                clix-vim
                clix-vim-light
                clix-bat
                clix-fish
                clix-git
                clix-tmux
                ;
              default = pkgs.symlinkJoin {
                name = "clix";
                buildInputs = [ pkgs.makeWrapper ];
                paths = commonPaths ++ [ clix-vim ];
                postBuild = "";
                passthru.shellPath = clix-fish.shellPath;
              };
              light = pkgs.symlinkJoin {
                name = "clix-light";
                buildInputs = [ pkgs.makeWrapper ];
                paths = commonPaths ++ [ clix-vim-light ];
                postBuild = "";
                passthru.shellPath = clix-fish.shellPath;
              };
            };
        };
    };
}
