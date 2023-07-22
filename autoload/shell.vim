function! shell#print(which = '')
    if a:which == ''
        echo 'let &shell        = "'..&shell       ..'"'
        echo 'let &shellcmdflag = "'..&shellcmdflag..'"'
        echo 'let &shellredir   = "'..&shellredir  ..'"'
        echo 'let &shellpipe    = "'..&shellpipe   ..'"'
        echo 'let &shellquote   = "'..&shellquote  ..'"'
        echo 'let &shellxquote  = "'..&shellxquote ..'"'
    else
        let info = execute('verbose function shell#'..a:which)->split('\n')
        echo info[2][7:]
        echo info[3][7:]
        echo info[4][7:]
        echo info[5][7:]
        echo info[6][7:]
        echo info[7][7:]
    endif
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

function! s:info()
    let info = execute('verbose set shell')->split('\n')
    if len(info) < 2
        return { }
    endif
    let info = info[1]->split(' ')
    return #{ file : info[3], line : info[5] }
endfunction

function! s:current()
    return #{ path   : 'shell',
            \ flag   : 'shellcmdflag',
            \ redir  : 'shellredir',
            \ pipe   : 'shellpipe',
            \ quote  : 'shellquote',
            \ xquote : 'shellxquote',
            \}->map('execute("echo &"..v:val)[1:]')
            \->extend(s:info())
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

function! shell#_set(bang, shell = 'default', which = v:null)
    if has_key(g:shell_configurations, a:shell)
        let res = a:which == v:null
                    \? g:shell_configurations[a:shell]()
                    \: g:shell_configurations[a:shell](a:which)
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
    command! -bang -nargs=* -complete=customlist,s:list Shell call shell#_set('<bang>', <f-args>)
endfunction
call shell#_init()
