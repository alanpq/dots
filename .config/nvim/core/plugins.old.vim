scriptencoding utf-8

call plug#begin()

Plug 'joshdick/onedark.vim' " theme
Plug 'vim-airline/vim-airline'

Plug 'sheerun/vim-polyglot' " language pack
Plug 'neoclide/coc.nvim', {'branch': 'release'} " code completion
Plug 'lepture/vim-jinja'

Plug 'williamboman/mason.nvim'

Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

Plug 'jbyuki/nabla.nvim'

call plug#end()

let s:plugin_config_list = [
      \ 'coc.vim'
      \ ]

for s:fname in s:plugin_config_list
  execute printf('source %s/%s', g:nvim_config_root, s:fname)
endfor

nnoremap <F5> :lua require("nabla").action()<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

""" MARKDOWN PREVIEW

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1
let g:mkdp_command_for_global = 1
let g:mkdp_browser = 'firefox'
" use a custom port to start server or random for empty
let g:mkdp_port = '1199'

au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm set ft=jinja
