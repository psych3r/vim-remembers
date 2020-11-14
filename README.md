# remembers.vim

Remembers emulates the behavior of Notepad++ where you can open multiple
unnamed files (`:enew` or `:tabnew` in vim), edit them, close the editor 
and all the files are there when you open it again.

Remembers simply saves all unnamed buffers upon exiting vim, creates a
session file and reloads it automatically when vim is opened again.

Unnamed buffers are always saved. 
A session is created/loaded only if vim is called with no file arguments.

This makes it so that calling `vim` restores the last saved session if 
available and creates a new session before exiting, while calling 
`vim <files>` doesn't restore or create a session.

This can be overridden by setting the variables

    let g:remembers_always_create = 1
    let g:remembers_always_reload = 1

They both default to `0`.

For other options and further explanation `:h remembers`.

## Installation

Using a plugin manager is recommended. [vim-plug](https://github.com/junegunn/vim-plug) is awesome !

    Plug 'abdalrahman-ali/vim-remembers'

## Contributing

Suggestions and pull requests are always welcome. Just open an issue first.
