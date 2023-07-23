if exists('g:shell')
    finish
endif

function! s:definition(symbol, request = 'function')
    if type(a:symbol) == v:t_dict
        for name in keys(a:symbol)
            if exists('&'..name)
                let info = s:definition(name, 'set')
                if len(info)
                    return info
                endif
            endif
        endfor
    endif
    let info = execute('verbose '..a:request..' '..a:symbol)->split('\n')
    if len(info) < 2
        return {}
    endif
    let changed = info[1]->split()
    return #{ path : changed[3], lnum : changed[5] + 0 }
endfunction

let s:default = #{ shell   : '',
            \ shellcmdflag : '',
            \ shellredir   : '',
            \ shellpipe    : '',
            \ shellquote   : '',
            \ shellxquote  : '',
            \}

let g:shell = {}
let g:shell.loaded = 1
let g:shell.configurations = {}
let g:shell.selected = 'default'
if len(s:definition(s:default))
    function! shell#custom(configuration)
        for key in keys(s:default)
            if a:configuration->has_key(key)
                execute a:configuration[key]
            endif
        endfor
    endfunction
    let g:shell.selected = 'custom'
endif

function! s:set(bang, shell = 'default', ...)
    if g:shell.configurations->has_key(a:shell)
        let configuration = g:shell.configurations[a:shell]
        let res = configuration->has_key('self') && configuration.self
                    \? configuration.value->call([configuration]->extend(a:000))
                    \: configuration.value()
        if a:bang == '' && res == ''
            call shell#print()
            let g:shell.selected = a:shell
        endif
    else
        echo 'unknown shell config'
    endif
endfunction

function! s:list(ArgLead, CmdLine, CursorPos)
    if a:ArgLead == ''
        return keys(g:shell.configurations)
    endif
    return keys(g:shell.configurations)->matchfuzzy(a:ArgLead)
endfunction

function! s:init()
    call shell#_load()
    for fsig in execute('function /shell#')->split('\n')
        let index = fsig->stridx('(')
        if index < 0 || fsig[15] == '_'
            continue
        endif
        let name = fsig[9:index-1]
        let short = name[6:]
        let g:shell.configurations[short] = s:definition(name)
        let g:shell.configurations[short].value = function(name)
        let g:shell.configurations[short].name = short
        let g:shell.configurations[short].self = fsig[index+1] != ')'
    endfor
    if g:shell.configurations->has_key('custom')
        call extend(g:shell.configurations.custom,
                    \ map(s:default, { key -> 'let &'..key.."='"..execute('echo &'..key)[1:].."'" })
                    \)->extend(s:definition(s:default))
    endif
    command! -bang -nargs=? -complete=customlist,s:list Shell call s:set('<bang>', <f-args>)
endfunction
call s:init()
