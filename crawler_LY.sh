#!/bin/bash
# no input

function get_domain(){
  awk -F[/:?] '{print $4}'
}
function get_bool(){
  temp=2
  while [ "$temp" != "1" ] && [ "$temp" != "0" ]; do
    read -p "$1: " temp
  done
  echo "$temp"
}
function update_newline_n(){
  ((line_n++))
  sed -i "5s/.*/$line_n/" temp.ly
}

if ! [ -e url.ly ] || ! [ -e temp.ly ]
then
  read -p "url: " url
  get_domain <<< "$url" > temp.ly
  is_same_domain=2
  is_same_domain=$(get_bool "scan url only of same domain? ")
  load_same_domain=$(get_bool "load html only of same domain? ")
  printf "$is_same_domain\n$load_same_domain\n" >> temp.ly
  read -p "add on: " addon_list
  printf "$addon_list\n1" >> temp.ly
  echo "$url" > url.ly
fi

content=$(cat temp.ly)
domain=$(sed '1!d' temp.ly)
is_same_domain=$(sed '2!d' temp.ly)
load_same_domain=$(sed '3!d' temp.ly)
addon_list=$(sed '4!d' temp.ly)
line_n=$(sed '5!d' temp.ly)

#echo "$domain"
#echo "$addon_list"
#echo "$is_same_domain"
#echo "$load_same_domain"
#echo "$line_n"

while ! [ -e pause.ly ] ; do
  url=$(sed "$line_n!d" url.ly)
  [ -z "$url" ] && break
  ([ "$load_same_domain" == 1 ] && [ $(get_domain <<< "$url") != "$domain" ]) && (update_newline_n;url_list="") || url_list=$("$(dirname $0)/scan_html_LY.sh" "$url" "$addon_list")
  IFS=$'\n'
  for new_url in $url_list
  do
    if ! grep -Fqx -- "$new_url" url.ly
      then
        if [ "$is_same_domain" == 1 ]
	then
	   [[ $(get_domain <<< "$new_url") == $domain ]] && echo "$new_url" >> url.ly
	else echo "$new_url" >> url.ly
	fi
    fi
  done
  update_newline_n
  #sleep 1
done


