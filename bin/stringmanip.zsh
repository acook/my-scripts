command="grep \"foo\" -C 2"

#array=("${(w):-$command}")

array=${${(z)command}[2,-1]}

echo $array

empty=""

echo ${empty:-nil}
