#!/bin/bash
#input $folder $sleep_time $token_file
while true;do
	date=$(env TZ=Asia/Hong_Kong date +"%d-%m-%y-%T")
	filename=$(basename "$1")"_${date}.tar"
	printf "\n$filename"
	tar -cf "$filename" "$1" --force-local
	web3storage_LY.sh "$filename" "$(cat $3)"
	rm "$filename"
	sleep "$2"
done