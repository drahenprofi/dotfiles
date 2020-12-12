#!/bin/sh
sed -i \
         -e 's/#1c1e26/rgb(0%,0%,0%)/g' \
         -e 's/#FFFFFF/rgb(100%,100%,100%)/g' \
    -e 's/#1c1e26/rgb(50%,0%,0%)/g' \
     -e 's/#f43e5c/rgb(0%,50%,0%)/g' \
     -e 's/#1c1e26/rgb(50%,0%,50%)/g' \
     -e 's/#d3dae3/rgb(0%,0%,50%)/g' \
	"$@"
