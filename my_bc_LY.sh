#!/bin/bash
#my_bc
	#pipline input: a -+ b
	#bash bc for simple add / subtraction

	function break_float(){
		if grep -q '\.' <<< "$1";then
			sed -e "s/\./ /g" <<< "$1"
		else
			echo "$1 0"
		fi
	}

read string
sign=$(cut -d' ' -f2 <<< "$string")
a=$(cut -d' ' -f1 <<< "$string")
b=$(cut -d' ' -f3 <<< "$string")
read -r a_int a_float <<< $(break_float "$a")
read -r b_int b_float <<< $(break_float "$b")
#echo "$a_int	$b_int"
#echo "$a_float	$b_float"

[ "$sign" = "-" ] && b_int="-$b_int" && b_float="-$b_float"
float_sum=".$(($a_float+$b_float))"
[ "$float_sum" = ".0" ] && float_sum=""
echo "$(($a_int+$b_int))$float_sum"

#end of my_bc