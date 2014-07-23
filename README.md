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
   map <F6> :.SpellLangIdentify setlocal spell<CR>:set spl<CR> " current line based
   map <F7> :'{,'}SpellLangIdentify setlocal spell<CR>:set spl<CR> " current paragraph based
   map <F8> :%SpellLangIdentify setlocal spell<CR>:set spl<CR> " whole buffer based
   map <F9> :setlocal nospell<CR> " turn off spell checking

   " insert mode
   imap <F6> <C-\><C-O>:.SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
   imap <F7> <C-\><C-O>:'{,'}SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
   imap <F8> <C-\><C-O>:%SpellLangIdentify setlocal spell<CR><C-\><C-O>:set spl<CR>
   imap <F9> <C-\><C-O>:setlocal nospell<CR>

   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Settings example:
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   let g:sliPath = "-path ~/.vim/plugin/mguesser/mguesser"   " executable's path
   "let g:sliMaps = "-maps ..."   " set this path if the language maps are installed elsewhere
   let g:sliSubs = "-subs 's/pt-br|pt-pt/pt/;s/ca/en/'"   " converts mguesser's pt-br or pt-pt to pt; and ca to en
   let g:sliLangs = "-langs 'en|pt'"   " after conversion, ignores all lang but en (includes ca) and pt (pt-br and pt-pt)
   let g:sliNLangs = "-nlangs 1"   " only one language can be guessed at a time
   "leg g:sliRaw = "-raw"   " if enabled it does not try to convert to plain text

   " Default mguesser's language code list:
   "    af ar az be bg br bs ca cs cy da de el en eo eo-h eo-x es et eu fi fr ga
   "    he hi hr hu hy is it ja la lt lv nl no pl pt-br pt-pt ro ru sk sl sq sr sv
   "    sw ta th tl tr ua vi zh

   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Autocmd examples (language identification & spelling based on file types):
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   " Detects document's language and sets spell checking when reading a .txt file:
   autocmd BufRead *.txt SpellLangIdentify setlocal spell

   " Identifies current paragraph's language and sets the spell checking whenever
   " leaving insert mode:
   autocmd InsertLeave *.txt '{,'}SpellLangIdentify setlocal spell

   " Another way of configuring SpellLangIdentifier based on the file type:
   " As illustrated below, when the filetype is 'mail' or 'tex' two things happen:
   "   1) Identification of the buffer's language, turning on spell checking; and
   "   2) Telling to (re)identify the language, based on the current paragraph,
   "      whenever the user leaves the insert mode.
   aug LangIdentify
      au FileType mail,tex SpellLangIdentify setl spell | :au! LangIdentify InsertLeave <buffer> '{,'}SpellLangIdentify setl spell
   aug END
```


Usage
-----

   1. Automatically (just open a text, mail or TeX file as defined above)
   2. Using shortcuts in normal or insert mode (F6, F7, and F8; F9 to disable spell checking)
   3. Directly: `:{range}SpellLangIdentify` (identify the language based on `{range}` lines; default is the whole buffer)


Notes
-----

The user can create its own reference language set ("maps") which will
guide/bias the language identification. An example would be to create an n-gram
frequency file (a map) for words related to the medical literature or, perhaps,
to some subset of the English language. Please check out mguesser's
documentation for that.


Prerequisites
-------------

   * Unix-like environment (POSIX shell, coreutils, awk, sed, grep, file, ...).
