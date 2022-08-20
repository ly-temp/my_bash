#!/bin/bash
#input $folder $sleep_time $webhook
function file_io(){	#$filename
	curl -s -X 'POST' \
	  'https://file.io/' \
	  -H 'accept: application/json' \
	  -H 'Content-Type: multipart/form-data' \
	  -F "file=@$1" \
	| grep -Eo '"link":"[^"]+"' | awk -F '"' '{print $(NF-1)}'
}
while true;do
	date=$(env TZ=Asia/Hong_Kong date +"%d-%m-%y-%T")
	filename=$(basename "$1")"_${date}.tar"
	printf "\n$filename"
	tar -cf "$filename" "$1" --force-local
	url=$(file_io "$filename")
	wget -O /dev/null -o /dev/null "https://url-log.laiyuantemp.workers.dev/add/$url"
	rm "$filename"
	sleep "$2"
done