#!/bin/bash
f=$1
i=1
while [ -f "$f" ]||[ -d "$f" ];do
	f="$1".~$i~
	((i++))
done
echo -n "$f"