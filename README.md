```vim
" Quick look setting example for TweetVim
let g:TmpWinTweetVimSetting = {}
function! g:TmpWinTweetVimSetting.open_post()
    normal! gg
endfunction
nnoremap <silent><Leader>tt :<C-u>call tmpwin#toggle(g:TmpWinTweetVimSetting, 'TweetVimHomeTimeline')<CR>
```
