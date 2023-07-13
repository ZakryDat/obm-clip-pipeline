#!/usr/bin/env bash

# changed from x264 to ffmpeg encoding
# all quality variations are now upscaled to the highest resolution (after encoding with target resolution...)

echo "Script started."
#set -x

sourceFolder=$1
videoFile=$2
outputFolder=$3
fps=$4
preset=$5
numberOfQualities=$6

inputFileName=$videoFile

# Encoding settings: (taken from apple's recommended settings for live stream:
# https://developer.apple.com/documentation/http_live_streaming/http_live_streaming_hls_authoring_specification_for_apple_devices)
# (416x234, 640x360, 768x432, 960x540, 1280x720, 1920x1080) (145, 365, 730, 2000, 4500, 7800)

if [[ "$numberOfQualities" -eq 3 ]]; then
declare -a resolutions=("416x234" "768x432" "1280x720")
declare -a bitrates=("145k" "730k" "4500k")
elif [[ "$numberOfQualities" -eq 4 ]]; then
declare -a resolutions=("416x234" "768x432" "1280x720" "1920x1080")
declare -a bitrates=("145k" "730k" "4500k" "7800k")
else
declare -a resolutions=("416x234" "1280x720")
declare -a bitrates=("145k" "4500k")
fi

# Encode assets into different bitrates
highestResolution=${resolutions[numberOfQualities-1]}

for (( i=0; i<$numberOfQualities; i++ ))
do
	./ffmpeg.exe -y -i $sourceFolder/$inputFileName.mp4 -c:v libx264 \
	 -r $fps -x264opts 'keyint='$fps':min-keyint='$fps':no-scenecut' \
	 -s ${resolutions[$i]} -b:v ${bitrates[$i]} -maxrate ${bitrates[$i]} \
	 -movflags faststart -bufsize ${bitrates[$i]} \
	 -profile:v main -pix_fmt yuv420p -preset $preset -an "output_$i.mp4"
done

# Upscale all quality permutations to the highest resolution & store in lossless format
for (( i=0; i<$numberOfQualities; i++ ))
do
	./ffmpeg.exe -i output_$i.mp4 -vf scale=$highestResolution output_$i_temp.mp4 -y

	#./ffmpeg.exe -i output_$i_temp.mp4 \
	#    -vcodec  ffv1       \
	#    -level   1          \
	#    -coder   1          \
	#    -context 1          \
	#    -g       1          \
	#    $outputFolder/$inputFileName\_$i.mov -y

	mv output_$level_temp.mp4 $outputFolder/$inputFileName\_$i.mp4

	rm output_$i.mp4
	#rm output_$level_temp.mp4

done

echo "Script finished."
