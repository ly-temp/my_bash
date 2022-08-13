#!/bin/bash
#bash input: $url, $max_int, $strg_file_dir p.s. max_int use 0 if no ;d

function dl_resource(){	#$url,$int,$line
	for ((i=0;i<=$2;i++))
	do
		url=$(echo "$1" | sed "s/;s/$3/g")
		url=$(echo "$url" | sed "s/;d/$i/g")
		#echo "$url"
		if [ "$3" == "" ]; then
			filename="$i"
		else
			if [ "$2" == 0 ]; then
				filename="$3"
			else
				filename="$i-$3"
			fi
		fi
		echo -n "$filename"
		$(wget "$url" -q -O "$filename")
		if [ "$?" != 0 ]; then
			rm "$filename"
			echo "[E]"
		else
			echo "[S]"
		fi
	done
}

$(mkdir -p download)
cd download
if [ "$3" == "" ]; then
	dl_resource "$1" "$2" "$3"
else
	while IFS= read -r line
	do
		dl_resource "$1" "$2" "$line"
	done < "$3"
fi
