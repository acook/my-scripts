#!/bin/bash
# by Dennis Williamson
# 2010-10-06, revised 2010-11-10
# for http://stackoverflow.com/questions/3869072/test-for-non-zero-length-string-in-bash-n-var-or-var
# designed to fit an 80 character terminal

dw=5    # description column width
w=6     # table column width

t () { printf "%-${w}s" "true"; }
f () { [[ $? == 1 ]] && printf "%-${w}s" "false " || printf "%-${w}s" "-err- "; }

o=/dev/null

echo '       1a    2a    3a    4a    5a    6a    |1b    2b    3b    4b    5b    6b'
echo '       [     ["    [-n   [-n"  [-z   [-z"  |[[    [["   [[-n  [[-n" [[-z  [[-z"'

while read -r d t
do
    printf "%-${dw}s: " "$d"

    case $d in
        unset) unset t  ;;
        space) t=' '    ;;
    esac

    [ $t ]        2>$o  && t || f
    [ "$t" ]            && t || f
    [ -n $t ]     2>$o  && t || f
    [ -n "$t" ]         && t || f
    [ -z $t ]     2>$o  && t || f
    [ -z "$t" ]         && t || f
    echo -n "|"
    [[ $t ]]            && t || f
    [[ "$t" ]]          && t || f
    [[ -n $t ]]         && t || f
    [[ -n "$t" ]]       && t || f
    [[ -z $t ]]         && t || f
    [[ -z "$t" ]]       && t || f
    echo

done <<'EOF'
unset
null
space
zero    0
digit   1
char    c
hyphn   -z
two     a b
part    a -a
Tstr    -n a
Fsym    -h .
T=      1 = 1
F=      1 = 2
T!=     1 != 2
F!=     1 != 1
Teq     1 -eq 1
Feq     1 -eq 2
Tne     1 -ne 2
Fne     1 -ne 1
EOF
