#!/bin/bash
#$html $cookie
function urldecode(){
	sed 's@+@ @g;s@%@\\x@g'| xargs -0 printf "%b"
}

extract_cookie_LY.sh "$2"

mkdir -p dl
html=$(realpath "$1")
list=$(scan_html_LY.sh "file://$html" | grep pid | sed "s|file://|https://blackboard.cuhk.edu.hk|g" )
for url in $list;do
	filename=$(curl -sLI "$url" -H @"$2" | grep "content-disposition:" | tr -d '\r','\n' | awk -F\' '{print $NF}'| urldecode )
	#curl -sL "$url" -H @"$2" -OJ -D- | grep content-disposition | awk -F\' '{print $NF}'
	curl -sL "$url" -H @"$2" -o "dl/$filename"
done
