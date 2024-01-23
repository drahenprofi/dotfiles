#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

size_store="$DIR/change_check.txt"
output="$DIR/wallpaper_blur"

# get wallpaper from command args
i_option=""
while getopts ":i:d:" flag; do
	case "${flag}" in
		i) i_option="${OPTARG}";;
		:) exit 1;;
		*) exit 1;;
	esac
done

# Check to make sure an option is given
if [[ -z "$i_option" ]]; then
	printf "\nPlease specify a wallpaper\n\n"
	exit 1
fi

wallpaper=$(printf '%s\n' "$i_option" | sed -e 's/[\/&]/\\&/g')
extension="${wallpaper##*.}"

old_size=$(cat $size_store)
old_size=$(($old_size+0))

current_size=$(ls -s $i_option | sed "s/${wallpaper}//")
current_size=$(($current_size+0))

if [[ $old_size != $current_size ]]; then
    # write new size to file
    echo $current_size > $size_store 

    # blur wallpaper 
    convert -blur 0x7 $i_option "$output.$extension"
fi

echo "$output.$extension" 
