if exists('g:shell_vim_loaded')
    finish
endif
let g:shell_vim_loaded = 1
call shell_vim#init()
