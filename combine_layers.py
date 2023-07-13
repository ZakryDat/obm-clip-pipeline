import subprocess

def combine_layers(foreground, background, new_filename):
    subprocess.run(f'./ffmpeg -i {background} -i {foreground} -filter_complex "[1:v]chromakey=0x00B140:0.2[ckout];[0:v][ckout]overlay" {new_filename}')
