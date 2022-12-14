#!/bin/bash
#input: [input file] [output suffix]
target_db=-54.4
suffix="$2"

if [ "$suffix" = "" ]; then
	[ $(ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$1" | wc -w) -eq 0 ] && type="a" || type="v"
	[ "$type" = "v" ] && suffix=".3gp" || suffix=".mp3"
fi

echo "type: $type"

diff_db(){
	current_db=($(ffmpeg -i "$file" -filter:a volumedetect -f null /dev/null 2>&1 | grep "mean_volume:" | grep -o ":.*" | cut -d' ' -f2))
	#bc
	#diff=$(echo "$target_db - $current_db" | bc)
	#awk
	
	diff=$(awk '{print $1 - $2}' <<< "$target_db $current_db")
	
	echo "$diff"
}

echo "in file: $1"
file=$1
diff=$(diff_db)
value=0
str_value=""
while
  if [ -f "$out_f" ]; then
	rm "$out_f"
  fi

  #value=$(echo "$value + $diff" | bc)
  value=$(awk '{print $1 + $2}' <<< "$value $diff")
  str_value="$value""dB"
  out_f="${1%.*}[$str_value]$suffix"
  echo "parameter: $str_value"
  if [ "$type" = "a" ]; then
		$(ffmpeg -i "$1" -filter:a "volume=$str_value" -y "$out_f" >/dev/null 2>&1)
  else
	if [ "$type" = "v" ]; then
		$(ffmpeg -i "$1" -r 30 -s 352*288 -acodec aac -filter:a "volume=$str_value" -y "$out_f" >/dev/null 2>&1)
	
  #fix 3gp cannot select codec
  #if [ $? ]; then
  #	output=$(ffmpeg -i "$1" -r 30 -s 352*288 -filter:a "volume=$str_value" -vcodec libx264 -acodec aac -y "$out_f" 2>&1)
  #fi

	fi
  fi
  file=$out_f
  diff=$(diff_db)
  echo "diff: ${diff}dB"
  echo '------'
  [ "$diff" != "0" ]
do true; done
echo "$out_f"
#mv "$out_f" ../output --backup=numbered
