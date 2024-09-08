require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({"n", "t"}, "<A-k>", function()
  require("nvchad.term").toggle({ pos = "float", id = "lazygit", cmd = "lazygit", float_opts = {
    row = 0,
    col = 0,
    width = 0.95,
    height = 0.9,
    border = "double",
  }})
end, {desc = "Toggle lazygit"})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
