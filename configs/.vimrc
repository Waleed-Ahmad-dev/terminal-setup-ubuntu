" VIM Configuration Profile

" Use the PowerLine plugin. Change Python directory if needed.
" Finds the bindings for whichever python3.x version pip installed into.
let s:powerline = glob('$HOME/.local/lib/python3*/site-packages/powerline/bindings/vim', 0, 1)
if !empty(s:powerline)
  let &rtp .= ',' . s:powerline[-1]
endif

" Always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" Always show the command as it is being typed.
set showcmd

