-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
---@param client vim.lsp.Client
---@param method vim.lsp.protocol.Method
---@param bufnr? integer some lsp support methods only in specific files
---@return boolean
local function client_supports_method(client, method, bufnr)
   if vim.fn.has("nvim-0.11") == 1 then
      return client:supports_method(method, bufnr)
   else
      return client.supports_method(method, { bufnr = bufnr })
   end
end

local mapKey = function(event, keys, func, desc, mode)
   mode = mode or "n"
   vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
end

---@param event table
local function mapLspServer(event)
   local mapKey = function(keys, func, desc, mode)
      mapKey(event, keys, func, desc, mode)
   end

   -- Rename variable, function, or any other code unit
   mapKey("grn", vim.lsp.buf.rename, "[R]e[n]ame")

   -- Some useful actions you need under cursor like disabling diagnostic for a piece
   -- of code. Not to write '# pyright: ignore ...' or smt like it. This mapping will
   -- do it for user undependently of code language
   mapKey("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

   -- Searches for references of code unit under cursor
   -- Works simular to RENAMING but provides (for this neovim configuration) ability
   -- to show all variable (or smt else) instances inside telescope
   mapKey("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

   -- From kickstart. Maybe useful
   mapKey("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
   mapKey("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

   -- Default classic old jump logic
   mapKey("gf", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
   mapKey("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
   mapKey("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

   --
   mapKey("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

   mapKey("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
   mapKey("<leader>9", function()
      require("cpp_funcs").switchHeaderSourceForCurrentBuffer()
   end, "")
end

local function enableHighlightWordsOnHover(event)
   local client = vim.lsp.get_client_by_id(event.data.client_id)
   if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("lsp-hightlight", { clear = false })
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
         group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
         callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
         end,
      })
   end
end

local function enableInlineHints(event)
   if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      mapKey(event, "<leader>th", function()
         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle inlay [H]ints")
   end
end

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

         { "Saghen/blink.cmp" },

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
         -- Needed autocommand to attach needed lsp server for
         -- needed file (with needed language)
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
            callback = function(event)
               mapLspServer(event)
               enableHighlightWordsOnHover(event)
               enableInlineHints(event)
            end,
         })

         -- Diagnostic configuration
         vim.diagnostic.config({
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
               [vim.diagnostic.severity.ERROR] = "󰅚 ",
               [vim.diagnostic.severity.WARN] = "󰀪 ",
               [vim.diagnostic.severity.INFO] = "󰋽 ",
               [vim.diagnostic.severity.HINT] = "󰌶 ",
            } or {},
            virtual_text = {
               source = "if_many",
               spacing = 2,
               format = function(diagnostic)
                  local diagnostic_message = {
                     [vim.diagnostic.severity.ERROR] = diagnostic.message,
                     [vim.diagnostic.severity.WARN] = diagnostic.message,
                     [vim.diagnostic.severity.INFO] = diagnostic.message,
                     [vim.diagnostic.severity.HINT] = diagnostic.message,
                  }
                  return diagnostic_message[diagnostic.severity]
               end,
            },
         })

         -- Capabilities (extra lsp methods)
         local capabilities = require("blink.cmp").get_lsp_capabilities()
         local servers = {
            -->
            lua_ls = {
               settings = {
                  Lua = {
                     completion = { callSnippet = "Replace" },
                  },
               },
            },
            basedpyright = {
               -- Using Ruff's import organizer
               disableOrganizeImports = true,
            },
            clangd = {},
            ["cmake-language-server"] = {},
            glsl_analyzer = {},
            gopls = {},
            zls = {},
            texlab = {},
            ["css-lsp"] = {},
            ["json-lsp"] = {},
            -- glslls = {},
         }

         local ensure_installed = vim.tbl_keys(servers or {})
         vim.list_extend(ensure_installed, { "stylua", "ruff" })
         require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

         require("mason-lspconfig").setup({
            ensure_installed = {},
            automatic_installation = false,
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
      "saghen/blink.cmp",
      event = "VimEnter",
      version = "1.*",
      dependencies = {
         {
            "L3MON4D3/LuaSnip",
            version = "2.*",
            build = (function()
               -- Build Step is needed for regex support in snippets.
               -- This step is not supported in many windows environments.
               -- Remove the below condition to re-enable on windows.
               if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                  return
               end
               return "make install_jsregexp"
            end)(),
            dependencies = {
               -- `friendly-snippets` contains a variety of premade snippets.
               --    See the README about individual language/framework/plugin snippets:
               --    https://github.com/rafamadriz/friendly-snippets
               -- {
               --   'rafamadriz/friendly-snippets',
               --   config = function()
               --     require('luasnip.loaders.from_vscode').lazy_load()
               --   end,
               -- },
            },
            opts = {},
         },
         "folke/lazydev.nvim",
      },

      --- @module 'blink.cmp'
      --- @type blink.cmp.Config
      opts = {
         keymap = {
            -- 'default' (recommended) for mappings similar to built-in completions
            --   <c-y> to accept ([y]es) the completion.
            --    This will auto-import if your LSP supports it.
            --    This will expand snippets if the LSP sent a snippet.
            -- 'super-tab' for tab to accept
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- For an understanding of why the 'default' preset is recommended,
            -- you will need to read `:help ins-completion`
            --
            -- No, but seriously. Please read `:help ins-completion`, it is really good!
            --
            -- All presets have the following mappings:
            -- <tab>/<s-tab>: move to right/left of your snippet expansion
            -- <c-space>: Open menu or open docs if already open
            -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
            -- <c-e>: Hide menu
            -- <c-k>: Toggle signature help
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            preset = "default",

            -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
         },

         appearance = {
            nerd_font_variant = "mono",
         },

         completion = {
            documentation = { auto_show = false, auto_show_delay_ms = 500, window = { border = "rounded" } },
            menu = {
               border = "rounded",
               draw = {
                  components = {
                     kind_icon = {
                        text = function(ctx)
                           local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                           return kind_icon
                        end,
                        -- (optional) use highlights from mini.icons
                        highlight = function(ctx)
                           local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                           return hl
                        end,
                     },
                     kind = {
                        -- (optional) use highlights from mini.icons
                        highlight = function(ctx)
                           local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                           return hl
                        end,
                     },
                  },
               },
            },
         },

         sources = {
            default = { "lsp", "path", "snippets", "lazydev" },
            providers = {
               lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
            },
         },

         -- snippets = { present = "luasnip" },

         fuzzy = { implementation = "lua" },

         signature = { enabled = true, window = { border = "rounded" } },
      },
   },
   {
      "nvim-treesitter/playground",
   },
}
