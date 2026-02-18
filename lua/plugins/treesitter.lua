-- Compatibility shim: nvim-treesitter main branch removed the old module
-- API (parsers.ft_to_lang, parsers.get_parser, configs.is_enabled, etc.)
-- but telescope.nvim 0.1.x still requires them for its previewer.
--
-- Problem: lazy.nvim replaces the table in package.loaded after config()
-- returns, so any rawset/setmetatable done during config() gets lost.
-- Solution: patch the tables via vim.schedule / vim.defer_fn which runs
-- after lazy.nvim finishes its post-config housekeeping.

local function patch_parsers()
  local get_lang = vim.treesitter.language.get_lang or vim.treesitter.language.ft_to_lang

  local parsers = rawget(package.loaded, "nvim-treesitter.parsers")
  if type(parsers) == "table" then
    if rawget(parsers, "ft_to_lang") == nil then
      rawset(parsers, "ft_to_lang", function(ft)
        return get_lang(ft) or ft
      end)
    end
    if rawget(parsers, "get_parser") == nil then
      rawset(parsers, "get_parser", function(bufnr, lang)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        lang = lang or get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype
        return vim.treesitter.get_parser(bufnr, lang)
      end)
    end
  end
end

local function patch_configs()
  local configs = rawget(package.loaded, "nvim-treesitter.configs")
  if type(configs) ~= "table" then
    configs = {}
    rawset(package.loaded, "nvim-treesitter.configs", configs)
  end
  if rawget(configs, "is_enabled") == nil then
    rawset(configs, "is_enabled", function(mod, lang, bufnr)
      if mod == "highlight" then
        return pcall(vim.treesitter.language.inspect, lang)
      end
      return false
    end)
  end
  if rawget(configs, "get_module") == nil then
    rawset(configs, "get_module", function(mod)
      if mod == "highlight" then
        return { additional_vim_regex_highlighting = false }
      end
      return {}
    end)
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      local get_lang = vim.treesitter.language.get_lang or vim.treesitter.language.ft_to_lang

      -- Patch vim.treesitter.language for any plugin using the core API
      if not vim.treesitter.language.ft_to_lang then
        vim.treesitter.language.ft_to_lang = get_lang
      end

      -- Patch now (may be overwritten by lazy.nvim) and schedule re-patch
      patch_parsers()
      patch_configs()

      -- Re-patch after lazy.nvim finishes post-config processing.
      -- vim.schedule runs at the next safe callback point, after lazy.nvim
      -- has finished replacing/resetting module tables.
      vim.schedule(function()
        patch_parsers()
        patch_configs()
      end)

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
