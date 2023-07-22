# shell.vim
## Description
Collection of shell configs for vim

## Installation

- [packer](https://github.com/wbthomason/packer.nvim)
```lua
use 'pinbraerts/shell.vim'
```

- [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'pinbraerts/shell.vim'
```

## Usage

- Restore default options
```
:Shell
```

or

```
Shell default
```

- Change shell
```
:Shell powershell
```

- Silently switch shells
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

Add new shell config in autoload/shell.vim
```
function! shell#config_name()
    let &shell        = 'shell_executable'
    let &shellcmdflag = 'launch flags'
    let &shellredir   = 'redirect options'
    let &shellpipe    = 'pipe options'
    let &shellquote   = 'quote around the command excluding redirection'
    let &shellxquote  = 'quote around the command including redirection'
endfunction
```

it will be automatically added to `s:configs` dictionary
 
