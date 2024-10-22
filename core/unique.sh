#!/bin/sh

INPUT_FILE="$1" 
OUTPUT_FOLDER="$2"
OUTPUT_FILE="$3"
TIME_IN_METADATA="$4"


ffmpeg -i "$INPUT_FILE" -i static/logo.png -r 30 -filter_complex\
        "[0:v]scale=1080:2000,crop=iw:ih-200,split[v1][v2];\
        [v1]boxblur=10:10[bl];[v2]crop=iw-70:ih-190[or];\
        [bl][or]overlay=W/2-w/2:H/2-h/2-55,\
        pad=iw:ih+2*60:0:60:black,setpts=PTS/1.1[final],\
        [final][1:v]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/1.05" \
        -threads "$(nproc)" -pix_fmt yuv420p -color_primaries bt709\
        -color_trc bt709 -colorspace bt709 -color_range "tv" \
        -c:a copy -shortest "$OUTPUT_FOLDER/result.mp4"

ffmpeg -i "$OUTPUT_FOLDER/result.mp4" -c copy  -map_metadata -1  \
        -metadata:s:0 "handler_name=Core Media Video" -metadata:s:1 "handler_name=Core Media Audio" \
        -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
        -sws_flags spline+accurate_rnd+full_chroma_int+full_chroma_inp \
        -movflags faststart -video_track_timescale 600 \
        "$OUTPUT_FOLDER/$OUTPUT_FILE"

rm "$OUTPUT_FOLDER/result.mp4"


if [[ "$TIME_IN_METADATA" == "yes" ]]; then
DAYS=$(shuf -i 0-10 -n 1)
HOURS=$(shuf -i 0-23 -n 1)
MINUTES=$(shuf -i 0-59 -n 1)
SECONDS=$(shuf -i 0-59 -n 1)

CREATE_DATE=$(date -d "$DAYS days ago $HOURS hours ago $MINUTES minutes ago $SECONDS seconds ago" +"%Y-%m-%d %H:%M:%S")
MODIFY_DATE=$(date -d "$CREATE_DATE 11 seconds" +"%Y-%m-%d %H:%M:%S")

exiftool -overwrite_original -QuickTime:CreateDate="$CREATE_DATE" -QuickTime:ModifyDate="$MODIFY_DATE"\
        -QuickTime:TrackCreateDate="$CREATE_DATE" -QuickTime:TrackModifyDate="$MODIFY_DATE"\
        -QuickTime:MediaCreateDate="$CREATE_DATE" -QuickTime:MediaModifyDate="$MODIFY_DATE"\
        "$OUTPUT_FOLDER/$OUTPUT_FILE"
fi
