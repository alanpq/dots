local rt = require("rust-tools")

--local lsp = require("config.lsp")

rt.setup({
  server = {
    on_attach = function(client, bufnr)
      vim.o.tabstop = 2
      vim.o.softtabstop = 2
      vim.o.shiftwidth = 2
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      --lsp.on_attach(client, bufnr)
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy", },
        procMacro = true,
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
