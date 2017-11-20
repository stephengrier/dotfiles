syntax on
colo delek

set laststatus=2

" Pathogen
execute pathogen#infect()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
syntax on
filetype plugin indent on

" detect puppet filetype
"au BufRead,BufNewFile *.pp              set filetype=puppet

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Enable line numbering.
set number
nmap <C-N><C-N> :set invnumber

" Highlight anything beyond 80 chars.
highlight ColorColumn ctermbg=235
let &colorcolumn=join(range(81,999),",")

" Wrap after 80 chars.
set textwidth=80
" colorscheme darkblue 

" vim's default split behaviour opens top and left, change that.
set splitbelow
set splitright

" Turn on cursor line highlighting.
hi CursorLine cterm=NONE ctermbg=235 ctermfg=white guibg=darkred guifg=white
set cursorline

" The next 6 lines highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

vnoremap <C-X> <Esc>`.``gvP``P

