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
              customRC = ''
                lua << EOF
                vim.opt.number = true
                vim.opt.relativenumber = true
                vim.opt.signcolumn = "yes"
                vim.opt.tabstop = 2
                vim.opt.shiftwidth = 2
                vim.opt.expandtab = true
                vim.api.nvim_set_hl(0, 'TrailingWhitespace', { bg = '#550000' })
                vim.fn.matchadd('TrailingWhitespace', '\\s\\+$')

                vim.lsp.config('nixd', {
                  cmd = { 'nixd' },
                  filetypes = { 'nix' },
                })
                vim.lsp.config('pyright', {
                  cmd = { 'pyright-langserver', '--stdio' },
                  filetypes = { 'python' },
                })
                vim.lsp.config('bashls', {
                  cmd = { 'bash-language-server', 'start' },
                  filetypes = { 'sh', 'bash' },
                })
                vim.lsp.config('lua_ls', {
                  cmd = { 'lua-language-server' },
                  filetypes = { 'lua' },
                })
                vim.lsp.config('dockerls', {
                  cmd = { 'docker-langserver', '--stdio' },
                  filetypes = { 'dockerfile' },
                })
                vim.lsp.config('yamlls', {
                  cmd = { 'yaml-language-server', '--stdio' },
                  filetypes = { 'yaml', 'yml' },
                })
                vim.lsp.config('taplo', {
                  cmd = { 'taplo', 'lsp', 'stdio' },
                  filetypes = { 'toml' },
                })
                vim.lsp.config('terraformls', {
                  cmd = { 'terraform-ls', 'serve' },
                  filetypes = { 'terraform', 'tf' },
                })
                vim.lsp.config('systemd_ls', {
                  cmd = { 'systemd-language-server' },
                  filetypes = { 'systemd' },
                })
                vim.lsp.enable({ 'nixd', 'pyright', 'bashls', 'lua_ls', 'dockerls', 'yamlls', 'taplo', 'terraformls', 'systemd_ls' })
                EOF
              '';
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
          clix-tmux = pkgs.symlinkJoin {
            name = "clix-tmux";
            paths = with pkgs; [ tmux tmuxPlugins.better-mouse-mode fish ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/fish --add-flags "--init-command 'fish_config theme choose Bay\ Cruise'"
              wrapProgram $out/bin/tmux \
                --add-flags "-f ${./config/tmux.conf} -L clix" \
                --set SHELL "$out/bin/fish"
            '';
          };
        in
        {
          packages = {
            inherit tsplit clix-vim clix-bat clix-tmux;
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
