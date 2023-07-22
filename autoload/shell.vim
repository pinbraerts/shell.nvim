function! shell#print()
    echo 'let &shell        =' &shell
    echo 'let &shellcmdflag =' &shellcmdflag
    echo 'let &shellredir   =' &shellredir
    echo 'let &shellpipe    =' &shellpipe
    echo 'set shellquote    =' &shellquote
    echo 'set shellxquote   =' &shellxquote
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

function! s:current()
    return #{ path   : 'shell',
            \ flag   : 'shellcmdflag',
            \ redir  : 'shellredir',
            \ pipe   : 'shellpipe',
            \ quote  : 'shellquote',
            \ xquote : 'shellxquote',
            \}->map('execute("echo &"..v:val)[1:]')
endfunction

let g:shell_custom_configuration = s:current()

function! shell#custom(configuration = g:shell_custom_configuration)
    let &shell        = a:configuration.path
    let &shellcmdflag = a:configuration.flag
    let &shellredir   = a:configuration.redir
    let &shellpipe    = a:configuration.pipe
    let &shellquote   = a:configuration.quote
    let &shellxquote  = a:configuration.xquote
endfunction

let g:shell_configurations = {}

function! s:list(ArgLead, CmdLine, CursorPos)
    if a:ArgLead == ''
        return keys(g:shell_configurations)
    endif
    return keys(g:shell_configurations)->filter('v:val =~ "^'..a:ArgLead..'"')
endfunction

function! shell#list()
    echo s:list('', '', '')
    return v:false
endfunction

function! shell#_set(bang, shell = 'default')
    if has_key(g:shell_configurations, a:shell)
        let res = g:shell_configurations[a:shell]()
        if a:bang == '' && res == ''
            call shell#print()
        endif
    else
        echo 'unknown shell config'
    endif
endfunction

function! shell#_init()
    for fsig in execute('function /shell#')->split('\n')
        let idx = fsig->stridx('(')
        if idx < 0
            continue
        endif
        let name = fsig[15:fsig->stridx('(')-1]
        if name[0] == '_'
            continue
        endif
        let g:shell_configurations[name] = function('shell#'..name)
    endfor
    command! -bang -nargs=? -complete=customlist,s:list Shell call shell#_set('<bang>', <f-args>)
endfunction
