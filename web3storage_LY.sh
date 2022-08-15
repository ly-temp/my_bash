#!/bin/bash
#input $file_dir $token_file
token="$2"
file=$1
name=$(basename "$file")
curl -X POST --url "https://api.web3.storage/upload" \
-H "Authorization:Bearer $token" \
-H "X-NAME:$name" \
--data-binary "@$file"
#get: https://[cid].ipfs.dweb.link