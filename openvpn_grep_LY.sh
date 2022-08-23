#!/bin/bash
#$openvpn_file
function grep_tag(){ #$tag #file
	grep -zEo "<$1>[^<>]+</$1>" "$2" > "$1".pem
}
grep_tag "cert" "$1"
grep_tag "ca" "$1"
grep_tag "key" "$1"
grep -E "^remote" "$1" | cut -d' ' -f2- | sed "s/ /:/g" > config
grep -E "^cipher" "$1" >> config
grep -E "^auth" "$1" >> config

