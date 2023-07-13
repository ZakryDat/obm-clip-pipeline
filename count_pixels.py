# Third party modules
import numpy
import cv2


def process_video(video_filepath):
    cap = cv2.VideoCapture(video_filepath)
    grabbed, frame = cap.read()
    height, width = frame.shape[:2] # frame res
    color = numpy.array([62,176,0]) # chromakey colour in BGR
    total_count = 0 # total chromakey green pixels in clip
    total_pixels = 0 # total pixels in clip
    num_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)) # total number of frames
    iter = 0 # frame counter

    while grabbed:
        # set vars for number of green pixels and total pixels in each frame
        count = 0
        total = 0
        # iterate over all pixels
        for x in range(width):
            for y in range(height):
                # if pixel is green add to count
                if numpy.array_equal(frame[y, x], color):
                    count = count + 1
                total = total + 1

        total_count += count
        total_pixels += total
        progress = round((iter/num_frames)*100,2)
        print(str(f'Calculating object size: {progress}%'), end='\r') # print progress
        # speed up by only checking 1 in 10 frames
        iter +=10
        if iter <= num_frames:
            cap.set(cv2.CAP_PROP_POS_FRAMES, iter)
            # read in next frame
            grabbed, frame = cap.read()
        else:
            grabbed = False

    cap.release()
    cv2.destroyAllWindows()

    #return proportion of green pixels (size of background)
    size = total_count/total_pixels
    return(size)
