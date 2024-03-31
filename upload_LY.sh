#!/bin/bash
#$filename

file_io(){
	curl -gs -X 'POST' \
		'https://file.io' \
		-H 'accept: application/json' \
		-H 'Content-Type: multipart/form-data' \
		-F "file=@$file" \
	|grep -Eo '"link":"[^"]+"' |awk -F\" '{print $(NF-1)}' |tr -d '\n'
}
transfer_sh(){
	curl -gs -T "$file" https://transfer.sh |sed 's|/|/get/|3'
}
null_pointer(){
	u=$(curl -gs -F"file=@$file" -Fsecret= https://0x0.st |tr -d '\n')
	printf %s "$u/$(basename -- "$file")"
}
oshi_at(){
	u=$(curl -gs -T "$file" https://oshi.at/?expire=129600 |grep '\[Download\]' |cut -d\  -f1)
	printf %s "$u/$(basename -- "$file")"
}
file_coffee(){
	u=$(curl -gs -F"file=@$file" https://api.file.coffee/file/upload|jq -r .url)
	printf %s "$u?f=$(basename -- "$file")"
}
s3(){
	s3_LY.sh -f "$file" -s "${service:1}" -x p
}

upload(){
	case $service in
		fio)	file_io;shift;;
		n)	null_pointer;shift;;
		o)	oshi_at;shift;;
		fc)	file_coffee;shift;;
		s*)	s3;shift;;
		t|'')	transfer_sh;shift;;
		*)	echo "unknown: '$method'" ;shift;exit;;
	esac
	[[ -n $pass ]] && printf " $pass"
	[[ $no_newline -eq 0 ]] && echo
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-s)	service=$2 ;shift;shift;;
		-f)	file=$2 ;shift;shift;;
		-n)	no_newline=1 ;shift;;
		-p|--password)	pass=$(openssl rand -base64 12 |tr -dc '[:alnum:]') ;shift;;
		-ps|--password_set)	pass=$2 ;shift;shift;;
		-c)	clip=1;no_newline=1	;shift;;
		-h|--help)	printf 's:service\nf:file\nn:no newline\np:ran pass\nps:set pass\nc:clip\n' ;shift;exit;;
		*)	echo "unknown: '$1'" ;shift;exit;;
	esac
done

fname=$(basename -- "$file")
: ${no_newline:=0}
: ${clip:=0}

if [[ -n $pass ]];then
	f_zip="$fname".7z
	7z a "$f_zip" "$file" -p"$pass" -bsp0 -bso0
	file="$f_zip"
else
	if [[ -d $file ]];then
		f_zip="$fname".tar
		tar cf "$f_zip" -C $(dirname "$file") "$fname"
		file=$f_zip
	fi
fi

if [ "$clip" -eq 1 ];then
	upload|tee >(xclip -sel c)
	echo
else
	upload
fi

[[ -n $f_zip ]] &&rm "$f_zip"
