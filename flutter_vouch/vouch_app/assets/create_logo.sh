#!/bin/bash
# This script creates a simple logo using ImageMagick if available
# If not, we'll use a different approach
if command -v convert &> /dev/null; then
    # Create logo with ImageMagick
    convert -size 512x512 xc:none \
        -fill "#6C63FF" -draw "circle 256,256 256,50" \
        -fill "white" -draw "path 'M 256 100 L 356 150 L 356 250 Q 356 320 256 400 Q 156 320 156 250 L 156 150 Z'" \
        -fill "#6C63FF" -draw "path 'M 256 130 L 330 165 L 330 250 Q 330 300 256 360 Q 182 300 182 250 L 182 165 Z'" \
        -stroke "white" -strokewidth 10 -fill none \
        -draw "path 'M 220 260 L 245 285 L 290 220'" \
        logo.png
    echo "Logo created with ImageMagick"
else
    echo "ImageMagick not found. Logo will need to be created manually or using Flutter."
fi
