#!/bin/bash
# $brightness $out_formt
my_contrast(){
	# set defaults
	samt=50			# shadow amount; 0<=integer<=100			
	swid=50			# shadow tone width; 0<=integer<=100	
	srad=30			# shadow radius; float>=0
	hamt=0			# highlight amount; 0<=integer<=100	
	hwid=50			# highlight tone width; 0<=integer<=100	
	hrad=30			# highlight radius; float>=0
	blend=50		# shadow highlight blend amount; 0<=integer<=100

	dir=.
	tmpA1="$dir/shadhigh_1_$$.mpc"
	tmpB1="$dir/shadhigh_1_$$.cache"
	tmpS1="$dir/shadhigh_S_$$.mpc"
	tmpS2="$dir/shadhigh_S_$$.cache"
	tmpH1="$dir/shadhigh_H_$$.mpc"
	tmpH2="$dir/shadhigh_H_$$.cache"
	tmpG1="$dir/shadhigh_G_$$.mpc"
	tmpG2="$dir/shadhigh_G_$$.cache"

	infile=$1
	outfile=$2
	tempfile=ly.mpc
	tempcache=ly.cache
	hamt=$3
	samt=$4

	trap "rm -f $tmpA1 $tmpB1 $tmpS1 $tmpS2 $tmpG1 $tmpG2 $tmpH1 $tmpH2 $tempfile $tempcache" RETURN

	convert -quiet "$infile" +repage "$tmpA1" || return 1

	convert $tmpA1 -colorspace LAB -channel R -separate +channel $tmpG1

	hwid2=$((100-hwid))
	# process highlight
	hrad=`convert xc: -format "%[fx:$hrad/3]" info:`
	hamt=`convert xc: -format "%[fx:$hamt/20]" info:`
	proc="+sigmoidal-contrast $hamt,0%"
	convert $tmpA1 -colorspace LAB -channel R $proc +channel -colorspace sRGB \
		\( $tmpG1 -blur 0x${hrad} -white-threshold $hwid2% -level 0x${hwid2}% \) \
		-alpha off -compose copy_opacity -composite $tmpH1

	# process shadow
	srad=`convert xc: -format "%[fx:$srad/3]" info:`
	samt=`convert xc: -format "%[fx:$samt/20]" info:`
	proc="+sigmoidal-contrast $samt,100%"	
	convert $tmpA1 -colorspace LAB -channel R $proc +channel -colorspace sRGB \
		\( $tmpG1 -blur 0x${srad} -black-threshold $swid% -level ${swid}x100% -negate \) \
		-alpha off -compose copy_opacity -composite $tmpS1

	# blend highlight and shadow results and do midtone and color correction processing
	convert $tmpH1 $tmpS1 -define compose:args=$blend -compose blend -composite -alpha off $tempfile

	convert $tempfile -colorspace gray -brightness-contrast "$5"x90 -quality 100% $outfile

	return 0
}

[ "$1" == '' ] && brightness=-5 || brightness=$1
mkdir -p out
cd out
for i in ../*;do
	[ -d "$i" ] && continue
	suffix="${i##*.}"
	name=$(basename "$i")
	out_f="${name%.*}_out.$suffix"
	my_contrast "$i" "$out_f" 100 160 "$brightness"
done
[ "$2" != 'img' ] && convert * ../out.pdf && rm -r ../out