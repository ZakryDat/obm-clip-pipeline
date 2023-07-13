#!/bin/bash

videoFile=$1
label=$2
size=$3

./ffmpeg.exe -i $videoFile -ss 00:00:06.000 -vframes 1 -s $size $videoFile\-temp.png -y

./ffmpeg.exe -i $videoFile\-temp.png -vf "drawtext=text=\'$label\':x=0.5:y=0.5:fontsize=60:fontcolor=white:box=1:boxcolor=black" $videoFile\.png -y

rm $videoFile\-temp.png

# ...
