scriptencoding utf-8

" Plugin specification and lua stuff
lua require('plugins')

" Use short names for common plugin manager commands to simplify typing.
" To use these shortcuts: first activate command line with `:`, then input the
" short alias, e.g., `pi`, then press <space>, the alias will be expanded to
" the full command automatically.
call utils#Cabbrev('pi', 'PackerInstall')
call utils#Cabbrev('pud', 'PackerUpdate')
call utils#Cabbrev('pc', 'PackerClean')
call utils#Cabbrev('ps', 'PackerSync')

""" MARKDOWN PREVIEW

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1
let g:mkdp_command_for_global = 1
let g:mkdp_browser = 'firefox'
" use a custom port to start server or random for empty
let g:mkdp_port = '1199'

au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm set ft=jinja
