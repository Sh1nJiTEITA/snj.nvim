require("vim_options")
local keymaps_module = require("keymaps")
require("autocmd")

require("lazy").setup({
   {
      "Shatur/neovim-cmake",
      dap_configuration = {
         type = "codelldb",
         request = "launch",
         stopOnEntry = false,
         runInTerminal = false,
      },
   },

   {
      "rcarriga/nvim-dap-ui",
      event = "VeryLazy",
      dependencies = {
         "mfussenegger/nvim-dap",
      },
      config = function()
         local dap = require("dap")
         local dapui = require("dapui")
         dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
         end

         dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
         end

         dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
         end

         require("dapui").setup()
      end,
   },
   {
      "mfussenegger/nvim-dap",
      dependencies = {
         "nvim-neotest/nvim-nio",
      },
      config = function()
         local dap = require("dap")

         vim.keymap.set("n", "<F5>", dap.continue, { desc = "Dap: Continue" })
         vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Dap: Step Over" })
         vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Dap: Step Into" })
         vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Dap: Step Out" })
         vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, { desc = "Dap: Toggle Breakpoint" })
         vim.keymap.set("n", "<Leader>B", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
         end, { desc = "Dap: Conditional Breakpoint" })
         vim.keymap.set("n", "<Leader>lp", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
         end, { desc = "Dap: Log Point" })
         vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Dap: Open REPL" })
         vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Dap: Run Last" })

         dap.configurations.cpp = {
            {
               name = "Launch",
               type = "codelldb",
               request = "launch",
               program = function()
                  local path = vim.g.dap_cpp_path
                  if path == nil then
                     path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                     vim.g.dap_cpp_path = path
                  end
                  return path
               end,
               cwd = "${workspaceFolder}",
               stopOnEntry = false,
               args = {},
            },
         }

         -- dap.adapters.cppdbg = {
         --    id = "cppdbg",
         --    type = "executable",
         --    command = "/home/snj/.local/share/nvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
         -- }
         --
         -- dap.configurations.cpp = {
         --    {
         --       name = "Launch file",
         --       type = "cppdbg",
         --       request = "launch",
         --       program = function()
         --          local executable = vim.fn.findfile("my_program", vim.fn.getcwd() .. "/build")
         --          if executable == "" then
         --             return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
         --          end
         --          return executable
         --       end,
         --       cwd = "${workspaceFolder}",
         --       stopAtEntry = false,
         --       setupCommands = {
         --          {
         --             description = "Enable pretty-printing for gdb",
         --             text = "-enable-pretty-printing",
         --             ignoreFailures = true,
         --          },
         --       },
         --    },
         -- }
         --
         -- -- dap.listeners.before.attach.dapui_config = function()
         -- --    dapui.open()
         -- -- end
         -- -- dap.listeners.before.launch.dapui_config = function()
         -- --    dapui.open()
         -- -- end
         -- -- dap.listeners.before.event_terminated.dapui_config = function()
         -- --    dapui.close()
         -- -- end
         -- -- dap.listeners.before.event_exited.dapui_config = function()
         -- --    dapui.close()
         -- -- end
         --
         -- dap.listeners.after.event_initialized["dapui_config"] = function()
         --    dapui.open()
         -- end
         --
         -- dap.listeners.before.event_terminated["dapui_config"] = function()
         --    dapui.close()
         -- end
         --
         -- dap.listeners.before.event_exited["dapui_config"] = function()
         --    dapui.close()
         -- end
      end,
   },
   {
      "kdheepak/lazygit.nvim",
      lazy = false,
      cmd = {
         "LazyGit",

         "LazyGitConfig",
         "LazyGitCurrentFile",
         "LazyGitFilter",
         "LazyGitFilterCurrentFile",
      },
      -- optional for floating window border decoration
      dependencies = {
         "nvim-telescope/telescope.nvim",
         "nvim-lua/plenary.nvim",
      },
      config = function()
         require("telescope").load_extension("lazygit")
      end,
   },
   {
      "NvChad/nvim-colorizer.lua",
      -- config = function()
      -- require("colorizer").setup({
      opts = {
         RGB = true, -- #RGB hex codes
         RRGGBB = true, -- #RRGGBB hex codes
         names = false, -- "Name" codes like Blue or blue
         RRGGBBAA = false, -- #RRGGBBAA hex codes
         AARRGGBB = false, -- 0xAARRGGBB hex codes
         rgb_fn = false, -- CSS rgb() and rgba() functions
         hsl_fn = false, -- CSS hsl() and hsla() functions
         css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
         css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
         -- Available modes for `mode`: foreground, background,  virtualtext
         mode = "foreground", -- Set the display mode.
         -- Available methods are false / true / "normal" / "lsp" / "both"
         -- True is same as normal
         tailwind = false, -- Enable tailwind colors
         -- parsers can contain values used in |user_default_options|
         sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
         virtualtext = "■",
         -- update color values even if buffer is not focused
         -- example use: cmp_menu, cmp_docs
         always_update = true,
      },
      -- )
      -- end,
   },

   -- {
   --    "brenoprata10/nvim-highlight-colors",
   --    config = function()
   --       require("nvim-highlight-colors").setup({})
   --    end,
   -- },

   -- {
   --    "nvim-tree/nvim-tree.lua",
   --    opts = {},
   -- },
   --

   -- {
   --    "3rd/image.nvim",
   --    dependencies = {
   --       "vhyrro/luarocks.nvim",
   --    },
   --    opts = {
   --       backend = "kitty",
   --       --    integrations = {
   --       --       markdown = {
   --       --          enabled = true,
   --       --          clear_in_insert_mode = false,
   --       --          download_remote_images = true,
   --       --          only_render_image_at_cursor = false,
   --       --          filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
   --       --       },
   --       --       neorg = {
   --       --          enabled = true,
   --       --          clear_in_insert_mode = false,
   --       --          download_remote_images = true,
   --       --          only_render_image_at_cursor = false,
   --       --          filetypes = { "norg" },
   --       --       },
   --       --       html = {
   --       --          enabled = false,
   --       --       },
   --       --       css = {
   --       --          enabled = false,
   --       --       },
   --       --    },
   --       max_width = nil,
   --       max_height = nil,
   --       max_width_window_percentage = nil,
   --       max_height_window_percentage = 50,
   --       window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
   --       window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
   --       editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
   --       tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
   --       hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
   --    },
   -- },

   {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
         "nvim-lua/plenary.nvim",
         "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
         "MunifTanjim/nui.nvim",
         "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
         "s1n7ax/nvim-window-picker",
      },
      opts = {
         window = {
            position = "left",
            width = 30,
            mapping_options = {
               noremap = true,
               nowait = true,
            },
         },
      },
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

   {
      "jayp0521/mason-nvim-dap",
      event = "VeryLazy",
      dependencies = {
         "williamboman/mason.nvim",
         "mfussenegger/nvim-dap",
      },
      opts = {
         handlers = {},
         -- ensure_installed = {
         --    "codelldb"
         -- }
      },
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
            cpptools = {},
            biome = {},
            codelldb = {},
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
         require("mason-nvim-dap").setup({
            ensure_installed = { "cpptools" },
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

   {
      "kdheepak/monochrome.nvim",
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
