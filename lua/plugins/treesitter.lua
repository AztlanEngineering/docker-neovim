return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install parsers (async, but :TSUpdate in build handles initial install)
      require("nvim-treesitter").install({
        "bash",
        "c",
        "dart",
        "diff",
        "dockerfile",
        "gitignore",
        "go",
        "graphql",
        "haskell",
        "hcl",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonnet",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "svelte",
        "terraform",
        "toml",
        "tsx",
        "turtle",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      })

      -- Enable treesitter highlighting and indentation for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
