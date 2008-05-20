#!/bin/sh

color=$1

/bin/sed -e "s/fill:\(#000000\)/fill:#${color}/" public/images/areas/circle.svg | /usr/bin/convert -background none - public/images/areas/${color}.png
