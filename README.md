spelllangidentifier
===================

*Vim plugin to automatically identify and set the spell language*

It detects the language based on the buffer contents through 'mguesser'
(http://www.mnogosearch.org/guesser/), which in turn uses "N-Gram-Based Text
Categorization".

Installation
------------

```
   cp -r SpellLangIdentifier.vim LanguageIdentifier.sh mguesser ~/.vim/plugin
   cd ~/.vim/plugin/mguesser && make
```


Configuration (~/.vimrc)
------------------------

```
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Recommended mappings:
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " normal mode
   map <F6> :.SpellLangIdentify setlocal spell<CR>:set spl<CR>
   map <F7> :'{,'}SpellLangIdentify setlocal spell<CR>:set spl<CR>
   map <F8> :%SpellLangIdentify setlocal spell<CR>:set spl<CR>

   " insert mode
   imap <F6> <C-\><C-O>:.SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
   imap <F7> <C-\><C-O>:'{,'}SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
   imap <F8> <C-\><C-O>:%SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>

   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Settings example:
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   let g:sliPath = "-path ~/.vim/plugin/mguesser/mguesser"
   "let g:sliMaps = "-maps ..."
   let g:sliLangs = "-langs 'en|pt'"
   let g:sliNLangs = "-nlangs 1"
   let g:sliSubs = "-subs 's/^pt-br$|^pt-pt$/pt/;'"
   "leg g:sliRaw = "-raw"

   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Autocmd examples (language identification & spelling based on file types):
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Detects document's language and sets spell checking when
   " reading a .txt or .tex file
   autocmd BufRead *.{txt,tex} SpellLangIdentify setlocal spell

   " Identifies current paragraph's language and sets the spell
   " checking whenever leaving insert mode
   autocmd InsertLeave *.{txt,tex} '{,'}SpellLangIdentify setlocal spell
```


Usage
-----

   1. Automatically (just open a text or TeX file as defined above)
   2. Using shortcuts in normal or insert mode (F6, F7, F8)
   3. Directly: `:{range}SpellLangIdentify` (identify the language based on `{range}` lines; default is the whole buffer)


Prerequisites
-------------

   * Unix-like environment (POSIX shell, coreutils, awk, cat, sed, grep, printf, paste, tr, file, which, basename, dirname, mktemp, rm, rmdir, ...).


Known limitations
-----------------

   * Currently support for unicode is limited due to *coreutils* not being fully compatible with UTF-8 yet.
