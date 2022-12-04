#!/bin/bash
for i in *; do
  b=$(eval "printf $RANDOM|md5sum")
  b=${b%-}
  b=${b//[[:blank:]]/}
  #echo $b
  mv -i -- "$i" "$b.${i##*.}"
done;