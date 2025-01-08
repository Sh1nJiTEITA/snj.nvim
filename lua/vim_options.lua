vim.opt.relativenumber = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.markdown_fenced_languages = {
   "ts=typescript",
}
-- Number at current line
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
-- vim.opt.mouse = ""
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = false
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.hlsearch = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.conceallevel = 1

vim.filetype.add({
   extension = {
      vert = "glsl",
      frag = "glsl",
      geom = "glsl",
   },
})

return
