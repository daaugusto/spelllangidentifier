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
"      License: GNU GPL version 3 or later <www.gnu.org/licenses/gpl.html>
"
"          URL: http://www.vim.org/scripts/script.php?script_id=4988
"
"  Installation
"      & Usage: Please see README file
"

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
"if !exists('g:sliFiletype')
"   let g:sliFiletype = ""
"endif

" ID/count of the last buffer change
" b:changedtick seems to start with 3 when creating/reading a named file So,
" assigning 3 here means that when a buffer is read (opened) HasChanged() ->
" false; assigning a value different than 3 (like 0) means that HasChanged() ->
" true when the buffer is opened.
let s:sliLastChangeID = 3

" Save the cursor position, run the external script and restore the cursor position
command! -range=% -nargs=* -bar SpellLangIdentify let pos = getpos('.') | <line1>,<line2>call <SID>SpellLangIdentify(<q-args>) | call setpos('.',pos)

" Only perform the language identification if the buffer has changed
command! -range=% -nargs=* -bar SpellLangIdentifyLazy if <SID>HasChanged() | let pos = getpos('.') | <line1>,<line2>call <SID>SpellLangIdentify(<q-args>) | call setpos('.',pos)

" Check whether the buffer has been changed since the last time
" A lazier approach would be to use changenr() instead of b:changedtick,
" which does not account for individual changes, but rather change sets (like undo)
function! <SID>HasChanged()
   if s:sliLastChangeID != b:changedtick
      let s:sliLastChangeID = b:changedtick
      "echo "Buffer has changed " . b:changedtick . "/" . changenr() . " times so far."
      return 1
   else
      return 0
   endif
endfunction

" 'cmd' is the command string that is executed if a language is identified
function! <SID>SpellLangIdentify( cmd ) range
   " Get the lines of the selected range
   let lines = getline(a:firstline,a:lastline)
   " Convert a list of lines to a string of lines
   let input = join(lines, "\n") . "\n"

   " Decide how to pass the file type to the script (LanguageIdentifier.sh)
   if exists('g:sliFiletype')
      let type = g:sliFiletype
   else
      let type = &filetype
   endif

   " Run the command and execute its output
   silent let lang = system(s:sliScriptPath . " " . g:sliPath . " " . g:sliMaps . " " . g:sliLangs . " " . g:sliNLangs . " " . g:sliSubs . " " . "-type " . string(type) . " " . shellescape(expand('%:t')), input)

   if v:shell_error
      echoe "[SpellLangIdentifier] An error has occurred while trying to run script '" . s:sliScriptPath . "'!"
   elseif !empty(lang) " If input length is 0 then the identification has failed because there is not enough information (soft error).
      if lang != "ERROR"
         " Set the spell language(s) based on the guessing
         silent execute ":setlocal spelllang=" . lang . "\n"
         " Execute the user given arguments now the language is identified
         execute a:cmd

         "set spelllang
      else " hard error
         echoe "[SpellLangIdentifier] An error has occurred while running 'mguesser'!"
      endif
   endif
endfunction
