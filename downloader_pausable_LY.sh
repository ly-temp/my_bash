#!/bin/bash
#bash input: $url, $max_int, $strg_file_dir p.s. max_int use 0 if no ;d
#strg file require terminating end!
#can only provide $strg_file_dir when resume

function dl_resource(){	#$url_template,$max_int,$line,$start_i
	for ((i=$4;i<=$2;i++))
	do
		url=$(echo "$1" | sed -e "s|;s|$3|g" -e "s|;d|$i|g")
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
		filename=$(basename "$filename")		
		echo -n "$filename"
		$(wget "$url" -q -O "$filename")
		if [ "$?" != 0 ]; then
			rm "$filename"
			echo "[E]"
		else
			echo "[S]"
		fi
		sed -i "4 s/.*/$i/" "$temp_file"
		[ -e "$pause_file" ] && exit			
	done
}

temp_file="temp.ly"
pause_file="../pause.ly"

if [ ! -f "$temp_file" ]; then
	printf "$1\n$2\n1\n0\n" > "$temp_file"
	url_template=$1
	max_int=$2
	current_strg_counter=1
	current_counter=0
else
	url_template=$(sed -n 1p "$temp_file")
	max_int=$(sed -n 2p "$temp_file")
	current_strg_counter=$(sed -n 3p "$temp_file")
	current_counter=$(sed -n 4p "$temp_file")
fi

$(mkdir -p download)
cd download
temp_file="../$temp_file"
if [ "$3" == "" ]; then
	dl_resource "$url_template" "$max_int" "$3" "$current_counter"
else
	strg_max_line=$(wc -l < "$3")
	for ((j=$current_strg_counter;j<=$strg_max_line;j++))
	do
		sed -i "3 s/.*/$j/" "$temp_file"
		line=$(sed -n "$j"p "$3")
		dl_resource "$url_template" "$max_int" "$line" "$current_counter"
		current_counter=0
	done
fi
