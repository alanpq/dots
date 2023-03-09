local masonlsp = require("mason-lspconfig")
local lsp = require("config.lsp-onattach")
masonlsp.setup({
  automatic_installation = true,
})

masonlsp.setup_handlers({
  function (server_name) -- default handler
    require("lspconfig")[server_name].setup({
      on_attach = lsp.on_attach, 
    })
  end,
})
