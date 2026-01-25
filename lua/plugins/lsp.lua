-- AI generated code (slop)

local is_011 = (vim.fn.has("nvim-0.11") == 1)

local function client_supports_method(client, method, bufnr)
   if is_011 then
      return client:supports_method(method, bufnr)
   end
   return client.supports_method(method, { bufnr = bufnr })
end

-- 1. Optimized Keymapper (Flat logic)
local function lsp_keymaps(bufnr)
   local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
   end

   map("grn", vim.lsp.buf.rename, "Rename")
   map("gra", vim.lsp.buf.code_action, "Action")
   map("grr", require("telescope.builtin").lsp_references, "References")
   map("gri", require("telescope.builtin").lsp_implementations, "Implementation")
   map("grd", require("telescope.builtin").lsp_definitions, "Definition")
   map("gd", vim.lsp.buf.definition, "Definition")
   map("gO", require("telescope.builtin").lsp_document_symbols, "Symbols")
end

-- 2. Optimized Highlighting (No leaks)
local function lsp_highlighting(client, bufnr)
   if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
      -- Use bufnr in the name to keep groups isolated
      local group = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
         buffer = bufnr,
         group = group,
         callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
         buffer = bufnr,
         group = group,
         callback = vim.lsp.buf.clear_references,
      })

      -- Cleanup when LSP leaves this specific buffer
      vim.api.nvim_create_autocmd("LspDetach", {
         buffer = bufnr,
         callback = function()
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
         end,
      })
   end
end

return {
   {
      "neovim/nvim-lspconfig",
      dependencies = {
         { "williamboman/mason.nvim", config = true },
         "williamboman/mason-lspconfig.nvim",
         "WhoIsSethDaniel/mason-tool-installer.nvim",
         { "j-hui/fidget.nvim", opts = {} },
         "Saghen/blink.cmp",
      },
      config = function()
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
            callback = function(event)
               local client = vim.lsp.get_client_by_id(event.data.client_id)
               if not client then
                  return
               end

               lsp_keymaps(event.buf)
               lsp_highlighting(client, event.buf)

               -- Inlay Hints (0.10+)
               -- if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
               --    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
               -- end
            end,
         })

         -- High performance Diagnostic Config (Static)
         vim.diagnostic.config({
            severity_sort = true,
            float = { border = "rounded" },
            underline = { severity = vim.diagnostic.severity.ERROR },
            virtual_text = { prefix = "●", spacing = 4 },
            signs = {
               text = {
                  [vim.diagnostic.severity.ERROR] = "󰅚 ",
                  [vim.diagnostic.severity.WARN] = "󰀪 ",
                  [vim.diagnostic.severity.INFO] = "󰋽 ",
                  [vim.diagnostic.severity.HINT] = "󰌶 ",
               },
            },
         })

         local capabilities = require("blink.cmp").get_lsp_capabilities()
         local servers = {
            clangd = {
               -- Command line flags to make clangd smoother
               cmd = {
                  "clangd",
                  "--background-index",
                  "--clang-tidy",
                  "--header-insertion=iwyu",
                  "--completion-style=detailed",
                  "--function-arg-placeholders",
               },
            },
            lua_ls = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },
            pyright = { settings = { python = { analysis = { autoImportCompletions = true } } } },
         }

         require("mason-tool-installer").setup({
            ensure_installed = vim.list_extend(vim.tbl_keys(servers), { "stylua", "ruff" }),
         })

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
      "saghen/blink.cmp",
      version = "1.*",
      opts = {
         keymap = { preset = "default" },
         appearance = { nerd_font_variant = "mono" },
         completion = {
            menu = { border = "rounded" },
            documentation = { auto_show = true, window = { border = "rounded" } },
         },
         signature = { enabled = true, window = { border = "rounded" } },
      },
   },
}

-- BUT it works lol. All became so fast!

-- local is_011 = (vim.fn.has("nvim-0.11") == 1)
--
-- -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
-- ---@param client vim.lsp.Client
-- ---@param method vim.lsp.protocol.Method
-- ---@param bufnr? integer some lsp support methods only in specific files
-- ---@return boolean
-- local function client_supports_method(client, method, bufnr)
--    return (is_011 and client:supports_method(method, bufnr)) or client.supports_method(method, { bufnr = bufnr })
-- end
--
-- ---@param event table
-- local function mapLspServer(event)
--    local mapKey = function(keys, func, desc, mode)
--       mode = mode or "n"
--       vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
--    end
--
--    -- Rename variable, function, or any other code unit
--    mapKey("grn", vim.lsp.buf.rename, "[R]e[n]ame")
--
--    -- Some useful actions you need under cursor like disabling diagnostic for a piece
--    -- of code. Not to write '# pyright: ignore ...' or smt like it. This mapping will
--    -- do it for user undependently of code language
--    mapKey("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
--
--    -- Searches for references of code unit under cursor
--    -- Works simular to RENAMING but provides (for this neovim configuration) ability
--    -- to show all variable (or smt else) instances inside telescope
--    mapKey("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
--
--    -- From kickstart. Maybe useful
--    mapKey("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
--    mapKey("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
--
--    -- Default classic old jump logic
--    mapKey("gf", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
--    mapKey("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
--    mapKey("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
--
--    --
--    mapKey("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
--
--    mapKey("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
-- end
--
-- local function enableHighlightWordsOnHover(event)
--    local client = vim.lsp.get_client_by_id(event.data.client_id)
--    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
--       local highlight_augroup = vim.api.nvim_create_augroup("lsp-hightlight", { clear = false })
--       vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--          buffer = event.buf,
--          group = highlight_augroup,
--          callback = vim.lsp.buf.document_highlight,
--       })
--
--       vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--          buffer = event.buf,
--          group = highlight_augroup,
--          callback = vim.lsp.buf.clear_references,
--       })
--
--       vim.api.nvim_create_autocmd("LspDetach", {
--          group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
--          callback = function(event2)
--             vim.lsp.buf.clear_references()
--             vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = event2.buf })
--          end,
--       })
--    end
-- end
--
-- local function enableInlineHints(client, event)
--    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
--       vim.keymap.set("n", "<leader>th", function()
--          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
--       end, { desc = "[T]oggle inlay [H]ints" })
--
--       -- mapKey(event, "<leader>th", function()
--       --    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
--       -- end, "[T]oggle inlay [H]ints")
--    end
-- end
--
-- return { -- LSP Configuration & Plugins
--    {
--       --
--       "neovim/nvim-lspconfig",
--       dependencies = {
--
--          -- Automatically install LSPs and related tools to stdpath for Neovim
--          -- Only installs stuff
--          { "williamboman/mason.nvim", config = true },
--
--          -- Bridges nvim-lspconfig with mason.nvim
--          { "williamboman/mason-lspconfig.nvim" },
--
--          -- Installs lsp servers datas in auto-mode
--          { "WhoIsSethDaniel/mason-tool-installer.nvim" },
--
--          -- UI for LSP servers logs like progress bars (percentage of
--          -- loadiong smt)
--          { "j-hui/fidget.nvim", opts = {} },
--
--          -- Auto configurator for Lua-lsp (lua-ls) server
--          -- { "folke/neodev.nvim", opts = {} },
--
--          { "Saghen/blink.cmp" },
--
--          -- NOTE: No need for this for now
--          --
--          -- DAP (DEBUGGER)
--          -- {
--          --    "jayp0521/mason-nvim-dap",
--          --    event = "VeryLazy",
--          --    dependencies = {
--          --       "williamboman/mason.nvim",
--          --       "mfussenegger/nvim-dap",
--          --    },
--          -- },
--       },
--       config = function()
--          -- Needed autocommand to attach needed lsp server for
--          -- needed file (with needed language)
--          vim.api.nvim_create_autocmd("LspAttach", {
--             group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
--             callback = function(event)
--                mapLspServer(event)
--                enableHighlightWordsOnHover(event)
--                -- enableInlineHints( event)
--             end,
--          })
--
--          -- Diagnostic configuration
--          -- vim.diagnostic.config({
--          --    severity_sort = true,
--          --    float = { border = "rounded", source = "if_many" },
--          --    underline = { severity = vim.diagnostic.severity.ERROR },
--          --    signs = vim.g.have_nerd_font and {
--          --       [vim.diagnostic.severity.ERROR] = "󰅚 ",
--          --       [vim.diagnostic.severity.WARN] = "󰀪 ",
--          --       [vim.diagnostic.severity.INFO] = "󰋽 ",
--          --       [vim.diagnostic.severity.HINT] = "󰌶 ",
--          --    } or {},
--          --    virtual_text = {
--          --       source = "if_many",
--          --       spacing = 2,
--          --       format = function(diagnostic)
--          --          local diagnostic_message = {
--          --             [vim.diagnostic.severity.ERROR] = diagnostic.message,
--          --             [vim.diagnostic.severity.WARN] = diagnostic.message,
--          --             [vim.diagnostic.severity.INFO] = diagnostic.message,
--          --             [vim.diagnostic.severity.HINT] = diagnostic.message,
--          --          }
--          --          return diagnostic_message[diagnostic.severity]
--          --       end,
--          --    },
--          -- })
--          vim.diagnostic.config({
--             severity_sort = true,
--             float = { border = "rounded" },
--             underline = { severity = vim.diagnostic.severity.ERROR },
--             virtual_text = {
--                prefix = "●",
--                source = "if_many",
--                spacing = 4,
--             },
--             signs = {
--                text = {
--                   [vim.diagnostic.severity.ERROR] = "󰅚 ",
--                   [vim.diagnostic.severity.WARN] = "󰀪 ",
--                   [vim.diagnostic.severity.INFO] = "󰋽 ",
--                   [vim.diagnostic.severity.HINT] = "󰌶 ",
--                },
--             },
--          })
--
--          -- Capabilities (extra lsp methods)
--          local capabilities = require("blink.cmp").get_lsp_capabilities()
--          local servers = {
--             -->
--             lua_ls = {
--                settings = {
--                   Lua = {
--                      completion = { callSnippet = "Replace" },
--                   },
--                },
--             },
--             -- basedpyright = {
--             --    -- Using Ruff's import organizer
--             --    disableOrganizeImports = true,
--             -- },
--             pyright = {
--                -- Using Ruff's import organizer
--                disableOrganizeImports = true,
--             },
--
--             clangd = {},
--             -- ["cmake-language-server"] = {},
--             glsl_analyzer = {},
--             gopls = {},
--             zls = {},
--             texlab = {},
--             ["css-lsp"] = {},
--             ["json-lsp"] = {},
--             -- glslls = {},
--          }
--
--          local ensure_installed = vim.tbl_keys(servers or {})
--          vim.list_extend(ensure_installed, { "stylua", "ruff" })
--          require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
--
--          require("mason-lspconfig").setup({
--             ensure_installed = {},
--             automatic_installation = false,
--             handlers = {
--                function(server_name)
--                   local server = servers[server_name] or {}
--                   server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
--                   require("lspconfig")[server_name].setup(server)
--                end,
--             },
--          })
--       end,
--    },
--
--    {
--       "saghen/blink.cmp",
--       event = "VimEnter",
--       version = "1.*",
--       -- dependencies = {
--       --    {
--       --       "L3MON4D3/LuaSnip",
--       --       version = "2.*",
--       --       build = (function()
--       --          -- Build Step is needed for regex support in snippets.
--       --          -- This step is not supported in many windows environments.
--       --          -- Remove the below condition to re-enable on windows.
--       --          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
--       --             return
--       --          end
--       --          return "make install_jsregexp"
--       --       end)(),
--       --       dependencies = {
--       --          -- `friendly-snippets` contains a variety of premade snippets.
--       --          --    See the README about individual language/framework/plugin snippets:
--       --          --    https://github.com/rafamadriz/friendly-snippets
--       --          -- {
--       --          --   'rafamadriz/friendly-snippets',
--       --          --   config = function()
--       --          --     require('luasnip.loaders.from_vscode').lazy_load()
--       --          --   end,
--       --          -- },
--       --       },
--       --       opts = {},
--       --    },
--       --    "folke/lazydev.nvim",
--       -- },
--
--       --- @module 'blink.cmp'
--       --- @type blink.cmp.Config
--       opts = {
--          keymap = { preset = "default" },
--          appearance = { nerd_font_variant = "mono" },
--          completion = {
--             -- documentation = {
--             --    auto_show = false,
--             --    auto_show_delay_ms = 500,
--             --    window = { border = "rounded" },
--             -- },
--             menu = {
--                border = "rounded",
--                -- draw = {
--                --    components = {
--                --       kind_icon = {
--                --          text = function(ctx)
--                --             local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
--                --             return kind_icon
--                --          end,
--                --          -- (optional) use highlights from mini.icons
--                --          highlight = function(ctx)
--                --             local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
--                --             return hl
--                --          end,
--                --       },
--                --       kind = {
--                --          -- (optional) use highlights from mini.icons
--                --          highlight = function(ctx)
--                --             local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
--                --             return hl
--                --          end,
--                --       },
--                --    },
--                -- },
--             },
--          },
--
--          -- sources = {
--          --    default = { "lsp", "path", "snippets", "lazydev" },
--          --    providers = {
--          --       lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
--          --    },
--          -- },
--
--          -- snippets = { present = "luasnip" },
--
--          -- fuzzy = { implementation = "lua" },
--
--          signature = { enabled = true, window = { border = "rounded" } },
--       },
--    },
--    -- {
--    --    "nvim-treesitter/playground",
--    -- },
-- }
