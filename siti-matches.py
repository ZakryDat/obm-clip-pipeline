import pandas as pd
import numpy as np
from scipy.signal import argrelextrema
import datetime
## pick clips with similar TI & SI info

# pick appropriate values file
siti_values_file = 'example.csv' #csv file containing siti values
#read in csv as pandas dataframe
df = pd.read_csv(siti_values_file)

# find max SI and TI frames in 10 sec window 25fps=250f window
# find frame local maxima
# n=number of frames to check before and after 250/2 = 125, make window larger to give some flexibility in finding clips
n=200

#argrelextrema finds local maxima in defined window
df['max_SI'] = df.iloc[argrelextrema(df.iloc[:,2].values, np.greater_equal, order=n)[0]]['SI']
df['max_TI'] = df.iloc[argrelextrema(df.iloc[:,3].values, np.greater_equal, order=n)[0]]['TI']

# strip out NaN values and drop irrelevant columns (for speed), creating separate TI and SI dataframes
df_SI = df.dropna(subset=['max_SI'])
df_TI = df.dropna(subset=['max_TI'])
df_SI.drop(columns=['Frame','max_TI'], inplace=True)
df_TI.drop(columns=['Frame','max_SI'], inplace=True)

## find frames with similar local maxima
matches_TI = []
matches_SI = []

# iterate through all frames and find max TI matches (within 1 unit).
for i_index,i_row in df_TI.iterrows():
    if i_row['max_TI'] != 0:
        matches = []
        for j_index,j_row in df_TI.iterrows():
            if (j_row['max_TI']-1) < i_row['max_TI'] < (j_row['max_TI']+1):
                # get times of matches
                matches.append(str(datetime.timedelta(seconds=j_index/25)))
        matches_TI.append(matches)

df_TI['matches_TI'] = matches_TI

#remove extra columns and write matches to csv file
df_TI.drop(columns=['max_TI'], inplace=True)
df_TI.to_csv('TI_matches.csv')

# repeat for SI
for i_index,i_row in df_SI.iterrows():
    if i_row['max_SI'] != 0:
        matches = []
        for j_index,j_row in df_SI.iterrows():
            if (j_row['max_SI']-1) < i_row['max_SI'] < (j_row['max_SI']+1):
                matches.append(str(datetime.timedelta(seconds=j_index/25)))
        matches_SI.append(matches)

df_SI['matches_SI'] = matches_SI

df_SI.drop(columns=['max_SI'], inplace=True)
df_SI.to_csv('SI_matches.csv')
