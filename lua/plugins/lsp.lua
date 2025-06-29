return { -- LSP Configuration & Plugins
   {
      --
      "neovim/nvim-lspconfig",
      dependencies = {

         -- Automatically install LSPs and related tools to stdpath for Neovim
         -- Only installs stuff
         { "williamboman/mason.nvim", config = true },

         -- Bridges nvim-lspconfig with mason.nvim
         { "williamboman/mason-lspconfig.nvim" },

         -- Installs lsp servers datas in auto-mode
         { "WhoIsSethDaniel/mason-tool-installer.nvim" },

         -- UI for LSP servers logs like progress bars (percentage of
         -- loadiong smt)
         { "j-hui/fidget.nvim", opts = {} },

         -- Auto configurator for Lua-lsp (lua-ls) server
         { "folke/neodev.nvim", opts = {} },

         -- DAP (DEBUGGER)
         {
            "jayp0521/mason-nvim-dap",
            event = "VeryLazy",
            dependencies = {
               "williamboman/mason.nvim",
               "mfussenegger/nvim-dap",
            },
         },
      },
      config = function()
         -- vim.lsp.enable("biome")
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

         local util = require("lspconfig.util")

         local servers = {
            clangd = {
               cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
            },
            -- clangformat = {},
            glslls = {},
            cpptools = {},
            -- biome = {},
            biome = {
               cmd = { "biome", "lsp-proxy" },
               filetypes = {
                  "astro",
                  "css",
                  "graphql",
                  "html",
                  "javascript",
                  "javascriptreact",
                  "json",
                  "jsonc",
                  "svelte",
                  "typescript",
                  "typescript.tsx",
                  "typescriptreact",
                  "vue",
               },
               workspace_required = true,
               root_dir = function(fname)
                  local root_files = { "biome.json", "biome.jsonc" }
                  -- util.insert_package_json — добавляет package.json в список, если нужно
                  root_files = util.insert_package_json(root_files, "biome", fname)
                  local found = vim.fs.find(root_files, { path = fname, upward = true })
                  if found[1] then
                     return vim.fs.dirname(found[1])
                  end
                  -- fallback: например, корень git или директория файла
                  return util.find_git_ancestor(fname) or vim.loop.os_homedir()
               end,
            },
            codelldb = {},
            cmakelang = {},
            cmake = {},
            pyright = {
               on_attach = function(client, bufnr)
                  client.server_capabilities.documentFormattingProvider = false
               end,
            },
            lua_ls = {
               settings = {
                  Lua = {
                     workspace = {
                        -- Path to your Addons directory
                        userThirdParty = { os.getenv("HOME") .. ".local/share/LuaAddons" },
                        checkThirdParty = "Apply",
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

         -- require("mason-lspconfig").setup({
         --    handlers = {
         --       function(server_name)
         --          local server = servers[server_name] or {}
         --          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
         --          require("lspconfig")[server_name].setup(server)
         --       end,
         --    },
         -- })
         -- require("mason-nvim-dap").setup({
         --    ensure_installed = { "cpptools" },
         -- })

         local lspconfig = require("lspconfig")

         vim.diagnostic.config({
            float = {
               border = "rounded",
            },
         })

         require("mason-lspconfig").setup_handlers({
            function(server_name)
               local server = servers[server_name] or {}
               server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
               require("lspconfig")[server_name].setup(server)
            end,
         })

         vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
         vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
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

         local kind_icons = {
            Text = "",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰇽",
            Variable = "󰂡",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰅲",
         }

         cmp.setup({
            formatting = {
               format = function(entry, vim_item)
                  -- Kind icons
                  vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatenates the icons with the name of the item kind
                  -- Source
                  vim_item.menu = ({
                     buffer = "[Buffer]",
                     nvim_lsp = "[LSP]",
                     luasnip = "[LuaSnip]",
                     nvim_lua = "[Lua]",
                     latex_symbols = "[LaTeX]",
                  })[entry.source.name]
                  return vim_item
               end,
            },
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
            window = {
               completion = cmp.config.window.bordered({
                  col_offset = 0,
               }),
               documentation = cmp.config.window.bordered(),
            },
         })
      end,
   },
   {
      "nvim-treesitter/playground",
   },
}
