#!/bin/bash

rmSpace(){
	sed -E -e 's/^\s+//' -e 's/\s+$//'
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-f|--file)	f=$(realpath -- "$2");fName=$(basename -- "$2");Name=${fName%.*};fDir=$(dirname -- "$2")/;shift;shift;;
		-m|--method)	m=$2;shift;shift;;
		-a|--author)	a=1;shift;;
		-v|--verbose)	v=1;shift;;
		-so)	so=1;shift;;
		-sn)	sn=1;shift;;
		-co)	co=1;shift;;
		-cn)	cn=1;shift;;
		-h|--help)	printf 'f:file\nm:method:\n\tr:rename\n\te:extract\n\ter:extract-rename\na:author\nv:verbose\nso/n:src(opf/ncx)\nco/n:content\n';exit;;
		*)echo Unknown;exit;;
	esac
done

[ -z "$fName" ] || [[ "$fName" != *.epub* ]] &&exit

CWD=$(pwd)
EPUB_DIR=/tmp/unzip."$fName"/
trap "cd ${CWD@Q} && rm -r ${EPUB_DIR@Q}" EXIT
7z x -o"$EPUB_DIR" -aoa "$f">/dev/null ||exit
cd "$EPUB_DIR"

OPF=$(xmlstarlet sel -t -v ////@full-path META-INF/container.xml)
R=$(dirname "$OPF")/	#root
NCX=$(xmlstarlet sel -t -v '//*[@id="ncx"]/@href' "$OPF")
[ -z "$NCX" ]&&NCX=$(xmlstarlet sel -t -v '//*[@id="toc.ncx"]/@href' "$OPF")

aut=$(xmlstarlet sel -N dc=http://purl.org/dc/elements/1.1/ -t -v //_:metadata/dc:creator "$OPF" |rmSpace)
title_opf=$(xmlstarlet sel -N dc=http://purl.org/dc/elements/1.1/ -t -v //_:metadata/dc:title "$OPF" |rmSpace)
src=$(xmlstarlet sel -t -v //_:navMap/_:navPoint/_:content/@src "$R$NCX")

if [ -n "$NCX" ];then
	tidy -q -xml -m -- "$R$NCX"
	title=$(xmlstarlet sel -t -v /_:ncx/_:docTitle/_:text "$R$NCX" |rmSpace)
	[ -z "$title" ]&&title=$(xmlstarlet sel -t -v /_:ncx/_:dcTitle/_:text "$R$NCX" |rmSpace)
content=$(xmlstarlet sel -T -t -m //_:navMap/_:navPoint  -v _:content/@src -o $'\t' -v _:navLabel/_:text -n "$R$NCX")	#extra
fi

[ -z "$title" ]&&title=$title_opf
title=$(tr -d '\n'<<<$title)

manifestSrc=$(xmlstarlet sel -t -v ///@href "$OPF")
manifestContent=$(xmlstarlet sel -T -t -m ///_:item -v @href -o $'\t' -v @id -n "$OPF")


n=$title	#new name
[ -n "$a" ] && n="$n - $aut"

[ -n "$so" ]&&echo "--src opf--
$manifestSrc
"
[ -n "$sn" ]&&echo "--src ncx--
$src
"
[ -n "$co" ]&&echo "--con opf--
$manifestContent
"
[ -n "$cn" ]&&echo "--con ncx--
$content
"

if [ -n "$v" ];then
	echo -n "$fName:
$title
$aut"
else
	echo -n "$fName => $n"
fi

[ -z "$n" ]&&{ echo [E];exit; }||echo

cd "$CWD"
case $m in
	r|rename)
		mv --backup=t "$f" "$fDir$n".epub;;
	e*|extract)
		[ "$m" == 'er' ]&&Name=$n
		while read -r i;do
			tail +2 "$EPUB_DIR$R$i" |html2text -utf8 >>"$Name".txt
		done<<<$(grep \\.xhtml$ <<<$src)
		while read -r i;do
			html2text -utf8 <"$EPUB_DIR$R$i" >>"$Name".txt
		done<<<$(grep \\.html$ <<<$src);;
esac
