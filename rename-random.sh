#!/bin/bash
for i in *;do
	b=$(eval "printf $RANDOM|md5sum")
	b=${b%-}
	b=${b//[[:blank:]]/}
	mv -i -- "$i" "$b.${i##*.}"
done