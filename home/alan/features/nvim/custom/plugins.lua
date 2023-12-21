local plugins = {

{
  "neovim/nvim-lspconfig",

   dependencies = {
     "jose-elias-alvarez/null-ls.nvim",
     config = function()
       require "custom.configs.null-ls"
     end,
   },
 
   config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
   end,
},

  {
    "williamboman/mason.nvim",
    enabled = false,
    -- opts = {
    --   ensure_installed = {
    --     "lua-language-server",
    --     "html-lsp",
    --     "prettier",
    --     "stylua",
    --     "rust-analyzer",
    --   },
    -- },
  },


  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "c",
        "markdown",
        "markdown_inline",
        "rust",
      },
      indent = {
        enable = true,
        -- disable = {
        --   "python"
        -- },
      },
    },
  },
  
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        enable = true,
      },
    
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = true,
          },
        },
      },
    },
  },


}

return plugins