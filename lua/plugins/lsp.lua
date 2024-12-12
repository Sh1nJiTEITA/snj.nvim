return { -- LSP Configuration & Plugins
   {
      "neovim/nvim-lspconfig",
      dependencies = {
         -- Automatically install LSPs and related tools to stdpath for Neovim
         { "williamboman/mason.nvim", config = true },
         { "williamboman/mason-lspconfig.nvim" },
         { "WhoIsSethDaniel/mason-tool-installer.nvim" },
         { "j-hui/fidget.nvim", opts = {} },
         { "folke/neodev.nvim", opts = {} },
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
      },
      config = function()
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
               local client = vim.lsp.get_client_by_id(event.data.client_id)

               require("keymaps").init_lspconfig_keymaps(event, client)

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
            mapping = require("keymaps").init_nvimcmp_keymaps(),

            sources = {
               { name = "nvim_lsp" },
               { name = "luasnip" },
               { name = "path" },
            },
         })
      end,
   },
}
