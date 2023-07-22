# shell.vim
Collection of shell configs for vim

## Installation

- [packer](https://github.com/wbthomason/packer.nvim)
```lua
use 'pinbraerts/shell.vim'
```

- [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug 'pinbraerts/shell.vim'
```

## Telescope integration

1) Setup
```lua
require'telescope'.load_extension('shell')
```

2) Open picker
```lua
require'telescope'.extensions.shell.configurations()
```


## Usage

- Restore default options
```
:Shell
```

or

```
:Shell default
```

- Change shell
```
:Shell powershell
```

or silent

```
:Shell! pwsh
```

- List all shells
```
:Shell list
```

- Print current configuration
```
:Shell print
```

## Contribution

Add new shell config in [autoload/shell.vim](https://github.com/pinbraerts/shell.vim/blob/main/autoload/shell.vim)
```viml
function! shell#config_name()
    let &shell        = 'shell_executable'
    let &shellcmdflag = 'launch flags'
    let &shellredir   = 'redirect options'
    let &shellpipe    = 'pipe options'
    let &shellquote   = 'quote around the command excluding redirection'
    let &shellxquote  = 'quote around the command including redirection'
endfunction
```

it will be automatically added to `g:shell_configurations` dictionary
 
