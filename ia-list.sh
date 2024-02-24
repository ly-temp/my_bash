#!/bin/bash
save(){
	echo -n "$1	"
	code=$(curl -w "%{http_code}" -sL "https://web.archive.org/save/$1" -o /dev/null)
	echo "$code"
	[ "$code" -eq 429 ]&&sleep 15
}
if [ -f log.txt ];then
	head -n -1 log.txt>log.txt.0 && mv log.txt.0 log.txt
	i=$(wc -l <log.txt)
	((i++))
else
	i=1
fi
while read -r url;do
	save "$url"|tee -a log.txt
done< <(tail -n +"$i" list.txt)
