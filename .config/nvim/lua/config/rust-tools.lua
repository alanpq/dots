local rt = require("rust-tools")

local lsp = require("config.lsp")

rt.setup({
  server = {
    on_attach = function(client, bufnr)
      lsp.on_attach(client, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy", },
      },
    },
  },
  tools = {
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },
})
