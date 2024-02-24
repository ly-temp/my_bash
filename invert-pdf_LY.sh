#!/bin/bash
gs -o "${1%.pdf}"_invert.pdf -sDEVICE=pdfwrite -c '{1 exch sub}{1 exch sub}{1 exch sub}{1 exch sub} setcolortransfer' -f "$1"