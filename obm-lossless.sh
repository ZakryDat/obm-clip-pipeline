#!/usr/bin/env bash

#
# Encodes two separate video layers into multiple qualities, then combines the different quality permutations using ffmpeg's chromakey filter
# With audio: mixes audio from both layers or copies audio from only one of the layers
# Adds 'End of Clip' message at the end
#
# Note: - both input layers must have the same framerate
#		- only mp4 files supported for now
#

echo "Script started."

preset="medium" # "medium" for slow encoding of final clips, "veryfast" for testing (encoding profile: https://write.corbpie.com/ffmpeg-preset-comparison-x264-2019-encode-speed-and-file-size/)
thumbnailRes="1280x720"					# Max resolution for thumbnails & the end message resolution

sourceFolder=$1 						# Directory where the assets are located
firstAsset=$2 							# Asset 1, the background layer, without extension (only works with mp4 for now)
secondAsset=$3 							# Asset 2, the foreground layer, without extension
outputFolder=$4 						# Output directory, will be created if doesn't exist
audioMode=$5 							# audio_first_only, audio_second_only, audio_mix
chromakeyColor=$6 						# The color of the chromakey background
chromakeySensitivity=$7 				# Similarity of ffmpeg chromakey filter: values between 0.13 and 0.23 work best - but it all depends on the content, more on the filter here: https://ffmpeg.org/ffmpeg-filters.html#chromakey-1
fps=$8									# needs to match the FPS of the source videos
numberOfQualities=$9

if [[ "$numberOfQualities" -eq 3 ]]; then
declare -a assetLabels=("L1" "L2" "L3")		# Asset labels for thumbnail titles
declare -a qualityLabels=("Q1" "Q2" "Q3")	# Video Quality labels for thumbnail titles
elif [[ "$numberOfQualities" -eq 4 ]]; then
declare -a assetLabels=("L1" "L2" "L3" "L4")
declare -a qualityLabels=("Q1" "Q2" "Q3" "Q4")
else
declare -a assetLabels=("L1" "L2")
declare -a qualityLabels=("Q1" "Q2")
fi


#blue: 0x0047BB:0.21
green: 0x00B140:0.2

mkdir $outputFolder

# Encode both layers into multiple quality permutations
./convert-lossless.sh $sourceFolder $firstAsset $outputFolder $fps $preset $numberOfQualities
./convert-lossless.sh $sourceFolder $secondAsset $outputFolder $fps $preset $numberOfQualities #$pos_x $pos_y $size_width $size_height $chromakeyColor

#echo "File\tP.1203 MOS" >> mos.txt
#for (( i=0; i<$numberOfQualities; i++ ))
#do
	#mos=$(python3 -m itu_p1203 $firstAsset\_$i\.mp4 --mode 3 | grep "O46")
	#echo "$firstAsset\_$i\.mp4 $mos" >> mos.txt

	#mos=$(python3 -m itu_p1203 $secondAsset\_$i\.mp4 --mode 3 | grep "O46")
	#echo "$secondAsset\_$i\.mp4 $mos" >> mos.txt

	#./thumbnail-new.sh $outputFolder/$firstAsset\_$i\.mov ${assetLabels[0]}\_${qualityLabels[$i]} $thumbnailRes
	#./thumbnail-new.sh $outputFolder/$secondAsset\_$i\.mov ${assetLabels[1]}\_${qualityLabels[$i]} $thumbnailRes
	#./thumbnail-new.sh $outputFolder/$firstAsset\_$i\.mp4 ${assetLabels[0]}\_${qualityLabels[$i]} $thumbnailRes
	#./thumbnail-new.sh $outputFolder/$secondAsset\_$i\.mp4 ${assetLabels[1]}\_${qualityLabels[$i]} $thumbnailRes

#done

# Extract & convert audio
if [[ "$audioMode" = "audio_first_only" ]]; then
	./ffmpeg.exe -i $sourceFolder/$firstAsset\.mp4 -vn -acodec aac tempaudio.aac -y
elif [[ "$audioMode" = "audio_second_only" ]]; then
	./ffmpeg.exe -i $sourceFolder/$secondAsset\.mp4 -vn -acodec aac tempaudio.aac -y
else
	./ffmpeg.exe -i $sourceFolder/$firstAsset\.mp4 -i $sourceFolder/$secondAsset\.mp4 -filter_complex "[0][1]amix=inputs=2[a]"  \
	-map "[a]" -vn -acodec aac tempaudio.aac -y
fi

# Generate a short clip for the 'End of Clip' message
./ffmpeg.exe -f lavfi -i color=size=$thumbnailRes:duration=0.2:rate=25:color=black -vf "drawtext=fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='End of Clip'" tempEndMessage.mp4 -y

# Combine the different quality permutations of both layers
for (( i=0; i<$numberOfQualities; i++ ))
do
	for (( j=0; j<$numberOfQualities; j++ ))
	do

		./ffmpeg.exe -i $outputFolder/$firstAsset\_$i\.mp4 -i $outputFolder/$secondAsset\_$j\.mp4 -i tempEndMessage.mp4 \
		-filter_complex '[1:v]chromakey='"$chromakeyColor"':'"$chromakeySensitivity"':0.0[ckout];[0:v][ckout]overlay[out] ; [out][2:v]concat=n=2:v=1 [v]' \
		-map '[v]' tempvideo.mp4 -y

		./ffmpeg.exe -i tempaudio.aac -i tempvideo.mp4 $outputFolder/$firstAsset\_$i\_$secondAsset\_$j\.mp4 -y
		rm tempvideo.mp4

		#./ffmpeg.exe -i $outputFolder/$firstAsset\_$i\_$secondAsset\_$j\.mov -c:v libx264 -crf 23 -preset $preset $outputFolder/$firstAsset\_$i\_$secondAsset\_$j\.mp4 -y

		#mos=$(python3 -m itu_p1203 $firstAsset\_$i\_$secondAsset\_$j\.mp4 --mode 3 | grep "O46")
		#echo "$firstAsset\_$i\_$secondAsset\_$j\.mp4 $mos" >> mos.txt

		#./thumbnail-new.sh $outputFolder/$firstAsset\_$i\_$secondAsset\_$j\.mov ${assetLabels[0]}_${qualityLabels[$i]}-${assetLabels[1]}_${qualityLabels[$j]} $thumbnailRes
		#./thumbnail-new.sh $outputFolder/$firstAsset\_$i\_$secondAsset\_$j\.mp4 ${assetLabels[0]}_${qualityLabels[$i]}-${assetLabels[1]}_${qualityLabels[$j]} $thumbnailRes

	done
done

# clean-up
rm tempaudio.aac
rm tempEndMessage.mp4
rm $outputFolder/$firstAsset\_0.mp4
rm $outputFolder/$secondAsset\_0.mp4
rm $outputFolder/$firstAsset\_1.mp4
rm $outputFolder/$secondAsset\_1.mp4

echo "Script finished."
