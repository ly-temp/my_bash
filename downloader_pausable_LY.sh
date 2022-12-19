#!/bin/bash
#bash input: $url, $start_int, $max_int, $strg_file_dir p.s. max_int use 0 if no ;d
#strg file require terminating end!
#can only provide $strg_file_dir when resume
#sed "s/#>/>/g"->log

function dl_resource(){	#$url_template,$max_int,$line,$start_i,$current_strg_counter
	for ((i=$4;i<=$2;i++))
	do
		url=$(echo "$1" | sed -e "s|;s|$3|g" -e "s|;d|$i|g")
		#echo "$url"
		if [ "$3" == "" ]; then
			filename="$i"
		else
			purged_line=$(basename "$3")
			if [ "$2" == 0 ]; then
				filename="$purged_line"
			else
				filename="$i-$purged_line"
			fi
		fi

		#filename=$(basename "$filename")
		echo -n "$filename" #>>../log.txt
		$(wget "$url" -q -O "$filename")
		if [ "$?" != 0 ]; then
			rm "$filename"
			echo "[E]" #>>../log.txt
		else
			echo "[S]" #>>../log.txt
		fi
		sed -i -e "4 s/.*/$5/" -e "5 s/.*/$i/" "$temp_file"
		[ -e "$pause_file" ] && exit
	done
}

temp_file="temp.ly"
pause_file="../pause.ly"

if [ ! -f "$temp_file" ]; then
	printf "$1\n$2\n$3\n1\n$2\n" > "$temp_file"
fi

url_template=$(sed -n 1p "$temp_file")
min_int=$(sed -n 2p "$temp_file")
max_int=$(sed -n 3p "$temp_file")
current_strg_counter=$(sed -n 4p "$temp_file")
current_counter=$(sed -n 5p "$temp_file")

$(mkdir -p download)
cd download
temp_file="../$temp_file"
if [ "$4" == "" ]; then
	dl_resource "$url_template" "$max_int" "" "$current_counter" "$current_strg_counter"
else
	strg_max_line=$(wc -l < "../$4")
	for ((j=$current_strg_counter;j<=$strg_max_line;j++))
	do
		#sed -i "4 s/.*/$j/" "$temp_file"
		line=$(sed -n "$j"p "../$4")
		dl_resource "$url_template" "$max_int" "$line" "$current_counter" "$j" #|tee -a log.txt
		current_counter=$min_int
	done
fi
