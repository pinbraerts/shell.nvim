function! shell#print(bang = '')
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

function! shell#default()
    set shell        &
    set shellcmdflag &
    set shellredir   &
    set shellpipe    &
    set shellquote   &
    set shellxquote  &
endfunction

function! shell#powershell()
    let &shell        = 'powershell'
    let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
    let &shellredir   = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe    = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
    let &shellquote   = ''
    let &shellxquote  = ''
endfunction

function! shell#pwsh()
    let &shell        = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
    let &shellredir   = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe    = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
    let &shellquote   = ''
    let &shellxquote  = ''
endfunction

function! shell#cmd()
    let &shell        = 'cmd'
    let &shellcmdflag = '/s /c'
    let &shellredir   = '>%s 2>&1'
    let &shellpipe    = '2>&1| tee'
    let &shellquote   = ''
    let &shellxquote  = '"'
endfunction

let s:configs = {
            \   'cmd'        : function('shell#cmd')
            \ , 'pwsh'       : function('shell#pwsh')
            \ , 'powershell' : function('shell#powershell')
            \}

function! shell#listshells(ArgLead, CmdLine, CursorPos)
    return keys(s:configs)
endfunction

function! shell#setshell(shell = '')
    if a:shell == ''
        call shell#default()
    elseif has_key(s:configs, a:shell)
        call s:configs[a:shell]()
    else
        echo 'unknown shell config'
    endif
endfunction

function! shell#init()
    command! -bang ShellPrint call shell#print('<bang>')
    command! -bang SetShellPowershell call shell#powershell() <bar>ShellPrint<bang>
    command! -bang SetShellPwsh       call shell#pwsh()       <bar>ShellPrint<bang>
    command! -bang SetShellCmd        call shell#cmd()        <bar>ShellPrint<bang>
    command! -bang -nargs=? -complete=customlist,shell#listshells
                \ SetShell
                \ call shell#setshell(<f-args>) <bar>ShellPrint<bang>
endfunction
