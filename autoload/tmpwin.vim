" default setting {{{
let s:DEFAULT_SETTINGS = {}
let s:DEFAULT_SETTINGS['move_cursor'] = 0

function! s:DEFAULT_SETTINGS.open_post()
    
endfunction

function! s:DEFAULT_SETTINGS.open()
    if winwidth(0) > winheight(0) * 2
        60vsplit
    else
        10split
    endif
endfunction
" }}}

let s:opened_tmpbufs = []

" helpers {{{
function! s:call(dict, name, ...)
    if has_key(a:dict, a:name) && type(a:dict[a:name]) == 2 " 2 means funcref.
        call call(a:dict[a:name], a:000, {})
    else
        call call(s:DEFAULT_SETTINGS[a:name], a:000, {})
    endif
endfunction

function! s:find_winnr_like(condition)
    let winnr = winbufnr('$')
    while winnr > 0
        if eval(a:condition)
            return winnr
        endif
        let winnr = winnr - 1
    endwhile
    return -1
endfunction

function! s:winnr_by_bufnr(bufnr)
    return s:find_winnr_like('winbufnr(winnr) == '.a:bufnr)
endfunction

function! s:close_window_by_bufnrs(bufnrs)
    let winnr = winnr('$')
    while winnr > 0
        if index(a:bufnrs, winbufnr(winnr)) != -1
            execute winnr.'wincmd w'
            wincmd c
        endif
        let winnr = winnr - 1
    endwhile
endfunction
" }}}

" main {{{
function! tmpwin#open(...)
    if a:0 < 1
        echoerr "tmpwin#open() requires at least one argument."
        return
    endif

    let [settings, commands] = type(a:1) == type({}) ?
                \ [a:1, a:000[1:]] : [s:DEFAULT_SETTINGS, a:000]

    let original_bufnr = bufnr('%')

    " do command in a temporary window
    let string_type = type('')
    for cmd in commands
        if type(cmd) == string_type
            call s:call(settings, 'open')
            execute cmd
            call add(s:opened_tmpbufs, bufnr('%'))
            call s:call(settings, 'open_post')
        endif
    endfor

    if original_bufnr == bufnr('%')
        echoerr "no new buffer has been opened."
        return
    endif

    let original_winnr = s:winnr_by_bufnr(original_bufnr)
    if original_winnr != -1 && ! get(settings, 'move_cursor', s:DEFAULT_SETTINGS['move_cursor'])
        " go back to original window
        execute original_winnr.'wincmd w'
    endif
endfunction

function! tmpwin#close()
    let original_bufnr = bufnr('%')
    call s:close_window_by_bufnrs(s:opened_tmpbufs)
    let s:opened_tmpbufs = []
    let original_winnr = s:winnr_by_bufnr(original_bufnr)
    if original_winnr != -1
        " go back to original window
        execute original_winnr.'wincmd w'
    endif
endfunction

function! tmpwin#exists()
    return s:find_winnr_like('index(s:opened_tmpbufs, winbufnr(winnr)) != -1')
                \ == -1 ? 0 : 1
endfunction

function! tmpwin#toggle(...)
    if ! tmpwin#exists()
        call call('tmpwin#open', a:000)
    else
        call tmpwin#close()
    endif
endfunction
" }}}
