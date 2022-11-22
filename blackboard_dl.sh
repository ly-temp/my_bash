#!/bin/bash
#$html $cookie
cookie=$(sed -E "s|-H '[^']+'|&\n|g" "$2" | awk -F\' '{print $(NF-1)}')
echo "$cookie" > "$2"

html=$(realpath "$1")
list=$(scan_html_LY.sh "file://$html" | grep pid | sed "s|file://|https://blackboard.cuhk.edu.hk|g" )
echo "$cookie"
for url in $list;do
	curl -L "$url" -H @"$2" -O -J
done
