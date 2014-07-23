" ==============================================================================
"         File: SpellLangIdentifier.vim
"
"      Summary: Automatically identify buffer's language and set the spell lang
"
"  Description: Automatically identify buffer's language and set the spell lang
"               It detects the language based on the buffer contents through
"               'mguesser' (http://www.mnogosearch.org/guesser/)
"
"       Author: Douglas A. Augusto (daaugusto@gmail.com)
"
"      Version: 0.1.0
"
"  Last change: July 20, 2014
"
"      License: GNU GPL version 3 or later <www.gnu.org/licenses/gpl.html>
"
"          URL: http://www.vim.org/scripts/script.php?script_id=4988
"
" Installation: Copy the plug-in (SpellLangIdentifier.vim) and the accompanying
"               script (LanguageIdentifier.sh) files into Vim's plug-in directory
"               (usually $HOME/.vim/plugin/ or something like that)
"
"               mguesser needs to be installed (http://www.mnogosearch.org/guesser/)
"               and reachable through $PATH (or its path configured by variables
"               g:sliPath (mguesser's executable) and g:sliMaps (language maps)
"
"               It is recommended to put mguesser executable inside the directory
"               $HOME/.vim/plugin/mguesser/ and the mappings into
"               $HOME/.vim/plugin/mguesser/maps/
"
"        Usage:
"
"           1) Calling the language identifier command directly:
"              :{range}SpellLangIdentify   " identify the language based on
"                                          " {range} lines (default is the whole buffer)
"
"           2) Via auto commands and mappings (.vimrc):
"
"              " Detects document's language and sets spell checking when
"                reading a .tex file
"              autocmd BufRead *.tex SpellLangIdentify setlocal spell
"
"              " Identifies current paragraph's language and sets the spell
"                checking whenever leaving insert mode
"              autocmd InsertLeave *.tex '{,'}SpellLangIdentify setlocal spell
"
"              Recommended mappings:
"                 " normal mode
"                 map <F6> :.SpellLangIdentify setlocal spell<CR>:set spl<CR>
"                 map <F7> :'{,'}SpellLangIdentify setlocal spell<CR>:set spl<CR>
"                 map <F8> :%SpellLangIdentify setlocal spell<CR>:set spl<CR>
"                 " insert mode
"                 imap <F6> <C-\><C-O>:.SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
"                 imap <F7> <C-\><C-O>:'{,'}SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
"                 imap <F8> <C-\><C-O>:%SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
"
"              Settings example:
"                 let g:sliPath = "-path ~/.vim/plugin/mguesser/mguesser"
"                 "let g:sliMaps = "-maps ..."
"                 let g:sliLangs = "-langs 'en|pt'"
"                 let g:sliNLangs = "1"
"                 let g:sliSubs = "-subs 's/^pt-br$|^pt-pt$/pt/;'"
"                 "leg g:sliRaw = "-raw"

" ==============================================================================
" Has this plugin already been loaded?
if exists('g:SpellLangIdentifier')
   finish
endif
let g:SpellLangIdentifier = 1

" ==============================================================================
" Parameters (can be changed by the user via .vimrc or within a Vim session)
" ------------------------------------------------------------------------------
if !exists('g:sliScriptPath')
   " ~/.vim/plugin/LanguageIdentifier.sh
   let s:sliScriptPath = expand('<sfile>:p:h') . "/LanguageIdentifier.sh"
endif
if !exists('g:sliPath')
   let g:sliPath = ""
endif
if !exists('g:sliMaps')
   let g:sliMaps = ""
endif
if !exists('g:sliLangs')
   let g:sliLangs = ""
endif
if !exists('g:sliNLangs')
   let g:sliNLangs = ""
endif
if !exists('g:sliSubs')
   let g:sliSubs = ""
endif
if !exists('g:sliRaw')
   let g:sliRaw = ""
endif

" Save the cursor position, run the external script and restore the cursor position
command! -range=% -nargs=* SpellLangIdentify let pos = getpos('.') | <line1>,<line2>call <SID>SpellLangIdentify(<q-args>) | call setpos('.',pos)

" 'cmd' is the command string that is executed if a language is identified
function! <SID>SpellLangIdentify( cmd ) range
   " Get the lines of the selected range
   let lines = getline(a:firstline,a:lastline)
   " Convert a list of lines to a string of lines
   let input = join(lines, "\n") . "\n"
   " Run the command and execute its output
   let lang = system(s:sliScriptPath . " " . g:sliPath . " " . g:sliMaps . " " . g:sliLangs . " " . g:sliNLangs . " " . g:sliSubs . " " . g:sliRaw . " " . shellescape(expand('%:t')), input)

   if len(lang) > 1
      silent execute ":setlocal spelllang=" . lang
      execute a:cmd
      "set spelllang
   else
      " If input length is 0 (counting only useful data) then the identification
      " has failed because there is not enough information. But when the length
      " is greater then zero probably an error has occurred.
      let input = substitute(input,'[^[:alpha:]]','','g')
      if strlen(input) > 0
         echo "[SpellLangIdentifier] Unable to automatically identify text's language."
      endif
   endif
endfunction
