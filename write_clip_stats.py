# takes clip filenames as input, export clip stats to csv

import subprocess
import json
import csv
import count_pixels
import os

# imported clip, green screened clip and csv file to write stats to
def write_clip_stats(clip, green_clip, csv_file="clip_stats.csv"):


    with open(csv_file,'a+',newline='') as file:
        writer = csv.writer(file)
        if os.stat(csv_file).st_size == 0:
            writer.writerow(['File name','Length','Max SI','Max TI', 'Foreground Obj Size', 'Background Obj Size'])

        y = subprocess.run(f"ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {clip}.mp4", stdout=subprocess.PIPE)
        clip_length = json.loads(y.stdout)
        x = subprocess.run(f"siti -f {clip}.mp4", stdout=subprocess.PIPE)

        siti_file = json.loads(x.stdout)

        sizeBackground = count_pixels.process_video(f"{green_clip}.mp4")
        sizeForeground = 1 - sizeBackground

        writer.writerow([clip, clip_length, siti_file['max_si'],siti_file['max_ti'], sizeForeground, sizeBackground])
