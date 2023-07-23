function! shell#print()
    echo 'let &shell        =' &shell
    echo 'let &shellcmdflag =' &shellcmdflag
    echo 'let &shellredir   =' &shellredir
    echo 'let &shellpipe    =' &shellpipe
    echo 'let &shellquote   =' &shellquote
    echo 'let &shellxquote  =' &shellxquote
    return v:false
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

function! shell#list()
    for name in keys(g:shell.configurations)
        echo name
    endfor
    return v:false
endfunction

function! shell#_load()
endfunction
