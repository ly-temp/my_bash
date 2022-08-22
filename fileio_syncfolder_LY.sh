#!/bin/bash
#input $folder $sleep_time $webhook
#webhook will append url directly i.e. no '/|?'
while true;do
	date=$(env TZ=Asia/Hong_Kong date +"%d-%m-%y-%T")
	filename=$(basename "$1")"_${date}.tar"
	printf "\n$filename => "
	tar -cf "$filename" "$1" --force-local
	url=$(./fileio.sh "$filename")
	echo "$url"
	wget -O /dev/null -o /dev/null "$3$url"
	rm "$filename"
	sleep "$2"
done