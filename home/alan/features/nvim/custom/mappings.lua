---@type MappingsTable
local M = {}

local lazyGitted = false

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
  v = {
    [">"] = { ">gv", "indent"},
  },

  ["<A-k>"] = {
    function()
      if lazyGitted then
        require("nvterm.terminal").toggle "float"
        vim.print("already gitted")
      else
        vim.print("not gitted")
        lazyGitted = true
        local term = require("nvterm.terminal").new "float"
        vim.api.nvim_chan_send(term.job_id, "lazygit\n")
      end
    end,
    "Toggle lazygit",
  },
}

-- more keybinds!

return M
