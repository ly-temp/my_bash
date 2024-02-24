#!/bin/bash
#$epub
function extract_purge_txt(){
	grep -Eo ">[^<]+<" |tr -d '<,>,/' |sed -E -e "s/^\s+//" -e "s/\s+$//"
}

[ -z "$1" ] || [ "${1##*.}" != "epub" ] && exit
file_realpath=$(realpath "$1")
file_realdir=$(dirname "$file_realpath")
file=$(basename "$1")
folder="${file}.unzip"
if mkdir "$folder";then
	unzip -q "$1" -d "$folder"
	cd "$folder"	#at book root now
#follow format
	opf=$(grep -oE 'full-path="[^"]+"' "META-INF/container.xml" |cut -d\" -f2)
	title=$(grep -m1 "title" "$opf" |extract_purge_txt)
	aut=$(grep -m1 "creator" "$opf" |extract_purge_txt)
	new_name="${title} - ${aut}.epub"
	#new_name=$(cut -d '\r','\n' <<< "$new_name")
	#mv --backup=numbered "$(realpath $1)" "$new_name"
	mv --backup=numbered "$file_realpath" "${file_realdir}/${new_name}"
	cd ../
	rm -r "$folder"
fi