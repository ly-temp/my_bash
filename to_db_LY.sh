#!/bin/bash
#input: [input file] [volume] [output suffix]
target_db=$2
if [ "$3" = "" ]; then
	filename=$(basename -- "$1")
	suffix=".${filename##*.}"
else
	suffix=$3
fi

diff_db(){
	current_db=($(ffmpeg -i "$file" -filter:a volumedetect -f null /dev/null 2>&1 | grep "mean_volume:" | grep -o ":.*" | cut -d' ' -f2))
	#diff=$(echo "$target_db - $current_db" | bc)
	diff=$(awk_bc <<< "$target_db -$current_db")
	echo "$diff"
}

awk_bc(){
	awk '{print $1 + $2}'
}

echo "in file: $1"
file=$1
diff=$(diff_db)
value=0
str_value=""
file=$out_f
while
  if [ -f "$out_f" ]; then
	rm "$out_f"
  fi

  #value=$(echo "$value + $diff" | bc)
  value=$(awk_bc <<< "$value $diff")  
  str_value="$value""dB"
  out_f="${1%.*}[$str_value]$suffix"
  echo "parameter: $str_value"
  output=$(ffmpeg -i "$1" -filter:a "volume=$str_value" -vcodec copy -y "$out_f" 2>&1)
  
  #fix 3gp cannot select codec
  #if [ $(grep -E "(Default encoder for format 3gp \(codec amr_nb\) is probably disabled.|Conversion failed!)" <<< "$output" | wc -w) -gt 0 ]; then
  #	output=$(ffmpeg -i "$1" -filter:a "volume=$str_value" -vcodec libx264 -acodec aac -y "$out_f" 2>&1)
  #fi
  
  file="$out_f"
  diff=$(diff_db)
  echo "diff: ${diff}dB"
  echo '------'
  [ "$diff" != "0" ]
do true; done
echo "$out_f"