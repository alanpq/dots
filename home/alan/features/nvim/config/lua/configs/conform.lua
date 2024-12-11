local options = {
  formatters_by_ft = {
    nix = { "alejandra" },
    lua = { "stylua" },
    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
    typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
    svelte = { "biome", "prettierd", "prettier", stop_after_first = true },

    python = { "isort", "black" },
    rust = { "rustfmt", lsp_format = "fallback" },

    ["*"] = { "codespell" },
    ["_"] = { "trim_whitespace" },
  },

  -- TODO: look into making a vscode's `modificationsIfAvailable` equivalent
  -- https://github.com/stevearc/conform.nvim/issues/92

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    -- lsp_format = "fallback",
    lsp_fallback = true,
  },
}

return options
