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
   echo "     mguesser language maps directory (default: 'mguesser dir/maps')"
   echo "  -langs <lang1|...|langN>"
   echo "     narrows down the subset of guessed languages"
   echo "  -nlangs <n>"
   echo "     allows up to 'n' languages to be identified"
   echo "  -subs <sed's patterns>"
   echo "     translates detected languages to others"
   echo "  -raw"
   echo "     does not try to convert input to plain text"
   echo "  filename"
   echo "     filename (w/ extension) to help to determine the input file type"
   echo
   echo "Example: cat text.tex | $SCRIPT_NAME -path ~/bin/mguesser -langs 'en|ca|pt'"
   echo "             -nlangs 3 -subs 's/^en$/en_US/;s/^pt-br$|^pt-pt$/pt/;' text.tex"
   echo
   echo "This is free software. You may redistribute copies of it under the terms"
   echo "of the GNU General Public License <http://www.gnu.org/licenses/gpl.html>."
   echo "There is NO WARRANTY, to the extent permitted by law."
   echo ""
   echo "Written by Douglas Adriano Augusto (daaugusto)."

   exit 0
}

################################################################################
###                              Default values                              ###
################################################################################
# The path of 'mguesser' executable (http://www.mnogosearch.org/guesser/)
MG="$(which mguesser 2> /dev/null)"

# Path of the language maps
MGMAPS=""

# Restrict the guessing to a number of languages. Uses .* for all of them
LANGS=".*"

# Maximum number of guessed languages (comma separated, for instance, if
# NLANGS=2 this would be possible: ':set spelllang=en,pt')
NLANGS=1

# Translates mguesser languages to Vim spell files (sed syntax)
SUBS=""

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
[ -z "$FILE" ] && FILE="unnamed"

FT=""

TMP="`mktemp -d`"
FILE="$TMP/$FILE"

FILTER="cat "$FILE""

cat - > "$FILE"

# Find out the type of the file if the option '-raw' has not been specified
[ "$RAW" ] || FT="`file -b -i "$FILE" | awk '{print $1}' | tr -d ';'`"

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

# Guess the language (unfortunately tr (from coreutils) still seems to not fully support utf-8)
CMD="$FILTER 2>/dev/null | tr '[:punct:]' ' ' | tr -s '[:space:]' | tr -d -c '[:alpha:][:space:][àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ]' | "$MG" -d "$MGMAPS" - 2>/dev/null | awk '\$1 !~ /^0.00/ {print \$2}' | grep -E -w -m $NLANGS \"$LANGS\""

# Perform the substitutions if any
[ "$SUBS" ] && CMD="$CMD | sed -E '$SUBS'"

# Debugging
#echo "$CMD [-path $MG | -maps $MGMAPS | -langs $LANGS | -nlangs $NLANGS | -subs $SUBS | -raw $RAW]"

# Evaluate the command; remove possible duplicate languages; replace EOL with a comma
LANG=$(eval "$CMD" | awk '!a[$0]++' | paste -sd',')

# Output guessed language
echo "$LANG"

# Remove temporary files
rm -f "$FILE"
rmdir "$TMP"
