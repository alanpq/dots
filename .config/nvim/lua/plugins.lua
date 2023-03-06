local api = vim.api
local fn = vim.fn

local utils = require("utils")

-- The root dir to install all plugins. Plugins are under opt/ or start/ sub-directory.
vim.g.plugin_home = fn.stdpath("data") .. "/site/pack/packer"

--- Install packer if it has not been installed.
--- Return:
--- true: if this is a fresh install of packer
--- false: if packer has been installed
local function packer_ensure_install()
  -- Where to install packer.nvim -- the package manager (we make it opt)
  local packer_dir = vim.g.plugin_home .. "/opt/packer.nvim"

  if fn.glob(packer_dir) ~= "" then
    return false
  end

  -- Auto-install packer in case it hasn't been installed.
  vim.api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})

  local packer_repo = "https://github.com/wbthomason/packer.nvim"
  local install_cmd = string.format("!git clone --depth=1 %s %s", packer_repo, packer_dir)
  vim.cmd(install_cmd)

  return true
end

local fresh_install = packer_ensure_install()

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

local packer = require("packer")
local packer_util = require("packer.util")

-- check if firenvim is active
local firenvim_not_active = function()
  return not vim.g.started_by_firenvim
end

packer.startup {
  function(use)
    -- it is recommended to put impatient.nvim before any other plugins
    use { "lewis6991/impatient.nvim", config = [[require('impatient')]] }

    use { "wbthomason/packer.nvim", opt = true }

    use { "onsails/lspkind-nvim", event = "VimEnter" }
    -- auto-completion engine
    use { "hrsh7th/nvim-cmp", after = "lspkind-nvim", config = [[require('config.nvim-cmp')]] }

    -- nvim-cmp completion sources
    use { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" }
    use { "hrsh7th/cmp-path", after = "nvim-cmp" }
    use { "hrsh7th/cmp-buffer", after = "nvim-cmp" }
    use { "hrsh7th/cmp-omni", after = "nvim-cmp" }
    use { "quangnguyen30192/cmp-nvim-ultisnips", after = { "nvim-cmp", "ultisnips" } }

    -- nvim-lsp configuration (it relies on cmp-nvim-lsp, so it should be loaded after cmp-nvim-lsp).
    use { "neovim/nvim-lspconfig", after = "cmp-nvim-lsp", config = [[require('config.lsp')]] }
    use {'simrat39/rust-tools.nvim', after = "nvim-lspconfig", config = [[require('config.rust-tools')]]}

    use {'williamboman/mason.nvim', config = [[require('config.mason')]]} 
    use {'williamboman/mason-lspconfig.nvim', after = "nvim-lspconfig", config = [[require('config.mason-lspconfig')]]}

    use {'nvim-treesitter/nvim-treesitter', config = [[require('config.treesitter')]],
      run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
      end,
    }
  
    use({
      "iamcco/markdown-preview.nvim",
      run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- A list of colorscheme plugin you may want to try. Find what suits you.
    use { "navarasu/onedark.nvim", opt = true }
    use { "sainnhe/edge", opt = true }
    use { "sainnhe/sonokai", opt = true }
    use { "sainnhe/gruvbox-material", opt = true }
    use { "shaunsingh/nord.nvim", opt = true }
    use { "sainnhe/everforest", opt = true }
    use { "EdenEast/nightfox.nvim", opt = true }
    use { "rebelot/kanagawa.nvim", opt = true }
    use { "catppuccin/nvim", as = "catppuccin", opt = true }
    use { "rose-pine/neovim", as = 'rose-pine', opt = true }
    use { "olimorris/onedarkpro.nvim", opt = true }
    use { "tanvirtin/monokai.nvim", opt = true }
    use { "marko-cerovac/material.nvim", opt = true }

    use { "kyazdani42/nvim-web-devicons", event = "VimEnter" }

    use {
      "nvim-lualine/lualine.nvim",
      event = "VimEnter",
      cond = firenvim_not_active,
      config = [[require('config.statusline')]],
    }

    use { "akinsho/bufferline.nvim", event = "VimEnter",
      cond = firenvim_not_active,
      config = [[require('config.bufferline')]] }

    -- fancy start screen
    use { "glepnir/dashboard-nvim", event = "VimEnter",
      cond = firenvim_not_active,
      config = [[require('config.dashboard-nvim')]]
    }

    use {
      "lukas-reineke/indent-blankline.nvim",
      event = "VimEnter",
      config = [[require('config.indent-blankline')]],
    }

    -- Highlight URLs inside vim
    use { "itchyny/vim-highlighturl", event = "VimEnter" }
    
    -- notification plugin
    use {
      "rcarriga/nvim-notify",
      event = "BufEnter",
      config = function()
        vim.defer_fn(function()
          require("config.nvim-notify")
        end, 2000)
      end,
    }

    -- Snippet engine and snippet template
    use { "SirVer/ultisnips", event = "InsertEnter" }
    use { "honza/vim-snippets", after = "ultisnips" }

    use {"nvim-lua/plenary.nvim"}
    use {"nvim-telescope/telescope.nvim"}

    use { "j-hui/fidget.nvim", after = "nvim-lspconfig", config = [[require('config.fidget-nvim')]] }
  end,
  config = {
    max_jobs = 16,
    compile_path = packer_util.join_paths(fn.stdpath("data"), "site", "lua", "packer_compiled.lua"),
  }
}

-- For fresh install, we need to install plugins. Otherwise, we just need to require `packer_compiled.lua`.
if fresh_install then
  -- We run packer.sync() here, because only after packer.startup, can we know which plugins to install.
  -- So plugin installation should be done after the startup process.
  packer.sync()
else
  local status, _ = pcall(require, "packer_compiled")
  if not status then
    local msg = "File packer_compiled.lua not found: run PackerSync to fix!"
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
  end
end

-- Auto-generate packer_compiled.lua file
api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "*/nvim/lua/plugins.lua",
  group = api.nvim_create_augroup("packer_auto_compile", { clear = true }),
  callback = function(ctx)
    local cmd = "source " .. ctx.file
    vim.cmd(cmd)
    vim.cmd("PackerCompile")
    vim.notify("PackerCompile done!", vim.log.levels.INFO, { title = "Nvim-config" })
  end,
})
