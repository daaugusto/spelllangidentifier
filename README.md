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

Please, check out the sample Vim configuration file `vimrc.sli`. You can
introduce your changes there and *source* it directly from your personal
*vimrc* by inserting the line `source /path/to/vimrc.sli`.


Usage
-----

   1. Automatically (just open a text, mail or TeX file, as illustrated in `vimrc.sli`). It even works on-the-fly while you edit the file, switching the languages on a paragraph basis when working on multi-language documents (configurable).
   2. Using shortcuts in normal or insert mode (`F6`, `F7`, and `F8`; `F9` to disable spell checking).
   3. Directly: `:{range}SpellLangIdentify` (identify the language based on `{range}` lines; default is the whole buffer).


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
