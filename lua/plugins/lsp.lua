return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          -- Avoid GitHub API refresh failures during startup; use :MasonUpdate manually.
          registry_cache = { refresh = false },
        },
      },
      "neovim/nvim-lspconfig",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            staticcheck = true,
            analyses = {
              unusedparams = true,
              nilness = true,
            },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        before_init = function(_, config)
          local python = require("config.python").find_python(config.root_dir)
          if not python then
            return
          end
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = { pythonPath = python },
          })
          vim.g.python3_host_prog = python
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "eslint",
          "gopls",
          "basedpyright",
          "ruff",
          "marksman",
        },
        automatic_enable = true,
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "prettier",
          "goimports",
          "debugpy",
          "js-debug-adapter",
          "delve",
        },
      })
    end,
  },
}
