#!/bin/sh

INPUT_FILE="$1" 
OUTPUT_FOLDER="$2"
OUTPUT_FILE="$3"
LOGO_PNG='static/logo.png'


ffmpeg -i "$INPUT_FILE" -i "$LOGO_PNG" -c:v libx264 -crf 20 -r 30 -filter_complex \
  "[0:v]scale=1080:2000,noise=alls=5:allf=t, \
  eq=brightness=-0.05:saturation=1.2,crop=iw:ih-200,split[v1][v2]; \
  [v1]boxblur=5:5[bl];[v2]rotate=0.02*sin(t),crop=iw-70:ih-190[or]; \
  [bl][or]overlay=W/2-w/2:H/2-h/2-55, \
  pad=iw:ih+2*60:0:60:black,setpts=PTS/1.08[final], \
  [final][1:v]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/1.05" \
  -threads "$(nproc)" -pix_fmt yuv420p -color_primaries bt709 \
  -color_trc bt709 -colorspace bt709 -color_range "tv" \
  -c:a aac -b:a 192k -ar 48000 -profile:a aac_low -af "atempo=1.07,afftdn=nf=-25" \
  -movflags +faststart -shortest "$OUTPUT_FOLDER/result.mp4"

ffmpeg -i "$OUTPUT_FOLDER/result.mp4" -c copy  -map_metadata -1 \
  -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
  -sws_flags spline+accurate_rnd+full_chroma_int+full_chroma_inp \
  -movflags +faststart -video_track_timescale 600 \
  -brand mp42 \
  "$OUTPUT_FOLDER/finall.mp4"


MP4Box -add "$OUTPUT_FOLDER/finall.mp4" -brand mp42 -ab isom -ab mp42 -new "$OUTPUT_FOLDER/$OUTPUT_FILE"


rm "$OUTPUT_FOLDER/result.mp4" "$OUTPUT_FOLDER/finall.mp4" "$INPUT_FILE"
