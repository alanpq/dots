local autocmd = vim.api.nvim_create_autocmd

-- Enable markdown syntax highlighting in comments
autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd [[
      syntax match Comment /\/\/.*/ contains=@Spell,CommentURL,CommentTask
      syntax region Comment start="/\*" end="\*/" contains=@Spell,CommentURL,CommentTask
      syntax match CommentURL /https\?:\/\/\S\+/ contained containedin=Comment
      syntax match CommentTask /TODO\|FIXME\|XXX/ contained containedin=Comment
      hi def link CommentURL Underlined
      hi def link CommentTask Todo
    ]]
  end,
})
