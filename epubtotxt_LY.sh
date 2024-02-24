#!/bin/bash
#$epub
[ -z "$1" ] && exit
file=$(basename "$1")
folder="${file}.unzip"
if mkdir "$folder";then
	unzip -q "$1" -d "$folder"
	cd "$folder"	#at book root now
#force search mode
	#list=$(find . -type f -name "*.*ml" |sort -V)
#follow format
	opf=$(grep -oE 'full-path="[^"]+"' "META-INF/container.xml" |cut -d'"' -f2)
	title=$(grep -m1 "title" "$opf" |grep -Eo ">[^<]+<" |tr -d '<,>,/' |sed -E -e "s/^\s+//" -e "s/\s+$//")
	txt_name="../${title}.txt"
	>"$txt_name"
	[ -z "$txt_name" ] && txt_name="${file%.epub}.txt"
	bk_dir=$(dirname "$opf")
	list=$(grep -zo "< *manifest *>.*< */ *manifest *>" "$opf" |grep -Eoa "href *= *\"[^\"]+\"" |cut -d'"' -f2 |grep "\..*ml$")
	while read -r line;do
		sed -E -e "s|< *br */? *>|\n|g" -e "s/<[^<>]+>//g" < "${bk_dir}/${line}" >> "$txt_name"
	done <<< "$list"
#move image
	image_folder="../${title}.image"
	pwd
	if mkdir "$image_folder";then
		find . -exec file {} \; |grep -Po "^.+: \w+ image" |cut -d':' -f1 |xargs -I {} mv --backup=t {} "$image_folder"
	fi
	cd ../
	rm -r "$folder"
fi