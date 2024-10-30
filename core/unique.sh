#!/bin/sh

INPUT_FILE="$1" 
OUTPUT_FOLDER="$2"
OUTPUT_FILE="$3"


ffmpeg -i "$INPUT_FILE" -i static/logo.png -c:v libx264 -crf 10 -fps_mode vfr -filter_complex \
  "[1:v]transpose=2[logo]; \
  [0:v]transpose=2,scale=2000:1080,crop=iw-200:ih,split[v1][v2]; \
  [v1]boxblur=10:10[bl];[v2]crop=iw-190:ih-70[or]; \
  [bl][or]overlay=W/2-w/2-55:H/2-h/2, \
  pad=iw+2*60:ih:60:0:black,setpts=PTS/1.1[final], \
  [final][logo]overlay=(main_w-overlay_w)/1.05:(main_h-overlay_h)/2" \
  -threads "$(nproc)" -pix_fmt yuv420p -color_primaries bt709 \
  -color_trc bt709 -colorspace bt709 -color_range "tv" \
  -c:a libfdk_aac -b:a 256k -ar 48000 -profile:a aac_low -af "atempo=1.1" \
  -movflags faststart -shortest "$OUTPUT_FOLDER/result.mp4"

ffmpeg -i "$OUTPUT_FOLDER/result.mp4" -c copy  -map_metadata -1 \
  -metadata:s:v:0 "handler_name=VideoHandle" -metadata:s:a:0 "handler_name=SoundHandle" \
  -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
  -sws_flags spline+accurate_rnd+full_chroma_int+full_chroma_inp \
  -movflags faststart -video_track_timescale 90000 \
  -brand mp42 -metadata:s:v:0 language=eng -metadata:s:a:0 language=eng \
  "$OUTPUT_FOLDER/finall.mp4"


MP4Box -add "$OUTPUT_FOLDER/finall.mp4" -brand mp42 -ab isom -ab mp42 -new "$OUTPUT_FOLDER/$OUTPUT_FILE"


DAYS=$(shuf -i 0-10 -n 1)
HOURS=$(shuf -i 0-23 -n 1)
MINUTES=$(shuf -i 0-59 -n 1)
SECONDS=$(shuf -i 0-59 -n 1)
CREATE_DATE=$(date -d "$DAYS days ago $HOURS hours ago $MINUTES minutes ago $SECONDS seconds ago" +"%Y-%m-%d %H:%M:%S")

exiftool -overwrite_original \
  -QuickTime:CreateDate="$CREATE_DATE" -QuickTime:ModifyDate="$CREATE_DATE" \
  -QuickTime:TrackCreateDate="$CREATE_DATE" -QuickTime:TrackModifyDate="$CREATE_DATE" \
  -QuickTime:MediaCreateDate="$CREATE_DATE" -QuickTime:MediaModifyDate="$CREATE_DATE" \
  -QuickTime:AndroidVersion='13' -QuickTime:PlayMode='SEQ_PLAY' \
  -QuickTime:Author='Samsung SM-A515F' -Composite:Rotation=90 \
  "$OUTPUT_FOLDER/$OUTPUT_FILE"


rm "$OUTPUT_FOLDER/result.mp4" "$OUTPUT_FOLDER/finall.mp4" "$INPUT_FILE"
