#!/bin/sh

# LanguageIdentifier - Automatically identify text's language
#
# Copyright (C) 2014  Douglas A. Augusto (daaugusto@gmail.com)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

usage()
{
   SCRIPT_NAME=`basename $0`
   echo
   echo "LanguageIdentifier - Automatically identify text's language"
   echo
   echo "Usage: ... | $SCRIPT_NAME [-path <mguesser path>] [-maps <lang maps dir>]"
   echo "             [-langs <lang1|...|langN>] [-nlangs <n>]"
   echo "             [-subs <sed's patterns>] [-raw] [filename]"
   echo
   echo "where:"
   echo
   echo "  -path <mguesser path>"
   echo "     mguesser executable path (see http://www.mnogosearch.org/guesser/)"
   echo "  -maps <lang maps dir>"
   echo "     mguesser language maps directory (default: 'mguesser_dir/maps')"
   echo "  -langs <lang1|...|langN>"
   echo "     narrows down the subset of guessed languages"
   echo "  -nlangs <n>"
   echo "     allows up to 'n' languages to be identified (multiple spell langs)"
   echo "  -subs <sed's patterns>"
   echo "     translates mguesser language codes to others"
   echo "  -raw"
   echo "     does not try to convert input to plain text (letters only)"
   echo "  filename"
   echo "     filename (w/ extension) to help to determine the input file type"
   echo
   echo "Example: cat text.tex | $SCRIPT_NAME -path ~/bin/mguesser -langs 'en_US|ca|pt'"
   echo "             -nlangs 3 -subs 's/^en$/en_US/;s/^pt-br$|^pt-pt$/pt/;' text.tex"
   echo
   echo "This is free software. You may redistribute copies of it under the terms"
   echo "of the GNU General Public License <http://www.gnu.org/licenses/gpl.html>."
   echo "There is NO WARRANTY, to the extent permitted by law."
   echo ""
   echo "Written by Douglas A. Augusto (daaugusto)."

   exit 0
}

################################################################################
###                              Default values                              ###
################################################################################
# The path of 'mguesser' executable (http://www.mnogosearch.org/guesser/)
MG="$(which mguesser 2> /dev/null)"

# Path of the language maps
MGMAPS=""

# Restrict the guessing to a number of languages (it operates on the processed
# list of languages, i.e., after the substitutions are applied (see below)).
LANGS=".*"   # .* allows all of them

# Maximum number of guessed languages (comma separated, for instance, if
# NLANGS=2 this would be possible: ':set spelllang=en,pt')
NLANGS=1

# Translates mguesser languages to Vim spell files (sed syntax)
#
# Current mguesser's language list (the user can build others; see mguesser docs):
#    af ar az be bg br bs ca cs cy da de el en eo eo-h eo-x es et eu fi fr ga
#    he hi hr hu hy is it ja la lt lv nl no pl pt-br pt-pt ro ru sk sl sq sr sv
#    sw ta th tl tr ua vi zh
SUBS=":"   # sed ':' does nothing (same as cat)

# Whether to pass the contents to mguesses as is
RAW=""

FILE=""

while [ $# -ge 1 ]; do
   case $1 in
      -path)     shift; MG="$1" ;;
      -maps)     shift; MGMAPS="$1" ;;
      -langs)    shift; LANGS="$1" ;;
      -nlangs)   shift; NLANGS="$1" ;;
      -subs)     shift; SUBS="$1" ;;
      -raw)      RAW="1" ;;
      -h|--help) usage ;;
      *)         FILE="$1" ;;
   esac
   shift
done
################################################################################

# Try to guess the mguesser's maps directory
[ -z "$MGMAPS" ] && MGMAPS="$(dirname "$MG")/maps"


TMP="`mktemp -d`"
[ -z "$FILE" ] && FILE="unnamed"
FILE="$TMP/$FILE"

FILTER="cat "$FILE""   # does nothing

# Save the input to the temporary file
cat - > "$FILE"

# Find out the type of the file if the option '-raw' has not been specified
FT=""
[ "$RAW" ] || FT="`file --mime-type -b "$FILE"`"

# Transform (try to) non-plain text files to plain text:
case $FT in
   "text/x-tex")
      if type detex > /dev/null 2>&1; then FILTER="detex "$FILE""; fi ;;
   "application/postscript")
      if type ps2ascii > /dev/null 2>&1; then FILTER="ps2ascii "$FILE""; fi ;;
   "text/html")
      if type html2text > /dev/null 2>&1; then FILTER="html2text "$FILE""; fi ;;
   "message/rfc822")
      FILTER="sed '1,/^$/d' "$FILE""
      if type html2text > /dev/null 2>&1; then FILTER="$FILTER | html2text"; fi ;;
esac

# Guess the language:
#  1) the filter that converts the raw input to plain text is applied (if -raw isn't specified)
#  2) all punctuation chars are transformed into single spaces, which are then squeezed and
#     all characters that are not letters or spaces are deleted.
#  3) the resulting content are then given to 'mguesser'
CMD="$FILTER 2>/dev/null | tr -d '[:digit:][:cntrl:]' | tr '[:punct:][:space:]' ' ' | tr -s ' ' | "$MG" -d "$MGMAPS" - 2>/dev/null"

# Evaluate the assembled command and check if it has succeeded
OUT="`eval "$CMD" 2>/dev/null`"

if [ "$?" = "0" ]
then
   # Print the command output (scores and languages) | ignore zero-score
   # guessings | perform the substitutions (if any)| remove possible duplicate
   # languages | filter out undesired languages (matches whole line) | replace
   # EOL with comma
   LANG="$(printf "%s\n" "$OUT" | awk '$1 !~ /^0.000/ {print $2}' | sed -E "$SUBS" | awk '!a[$0]++' | grep -E -x -m $NLANGS "$LANGS" | paste -sd',')"

   # Output guessed language (empty if it could not identify)
   printf "%s" "$LANG"
else
   printf "ERROR"

   # Debugging (uncomment for debugging)
   #echo "$CMD [-path $MG | -maps $MGMAPS | -langs $LANGS | -nlangs $NLANGS | -subs $SUBS | -raw $RAW]"
   #printf "%s\n" "$OUT"
fi

# Remove temporary files
rm -f -- "$FILE"
rmdir "$TMP"
