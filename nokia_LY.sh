#!/bin/bash

while [[ $# -gt 0 ]];do
	case $1 in
		-i|--input_file)	input_file=$2 ;shift;shift;;
		-t|--type)	type=$2 ;shift;shift;;
		-db|--target_db)	target_db=$2 ;shift;shift;;
		-e|--allowed_error)	allowed_error=$2 ;shift;shift;;
		-max|--max_trial)	max_trial=$2 ;shift;shift;;
		*)	echo "unknown: '$1'" ;shift;exit;;
	esac
done

: ${target_db:=-54.4}
: ${allowed_error:=0}
: ${max_trial:=20}

if [ "$type" == '' ];then
	[ $(ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$input_file" |wc -w) -eq 0 ] && type=a || type=v
fi

[ "$type" = "v" ] && suffix=".3gp" || suffix=".mp3"
echo "type: $type->$suffix"

diff_db(){ #file
	current_db=($(ffmpeg -i "$1" -filter:a volumedetect -f null /dev/null 2>&1 |grep "mean_volume:" |grep -o ":.*" |cut -d' ' -f2))

	#bc
	#diff=$(echo "$target_db - $current_db" |bc)
	#awk
	diff=$(awk '{print $1 - $2}' <<<"$target_db $current_db")
	
	echo "$diff"
}

echo "in file: $input_file"
diff=$(diff_db "$input_file")
value=0
trial_counter=0
str_value=''
base_name=$(basename -- "$input_file")
while
	if [ -f "$out_f" ];then
	rm "$out_f"
	fi

	#value=$(echo "$value + $diff" |bc)
	value=$(awk '{print $1 + $2}' <<<$value $diff)
	str_value="$value"dB
	out_f="${base_name%.*}[$str_value]$suffix"
	echo "parameter: $str_value"
	if [ "$type" = a ];then
		$(ffmpeg -i "$input_file" -filter:a "volume=$str_value" -y "$out_f" >/dev/null 2>&1)
	else
		if [ "$type" = v ];then
			$(ffmpeg -i "$input_file" -r 30 -s 352*288 -acodec aac -filter:a "volume=$str_value" -y "$out_f" >/dev/null 2>&1)
		
		#fix 3gp cannot select codec
		#if [ $? ];then
		#	output=$(ffmpeg -i "$input_file" -r 30 -s 352*288 -filter:a "volume=$str_value" -vcodec libx264 -acodec aac -y "$out_f" 2>&1)
		#fi
		fi
	fi

	diff=$(diff_db "$out_f")
	echo "diff: ${diff}dB"
	echo '------'

	((trial_counter++))
	[ $(awk 'BEGIN{print('${diff#-}' > '$allowed_error')}') -eq 1 ] && [ $trial_counter -le $max_trial ]
do true;done
echo "$out_f"
#mv "$out_f" ../output --backup=numbered
