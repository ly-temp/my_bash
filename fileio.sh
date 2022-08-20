#!/bin/bash
#$filename
	curl -s -X 'POST' \
	  'https://file.io/' \
	  -H 'accept: application/json' \
	  -H 'Content-Type: multipart/form-data' \
	  -F "file=@$1" \
	| grep -Eo '"link":"[^"]+"' | awk -F '"' '{print $(NF-1)}'
