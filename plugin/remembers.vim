" remembers.vim - Continuously updated session files
" Maintainer:     Abdalrahman Mursi <abdalrahman.mursi@gmail.com>
" Version:        1.1

if exists("g:loaded_remembers") || &cp
    finish
endif
let g:loaded_remembers = 1
let s:osname = system("uname -s")

" setting defaults

if !exists('g:remembers_always_create')
    let g:remembers_always_create=0
endif

if !exists('g:remembers_always_reload')
    let g:remembers_always_reload=0
endif

if !exists('g:remembers_tmp_prefix')
    let g:remembers_tmp_prefix='tmp_'
endif

if !exists('g:remembers_tmp_suffix')
    let g:remembers_tmp_suffix=''
endif

if !exists('g:remembers_tmp_dir')
    let g:remembers_tmp_dir='~/.vim/.tmp_files'
endif

if !exists('g:remembers_session_dir')
    let g:remembers_session_dir='~/.vim/.tmp_files'
endif

if !exists('g:remembers_session_fname')
    let g:remembers_session_fname='.remembers_session.vim'
endif

if !exists('g:remembers_ignore_empty_buffers')
    let g:remembers_ignore_empty_buffers=0
endif

if !exists('g:Remembers_file_counter')
    let g:Remembers_file_counter = 1
endif

function! s:Remembers_save_tmps(dir,prefix,suffix)
    let bufcount = bufnr("$")
    let currbufnr = 1
    let original_place = bufnr('%')
    while currbufnr <= bufcount
        if bufexists(currbufnr) && buflisted(currbufnr) == 1
            if bufname(currbufnr) == ''
                execute ":buffer ". currbufnr
                if line('$') == 1 && getline(1) == '' && g:remembers_ignore_empty_buffers == 1
                    let currbufnr = currbufnr + 1
                    continue
                else
                    let dir_path = substitute(fnamemodify(expand(a:dir), ':p'), '[\/]$', '', '')  . '/'
                    if !isdirectory(dir_path)
                        call mkdir(dir_path, "p")
                    endif
                    let fname = a:prefix . string(g:Remembers_file_counter) . a:suffix
                    execute ":w! " . dir_path . fname
                    let g:Remembers_file_counter += 1
                endif
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
    execute ":buffer ". original_place 
endfunction

fu! s:get_args_count()
    let arg_count = has('win32') || s:osname == "Darwin\n" ? argc() : len(split(system("ps -o command= -p ".getpid()))) - 1
    " argc() now reports the correct number of arguments with nvim v0.10
    " if has('nvim')
        " let arg_count = arg_count - 1
    " endif
    " echo "Argument Count: " . arg_count
    return arg_count
endfunction

fu! s:Remembers_save_session(dir, fname)
    if s:get_args_count() <= 0 || g:remembers_always_create == 1
        let sessionoptions = &sessionoptions
        let dir_path = substitute(fnamemodify(expand(a:dir), ':p'), '[\/]$', '', '')  . '/'
        if !isdirectory(dir_path)
            call mkdir(dir_path, "p")
        endif
        let session_file = dir_path . a:fname
        try
            set sessionoptions-=blank sessionoptions-=curdir sessionoptions-=sesdir sessionoptions-=options 
            set sessionoptions+=tabpages sessionoptions+=globals
            execute 'mksession! '. session_file
        catch /^Vim(mksession):E11:/
            return ''
        catch
            return 'echoerr '.string(v:exception)
        finally
            let &sessionoptions = sessionoptions
        endtry
    endif
endfunction

fu! s:Remembers_restore_session(dir, fname)
    if s:get_args_count() <= 0  || g:remembers_always_reload == 1
        let dir_path = substitute(fnamemodify(expand(a:dir), ':p'), '[\/]$', '', '')  . '/'
        let session_file = dir_path . a:fname
        if filereadable(session_file)
            execute 'so ' . session_file
        endif
    endif
endfunction

augroup remembersPlugin
    autocmd!
    autocmd VimLeavePre * call s:Remembers_save_tmps(g:remembers_tmp_dir, g:remembers_tmp_prefix, g:remembers_tmp_suffix)
    autocmd VimLeave * call s:Remembers_save_session(g:remembers_session_dir, g:remembers_session_fname)
    autocmd VimEnter * nested call s:Remembers_restore_session(g:remembers_session_dir, g:remembers_session_fname)
augroup END

" vim: ft=vim fdm=indent
