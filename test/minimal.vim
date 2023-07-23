set noshowmode
let s:counter = 1
function Check(bang, ...)
    let shell = exists('a:2') ? a:2 : 'default'
    if a:bang != '' && g:shell.selected != shell
        echoerr 'current config mismatch:' g:shell.selected '!=' shell
        execute 'cquit '..s:counter
    endif
    if v:errmsg
        execute 'cquit '..s:counter
    endif
    if v:shell_error
        execute 'cquit '..-s:counter
    endif
    let s:counter = s:counter + 1
endfunction

command -bang -nargs=* Test
            \ echo '===== Testing "<args>"' <bar>
            \ execute '<args>' <bar>
            \ call Check('<bang>', <f-args>) <bar>
            \ echo '===== Succeded'

set rtp+=~/.config/nvim-data/site/pack/packer/start/plenary.nvim
set rtp+=~/.config/nvim-data/site/pack/packer/start/telescope.nvim
set rtp+=.
runtime! plugin/plenary.vim
runtime! plugin/telescope.vim
runtime! plugin/shell.vim
