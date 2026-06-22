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
