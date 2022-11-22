#!/bin/bash
cookie=$(sed -E "s|-H '[^']+'|&\n|g" "$1" | awk -F\' '{print $(NF-1)}')
echo "$cookie" > "$1"