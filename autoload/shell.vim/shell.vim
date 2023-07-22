function! s:print(bang = '')
    if a:bang != ''
        return
    endif
    echo 'let &shell        =' &shell
    echo 'let &shellcmdflag =' &shellcmdflag
    echo 'let &shellredir   =' &shellredir
    echo 'let &shellpipe    =' &shellpipe
    echo 'set shellquote    =' &shellquote
    echo 'set shellxquote   =' &shellxquote
endfunction

function! s:default()
    set shell        &
    set shellcmdflag &
    set shellredir   &
    set shellpipe    &
    set shellquote   &
    set shellxquote  &
endfunction

function! s:powershell()
    let &shell        = 'powershell'
    let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
    let &shellredir   = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe    = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
    let &shellquote   = ''
    let &shellxquote  = ''
endfunction

function! s:pwsh()
    let &shell        = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
    let &shellredir   = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe    = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
    let &shellquote   = ''
    let &shellxquote  = ''
endfunction

function! s:cmd()
    let &shell        = 'cmd'
    let &shellcmdflag = '/s /c'
    let &shellredir   = '>%s 2>&1'
    let &shellpipe    = '2>&1| tee'
    let &shellquote   = ''
    let &shellxquote  = '"'
endfunction

let s:configs = {
            \   'cmd'        : function('s:cmd')
            \ , 'pwsh'       : function('s:pwsh')
            \ , 'powershell' : function('s:powershell')
            \}

function! s:listshells(ArgLead, CmdLine, CursorPos)
    return keys(s:configs)
endfunction

function! s:setshell(shell = '')
    if a:shell == ''
        call s:default()
    elseif has_key(s:configs, a:shell)
        call s:configs[a:shell]()
    else
        echo 'unknown shell config'
    endif
endfunction

function! shell_vim#init()
    command! -bang Powershell call s:powershell() <bar> call s:print('<bang>')
    command! -bang Pwsh       call s:pwsh()       <bar> call s:print('<bang>') 
    command! -bang Cmd        call s:cmd()        <bar> call s:print('<bang>') 
    command! -bang -nargs=? -complete=customlist,s:listshells
                \ SetShell
                \ call s:setshell(<f-args>) <bar> call s:print('<bang>')
endfunction
