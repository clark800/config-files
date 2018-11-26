set encoding=utf-8          " use utf-8 encoding
set tabstop=4               " render space characters as 4 spaces
set softtabstop=4           " backspace erases all spaces to next tab stop
set shiftwidth=4            " use 4 spaces for each step of (auto)indent
set expandtab               " expand <Tab> keypresses to spaces
set scrolloff=10            " show 10 lines of context around cursor
set colorcolumn=81          " color column 81
set wildmenu
set path+=**
set completeopt=menu

" set color of autocomplete popup menu
highlight Pmenu ctermbg=238

" http://vimdoc.sourceforge.net/htmldoc/options.html#'viminfo'
set viminfo='20,<1000       " remember marks for previous 20 files;
                            " save max of 1000 lines for each region

syntax on                   " enable syntax highlighting
filetype plugin indent on   " enable filetype plugins and indentation rules

function IndentedBlockFoldExpr(line_number)
    let current_indent = indent(a:line_number) / &shiftwidth
    let next_indent = indent(a:line_number + 1) / &shiftwidth
    if getline(a:line_number) =~ '\v^\s*$'
        return -1
    endif
    if getline(a:line_number + 1) =~ '\v^\s*$'
        return current_indent
    endif
    if next_indent > current_indent
        return ">" . next_indent
    elseif next_indent < current_indent
        return "<" . current_indent
    else
        return current_indent
    endif
endfunction

function IndentedBlockFoldText(fold_start)
    return getline(a:fold_start) . " …"
endfunction

function ToggleFold()
    if foldclosed(line('.')) >= 0
        silent! normal zv
    else
        silent! normal za
    endif
endfunction

function SetIndentedBlockFolding()
    setlocal foldmethod=expr
    setlocal foldexpr=IndentedBlockFoldExpr(v:lnum)
    setlocal foldtext=IndentedBlockFoldText(v:foldstart)
    setlocal fillchars=fold:\    " escaped space
    highlight Folded ctermfg=NONE ctermbg=NONE
    nnoremap <buffer> <silent> <tab> :<c-u>call ToggleFold()<cr>
endfunction

autocmd BufRead,BufNewFile *.todo call SetIndentedBlockFolding()

" http://vim.wikia.com/wiki/Smart_mapping_for_tab_completion
function! CleverTab()
    if pumvisible()
        return "\<C-N>"
    endif
        if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
        return "\<Tab>"
    elseif exists('&omnifunc') && &omnifunc != ''
        return "\<C-X>\<C-O>"
    else
        return "\<C-N>"
    endif
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" highlight column 81
highlight ColorColumn ctermbg=236 guibg=#303030

" highlight tabs
autocmd BufNewFile,BufReadPost,FileReadPost * syntax match Tab "\t"
highlight Tab ctermbg=238 guibg=#444444

" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" update tags file after writes
autocmd BufWritePost *.c,*.h,*.zero silent! !ctags -R --quiet &

" map Ctrl-Arrow keys
map <ESC>[1;5A <C-Up>
map <ESC>[1;5B <C-Down>
map <ESC>[1;5C <C-Right>
map <ESC>[1;5D <C-Left>
