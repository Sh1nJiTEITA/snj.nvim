require("vim_options")
local keymaps_module = require("keymaps")
require("autocmd")

require("lazy").setup({
   {
      "nvim-tree/nvim-tree.lua",
      opts = {},
   },
   {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },

      event = "VimEnter",
      config = function()
         keymaps_module.init_harpoon_keymaps()
      end,
   },

   { "xiyaowong/transparent.nvim" },

   { "tpope/vim-sleuth" },

   {
      "numToStr/Comment.nvim",
      opts = {
         toggler = {
            line = "gcc",
            block = "gbc",
         },
      },
   },

   {
      "lewis6991/gitsigns.nvim",
      opts = {
         signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
         },
      },
   },

   {
      "folke/which-key.nvim",
      event = "VimEnter",
      config = function()
         require("which-key").setup()
         require("which-key").add(keymaps_module.init_whichkey_keymaps())
      end,
   },

   {
      "nvim-telescope/telescope.nvim",
      event = "VimEnter",
      branch = "0.1.x",
      dependencies = {
         "nvim-lua/plenary.nvim",
         {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
               return vim.fn.executable("make") == 1
            end,
         },
         { "nvim-telescope/telescope-ui-select.nvim" },
         { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      },
      config = function()
         require("telescope").setup({
            extensions = {
               ["ui-select"] = {
                  require("telescope.themes").get_dropdown(),
               },
            },
         })

         -- Enable Telescope extensions if they are installed
         pcall(require("telescope").load_extension, "fzf")
         pcall(require("telescope").load_extension, "ui-select")

         keymaps_module.init_telescope_keymaps(require("telescope.builtin"))
      end,
   },

   { -- LSP Configuration & Plugins
      "neovim/nvim-lspconfig",
      dependencies = {
         -- Automatically install LSPs and related tools to stdpath for Neovim
         { "williamboman/mason.nvim", config = true },
         { "williamboman/mason-lspconfig.nvim" },
         { "WhoIsSethDaniel/mason-tool-installer.nvim" },
         { "j-hui/fidget.nvim", opts = {} },
         { "folke/neodev.nvim", opts = {} },
      },
      config = function()
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
               local client = vim.lsp.get_client_by_id(event.data.client_id)

               keymaps_module.init_lspconfig_keymaps(event, client)

               -- When you move your cursor, the highlights will be cleared (the second autocommand).
               if client and client.server_capabilities.documentHighlightProvider then
                  local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                     buffer = event.buf,
                     group = highlight_augroup,
                     callback = vim.lsp.buf.document_highlight,
                  })

                  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                     buffer = event.buf,
                     group = highlight_augroup,
                     callback = vim.lsp.buf.clear_references,
                  })
                  vim.api.nvim_create_autocmd("LspDetach", {
                     group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                     callback = function(event)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
                     end,
                  })
               end
            end,
         })

         local capabilities = vim.lsp.protocol.make_client_capabilities()
         capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

         local servers = {
            clangd = {
               cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
            },

            glsl_analyzer = {
               filetypes = { "vert", "frag", "glsl", "geom" },
            },

            cmakelang = {},
            cmake = {},
            pyright = {},
            lua_ls = {
               settings = {
                  Lua = {
                     completion = {
                        callSnippet = "Replace",
                     },
                  },
               },
            },
         }

         require("mason").setup()
         local ensure_installed = vim.tbl_keys(servers or {})
         vim.list_extend(ensure_installed, {
            "stylua", -- Used to format Lua code
         })
         require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

         require("mason-lspconfig").setup({
            handlers = {
               function(server_name)
                  local server = servers[server_name] or {}
                  server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                  require("lspconfig")[server_name].setup(server)
               end,
            },
         })
      end,
   },

   {
      "stevearc/conform.nvim",
      lazy = false,
      keys = {
         {
            "<leader>f",
            function()
               require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "[F]ormat buffer",
         },
      },
      opts = {
         notify_on_error = false,
         format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            return {
               timeout_ms = 500,
               lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            }
         end,
         formatters_by_ft = {
            lua = { "stylua" },
            cpp = { "clang_format" },
            c = { "clang_format" },
            python = { "isort", "black" },
         },
      },
   },

   {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
         {
            "L3MON4D3/LuaSnip",
            build = (function()
               if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                  return
               end
               return "make install_jsregexp"
            end)(),
            dependencies = {
               --    https://github.com/rafamadriz/friendly-snippets
               {
                  "rafamadriz/friendly-snippets",
                  config = function()
                     require("luasnip.loaders.from_vscode").lazy_load()
                  end,
               },
            },
         },
         "saadparwaiz1/cmp_luasnip",

         "hrsh7th/cmp-nvim-lsp",
         "hrsh7th/cmp-path",
      },
      config = function()
         -- See `:help cmp`
         local cmp = require("cmp")
         local luasnip = require("luasnip")
         luasnip.config.setup({})

         cmp.setup({
            snippet = {
               expand = function(args)
                  luasnip.lsp_expand(args.body)
               end,
            },
            completion = { completeopt = "menu,menuone,noinsert" },

            -- For an understanding of why these mappings were
            -- chosen, you will need to read `:help ins-completion`
            --
            -- No, but seriously. Please read `:help ins-completion`, it is really good!
            mapping = keymaps_module.init_nvimcmp_keymaps(),

            sources = {
               { name = "nvim_lsp" },
               { name = "luasnip" },
               { name = "path" },
            },
         })
      end,
   },

   -- { -- You can easily change to a different colorscheme.
   --   -- Change the name of the colorscheme plugin below, and then
   --   -- change the command in the config to whatever the name of that colorscheme is.
   --   --
   --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
   --   'folke/tokyonight.nvim',
   --   --
   --   -- 'morhetz/gruvbox',
   --   priority = 1000, -- Make sure to load this before all the other start plugins.
   --   init = function()
   --     -- load the colorscheme here.
   --     -- like many other themes, this one has different styles, and you could load
   --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
   --     vim.cmd.colorscheme 'tokyonight-moon'
   --
   --     -- vim.cmd.colorscheme 'gruvbox-dark'
   --     -- you can configure highlights by doing something like:
   --     vim.cmd.hi 'comment gui=none'
   --   end,
   -- },
   {
      "ellisonleao/gruvbox.nvim",
      priority = 1000,
      event = "VimEnter",
      config = function()
         require("gruvbox").setup({
            terminal_colors = true, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
               strings = true,
               emphasis = true,
               comments = true,
               operators = false,
               folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            contrast = "", -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = true,
         })
         vim.cmd("colorscheme gruvbox")
         -- vim.o.background = "dark"
         -- vim.o.background = "light"
      end,
   },

   -- Highlight todo, notes, etc in comments
   {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
   },

   {
      "echasnovski/mini.nvim",
      config = function()
         -- Better Around/Inside textobjects
         --
         -- Examples:
         --  - va)  - [V]isually select [A]round [)]paren
         --  - yinq - [Y]ank [I]nside [N]ext [']quote
         --  - ci'  - [C]hange [I]nside [']quote
         require("mini.ai").setup({ n_lines = 500 })

         -- Add/delete/replace surroundings (brackets, quotes, etc.)
         --
         -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
         -- - sd'   - [S]urround [D]elete [']quotes
         -- - sr)'  - [S]urround [R]eplace [)] [']
         require("mini.surround").setup()

         -- Simple and easy statusline.
         --  You could remove this setup call if you don't like it,
         --  and try some other statusline plugin
         local statusline = require("mini.statusline")
         -- set use_icons to true if you have a Nerd Font
         statusline.setup({ use_icons = vim.g.have_nerd_font })

         -- You can configure sections in the statusline by overriding their
         -- default behavior. For example, here we set the section for
         -- cursor location to LINE:COLUMN
         ---@diagnostic disable-next-line: duplicate-set-field
         statusline.section_location = function()
            return "%2l:%-2v"
         end

         -- ... and there is more!
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
   { -- Highlight, edit, and navigate code
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
         ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
         -- Autoinstall languages that are not installed
         auto_install = true,
         highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "ruby" },
         },
         indent = { enable = true, disable = { "ruby" } },
      },
      config = function(_, opts)
         require("nvim-treesitter.install").prefer_git = true
         ---@diagnostic disable-next-line: missing-fields
         require("nvim-treesitter.configs").setup(opts)
      end,
   },
}, {
   ui = {
      icons = vim.g.have_nerd_font and {} or {
         cmd = "",
         config = "",
         event = "",
         ft = "",
         init = "",
         keys = "",
         plugin = "",
         runtime = "",
         require = "",
         source = "",
         start = "北",
         task = "",
         lazy = "鈴",
      },
   },
})
