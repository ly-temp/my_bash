#!/bin/bash
a=1
for i in *;do
	mv -n -- "$i" "$a.${i##*.}"
	let a=a+1
done