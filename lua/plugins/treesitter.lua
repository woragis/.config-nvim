local parsers = {
  "bash",
  "css",
  "diff",
  "gitcommit",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local filetypes = {
  "bash",
  "sh",
  "css",
  "diff",
  "gitcommit",
  "go",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "lua",
  "markdown",
  "python",
  "query",
  "toml",
  "typescript",
  "typescriptreact",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install(parsers)

      vim.treesitter.language.register("bash", "sh")
      vim.treesitter.language.register("javascript", "javascriptreact")
      vim.treesitter.language.register("tsx", "typescriptreact")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function(event)
          vim.treesitter.start(event.buf)
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
