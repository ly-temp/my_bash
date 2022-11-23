#!/bin/bash
#$html $cookie
extract_cookie_LY.sh "$2"

html=$(realpath "$1")
list=$(scan_html_LY.sh "file://$html" | grep pid | sed "s|file://|https://blackboard.cuhk.edu.hk|g" )
for url in $list;do
	curl -sL "$url" -H @"$2" -O -J
done
