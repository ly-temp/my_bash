# $url $add_on_strg
function add_on(){
	if grep -Fq "google;" <<< "$2"
	then
	  grep -Eo "url=[^;]+;" <<< "$1" | grep -Eo "(https|http)://[^;]+" | rev | cut -d'&' -f2- | rev #for google search links
	fi

	if grep -Fq "haodu;" <<< "$2"
	then
	  sed 's/ //g' <<< "$1" | grep -Eo 'onClick="[^"]+"' | cut -d'"' -f2 | sed "s|^|$protocol$host/|" #for haodu book tag
	fi
}
function html_get_url_LY(){
	#grep -Eoi '<a[^>]+>' | grep -Eo '"(http|https|/).*' | cut -d '"' -f2 | uniq
	grep -Eoi '<a[^>]+>' | grep -Eoi 'href="[^"]+"' | cut -d '"' -f2 | uniq
}

function html_append_host_LY(){
	#grep -Ev '(https|http)' | sed "s|^[^/]|/|" | sed "s|^|$1|"
	grep -Ev '(https|http)' | sed "s|^[^/].*|/&|" | sed "s|^|$1|"
	grep -E '(https|http)'
}
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/37.0.2062.94 Chrome/37.0.2062.94 Safari/E7FBAF"
host=$(awk -F[/:?] '{print $4}' <<< "$1")
protocol=$(grep -o ".*://" <<< "$1")
content=$(curl -s "$1" --connect-timeout 5 -A "$UA" | tr -d '\0')
echo "$content" | html_get_url_LY | html_append_host_LY "$protocol$host"
#printf "\n--add_on--\n\n"
add_on "$content" "$2"
