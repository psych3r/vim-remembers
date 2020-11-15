" remembers.vim - Continuously updated session files
" Maintainer:     Abdalrahman Mursi <abdalrahman.mursi@gmail.com>
" Version:        1.0

if exists("g:loaded_remembers") || &cp
    finish
endif
let g:loaded_remembers = 1

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

function! s:Remembers_save_tmps(dir,prefix,suffix)
    let bufcount = bufnr("$")
    let currbufnr = 1
    let counter = 0
    let original_place = bufnr('%')
    while currbufnr <= bufcount
        if bufexists(currbufnr) && buflisted(currbufnr) == 1
            if bufname(currbufnr) == ''
                let counter += 1
                execute ":buffer ". currbufnr
                let dir_path = substitute(fnamemodify(expand(a:dir), ':p'), '[\/]$', '', '')  . '/'
                if !isdirectory(dir_path)
                    call mkdir(dir_path, "p")
                endif
                let fname = a:prefix . strftime('%Y%m%d%I%M%S') . '_' .  string(counter) . a:suffix
                execute ":w! " . dir_path . fname
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
    execute ":buffer ". original_place 
endfunction

fu! s:Remembers_save_session(dir, fname)
    if argc() == 0 || g:remembers_always_create == 1
        let sessionoptions = &sessionoptions
        let dir_path = substitute(fnamemodify(expand(a:dir), ':p'), '[\/]$', '', '')  . '/'
        if !isdirectory(dir_path)
            call mkdir(dir_path, "p")
        endif
        let session_file = dir_path . a:fname
        try
            set sessionoptions-=blank sessionoptions-=options sessionoptions+=tabpages
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
    if argc() == 0  || g:remembers_always_reload == 1
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
