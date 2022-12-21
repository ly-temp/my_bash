#!/bin/bash
#bash input: $url, $start_int, $max_int, $is_numbering, $strg_file_dir p.s. max_int use 0 if no ;d
#strg file require terminating end!
#can only provide $strg_file_dir when resume
#sed "s/#>/>/g"->log

temp_file="temp.ly"
pause_file="../pause.ly"
lock_suffix=".lock.ly"

function urldecode(){
	sed 's@+@ @g;s@%@\\x@g'| xargs -0 printf "%b"
}

function valid_filename(){	#$filename
	f=$(basename -- "$1") 	#purge filename
	extension=".${f##*.}"
	name="${f%.*}"
	count=1
	while [ -f "$f" ] && [ ! -f "$f$lock_suffix" ]; do	#break if locked
		f="$name"."$count$extension"
		count=$((count+1))
	done
	touch "$f$lock_suffix"	#make lock file
	printf "$f"
}

function strip_space(){
	sed -Ee "s/^[ ]+//g" -Ee "s/[ ]+$//g"
}

function grep_content_disposition(){	#$response headers
	dispos=$(grep -i "content-disposition:" <<< "$1")
	utf_8_dispos=$(grep -iEo "filename\*[^=]?+=[^;]+" <<< "$dispos" | tail -n1 | awk -F\' '{print $NF}' | tr -d '\r','\n' | urldecode )
	normal_dispos=$(grep -iEo "filename[^=*]?+=[^;]+" <<< "$dispos" | tail -n1 | awk -F\" '{print $(NF-1)}' | tr -d '\r','\n' | urldecode )
	[ "$utf_8_dispos" != "" ] && choosen_dispos="$utf_8_dispos" || choosen_dispos="$normal_dispos"
	choosen_dispos=$(strip_space <<< "$choosen_dispos")
	printf "$choosen_dispos"
}

function dl_resource(){	#$url_template,$max_int,$line,$start_i,$current_strg_counter,$is_numbering,$cookie_file
	for ((i=$4;i<=$2;i++))
	do
		sed -i -e "5 s/.*/$5/" -e "6 s/.*/$i/" "$temp_file"
		rm -f "$filename$lock_suffix"	#last residue lock
		[ -e "$pause_file" ] && exit

		url=$(echo "$1" | sed -e "s|;s|$3|g" -e "s|;d|$i|g")
		#echo "$url"#;continue

		filename=""
		if [ "$6" -eq 0 ]; then
			if [ "$7" != "" ]; then
				response_header=$(curl -sLI "$url" -H @"$7")
			else
				response_header=$(curl -sLI "$url")
			fi
			#filename=$(grep -i "content-disposition:" <<< "$response_header" | tail | tr -d '\r','\n' | awk -F\' '{print $NF}'| urldecode)
			filename=$(grep_content_disposition "$response_header")
			[ "$filename" == "" ] && filename=$(grep -i "location:" <<< "$response_header" | tail -n1 | tr -d '\r','\n' | cut -d':' -f2- | strip_space | urldecode)
			filename=$(valid_filename "$filename")
		fi
		if [ "$filename" == "" ]; then
			if [ "$3" == "" ]; then
				filename="$i"
			else
				purged_line=$(basename -- "$3" | urldecode)
				if [ "$2" == 0 ]; then
					filename="$purged_line"
				else
					filename="$i-$purged_line"
				fi
			fi
		fi		




		echo -n "$filename" #>>../log.txt

		if [ "$7" != "" ]; then
			#$(curl -sL "$url" -H @"$7" -C- -o "$filename")	#resume mode
			$(curl -sL "$url" -H @"$7" -o "$filename")
		else
			#$(wget "$url" -q -c -O "$filename") #resume mode
			$(wget "$url" -q -O "$filename")
		fi

		if [ "$?" != 0 ]; then
			rm "$filename"
			echo "[E]" #>>../log.txt
		else
			echo "[S]" #>>../log.txt
		fi

		#sed -i -e "5 s/.*/$5/" -e "6 s/.*/$i/" "$temp_file"
		#[ -e "$pause_file" ] && exit
	done
}


while [[ $# -gt 0 ]]; do
	case $1 in
		-url|--url)
		  url_template="$2"
		  shift # past argument
		  shift # past value
		  ;;
		-min|--min_int)
		  min_int="$2"
		  shift
		  shift
		  ;;
		-max|--max_int)
		  max_int="$2"
		  shift
		  shift
		  ;;
		-num|--is_numbering)	#use name from counter / strg file
		  is_numbering="$2"
		  shift
		  shift
		  ;;
		-strg|--strg_file)
		  strg_file=$(realpath "$2")
		  shift
		  shift
		  ;;
		-cookie|--cookie_file)
		  cookie_file=$(realpath "$2")
		  shift
		  shift
		  ;;
		*)
		  echo "unknown: '$1'"
		  shift
		  exit
		  ;;
	esac
done

if grep -q ";d" <<< "$url_template" ; then
	: ${max_int:=$((2**63-1))}
	: ${min_int:=0}
else
	max_int=0
	min_int=0
fi
: ${is_numbering:=1}

if [ ! -f "$temp_file" ]; then
	printf "$url_template\n$min_int\n$max_int\n$is_numbering\n1\n$min_int\n" > "$temp_file"
fi

url_template=$(sed -n 1p "$temp_file")
min_int=$(sed -n 2p "$temp_file")
max_int=$(sed -n 3p "$temp_file")
is_numbering=$(sed -n 4p "$temp_file")
current_strg_counter=$(sed -n 5p "$temp_file")
current_counter=$(sed -n 6p "$temp_file")

$(mkdir -p download)
cd download
temp_file="../$temp_file"
if [ "$strg_file" == "" ]; then
	dl_resource "$url_template" "$max_int" "" "$current_counter" "$current_strg_counter" "$is_numbering" "$cookie_file"
else
	strg_max_line=$(wc -l < "$strg_file")
	for ((j=$current_strg_counter;j<=$strg_max_line;j++))
	do
		#sed -i "4 s/.*/$j/" "$temp_file"
		line=$(sed -n "$j"p "$strg_file")
		dl_resource "$url_template" "$max_int" "$line" "$current_counter" "$j" "$is_numbering" "$cookie_file" #|tee -a log.txt
		current_counter=$min_int
	done
fi
