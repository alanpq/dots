local nvlsp = require "nvchad.configs.lspconfig"
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "nix",
        "bash",
        "rust",
        "toml",
        "svelte",
        "javascript",
        "typescript",
        "markdown",
        "markdown_inline",
        "comment",
      },
      indent = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
      markdown_fenced_languages = {
        "vim",
        "lua",
        "python",
        "javascript",
        "typescript",
        "svelte",
        "rust",
        "c",
        "cpp",
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = false,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    config = function(_, _)
      vim.g.rustaceanvim = {
        server = {
          on_attach = nvlsp.on_attach,
          on_init = nvlsp.on_init,
          capabilities = nvlsp.capabilities,
          load_vscode_settings = false,
        },
      }
    end,
  },
}
