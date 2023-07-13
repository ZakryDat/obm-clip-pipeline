# run pipeline for creating short clips with different quality permutations
# only works for .mp4 clips

from write_clip_stats import write_clip_stats
import subprocess

numClips = 37

for i in range(1,numClips):
    # parameters
    # full clip name, without extension
    clip = f"news{i}"
    # runway ML processed clip, with object on green screen background
    green_clip = f"{i}"
    # folder to store clip permutations
    output_folder = "outputs"
    source_folder = "" #

    chroma_colour = "green"
    chroma_sensitivity = 0.2 # sensitivity of chromakey transparency filter, 0.1 - 0.3 seems to work for most clips.
    audio = "audio_first_only" # # audio_first_only, audio_second_only, audio_mix
    fps=25 # needs to match the FPS of the source videos
    num_qualities=2 # desired number of quality encoding - will dictate number of permutations


    # writes clip name, length of clip, obj size, SI and TI info to a csv
    # params are clip, green screened object, csv file name
    write_clip_stats(clip, green_clip)

    # combines clip and green screen into multiple quality permutations
    subprocess.run(f"bash ./obm-lossless.sh {source_folder} {clip} {green_clip} {output_folder} {audio} {chroma_colour} {chroma_sensitivity} {fps} {num_qualities}")
