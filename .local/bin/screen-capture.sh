#!/bin/sh

format="mkv"
audio_format="flac"
dir="$(xdg-user-dir VIDEOS)/screencasts/"
output="${dir}screencast_$(date '+%Y%m%d%H%M%S').${format}"
audio_output="${dir}screencast_$(date '+%Y%m%d%H%M%S').${audio_format}"
recpid="/tmp/recordingpid"
watermark="${dir}watermark.png"
internal="$(pacmd list-sources | grep -B 1 -A 3 'name:.*monitor' | grep -B 4 'state: IDLE' | awk '/index:/ { print $2; }')"
mic="$(pacmd list-source-outputs | awk '/source:/ { print $2; }')"
#mic="$(pacmd list-sources | awk '/\* index:/ { print $3; }')"
[ -z "$(echo "${1}" | grep '^$')"  ] && mic="default"

case "${1}" in
  "window"|"all"|"nomic"|"gif*"|"watermark")
    #info="$(xdpyinfo | awk '/dimensions/ { print $2; }')"
    info="$(xwininfo -frame)"
    win_geo=$(echo "${info}" | grep -e "Height:" -e "Width:" | cut -d \: -f 2 | tr "\n" " " | awk '{print $1 "x" $2}')
    win_pos=$(echo "${info}" | grep "upper-left" | head -n 2 | cut -d \: -f 2 | tr "\n" " " | awk '{print $1 "," $2}')
    ;;
  "region") reg_sel=$(slop -f "-video_size %wx%h -i :0.0+%x,%y") ;;
  "full"|"overlay") 
    full="$(xrandr -q | awk '/\sconnected/ { print $4; }' | cut -d '+' -f 1)"
    ;;
esac

## KILL RECORDING
killrecording() {
  if [ -f "${recpid}" ]; then
    pidrec="$(command cat ${recpid})"
    kill -15 "${pidrec}"
    sleep 3
    kill -9 "${pidrec}" 2>/dev/null
    rm -f "${recpid}"
    exit 0
  fi
}

## WINDOW SELECTION
window() {
  ffmpeg \
    -video_size "${win_geo}" \
    -framerate 60 \
    -f x11grab -i :0.0+"${win_pos}" \
    -f pulse -i "${mic}" \
    -ac 2 \
    -r 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## REGION
region() {
  ffmpeg \
    -framerate 60 \
    -f x11grab \
    ${reg_sel} \
    -f pulse -i "${mic}" \
    -ac 2 \
    -r 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## FULL
full() {
  ffmpeg \
    -video_size "${full}" \
    -framerate 60 \
    -f x11grab -i :0.0+0,0\
    -f pulse -i "${mic}" \
    -ac 2 \
    -r 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## NO MIC
nomic() {
  ffmpeg \
    -video_size "${win_geo}" \
    -framerate 60 \
    -f x11grab -i :0.0+"${win_pos}" \
    -r 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## ALL SOUND
all() {
  ffmpeg \
    -video_size "${win_geo}" \
    -framerate 60 \
    -f x11grab -i :0.0+"${win_pos}" \
    -f pulse -i "${mic}" \
    -f pulse -i "${internal}" \
    -ac 2 \
    -filter_complex amerge=inputs=2 \
    -r 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## MONITOR WHILE RECORDING
monitor() {
  ffmpeg \
    -f v4l2 -standard PAL -thread_queue_size 2048 -i /dev/video1 \
    -f alsa -thread_queue_size 2048 -i hw:2,0 \
    -map 0 -map 1 \
    -vf yadif=1 \
    -vcodec libx264 -preset superfast -crf 23 -flags +global_header \
    -acodec libmp3lame -b:a 128k -ac 2 -ar 48000 \
    -f tee "vhs_output.mov|[f=nut:onfail=ignore]pipe:1" | ffplay - &
  echo $! > "${recpid}"
}

## WEBCAM ONLY
webcam() {
  ffmpeg \
    -f v4l2 \
    -i /dev/video0 \
    -video_size 1280x720 \
    -framerate 30 \
    "${output}" &
  echo $! > "${recpid}"
}

## MIC AUDIO ONLY
mic_only() {
  ffmpeg \
    -f alsa -i default \
    -c:a flac \
    "${audio_output}" &
  echo $! > "${recpid}"
}

## MONITOR AND MIC AUDIO ONLY
all_audio() {
  ffmpeg \
    -f alsa -i default \
    -f pulse -i "${internal}"\
    -c:a flac \
    -ac 2 \
    -filter_complex amerge=inputs=2 \
    "${audio_output}" &
  echo $! > "${recpid}"
}

## MONITOR AUDIO ONLY
internal_monitor() {
  ffmpeg \
    -f pulse -i "${internal}"\
    -c:a flac \
    "${audio_output}" &
  echo $! > "${recpid}"
}

## GIF
gif() {
  ffmpeg \
    -video_size "${win_geo}" \
    -framerate 60 \
    -f x11grab -i :0.0+"${win_pos}" \
    -r 30 \
    "${output%%${format}}gif" &
  echo $! > "${recpid}"
}

## LOW QUALITY GIF
gif_low() {
  ffmpeg \
    -video_size "${win_geo}" \
    -framerate 60 \
    -f x11grab -i :0.0+"${win_pos}" \
    -r 30 \
    -vf "fps=10,scale=320:-1:flags=lanczos" \
    "${output%%${format}}gif" &
  echo $! > "${recpid}"
}

## SCREEN AND OVERLAY
overlay() {
  ffmpeg \
    -f x11grab \
    -thread_queue_size 64 \
    -video_size "${full}" \
    -framerate 30 \
    -i :1 \
    -f v4l2 \
    -thread_queue_size 64 \
    -video_size 320x180 \
    -framerate 30 \
    -i /dev/video0 \
    -filter_complex 'overlay=main_w-overlay_w:main_h-overlay_h:format=yuv444' \
    -vcodec libx264 \
    -preset ultrafast \
    -qp 0 \
    -pix_fmt yuv444p \
    "${output}" &
  echo $! > "${recpid}"
}

## SCREEN AND WATERMARK
watermark() {
  ffmpeg \
    -f x11grab \
    -video_size "${win_geo}" \
    -framerate 30 \
    -f x11grab -i :0.0+"${win_pos}" \
    -f image2 -i "${watermark}" \
    -filter_complex 'overlay=W-w-5:H-h-5' \
    -f pulse -i "${mic}" \
    -ac 2 \
    -preset medium \
    -qp 0 \
    -pix_fmt yuv444p \
    "${output}" &
  echo $! > "${recpid}"
}

case "${1}" in
  "window") window ;;
  "full") full ;;
  "region") region ;;
  "nomic") nomic ;;
  "all") all ;;
  "watermark") watermark ;;
  "overlay") overlay ;;
  "monitor") monitor ;;
  "webcam") webcam ;;
  "mic") mic_only ;;
  "internal") internal_monitor ;;
  "all-audio") all_audio ;;
  "gif") gif ;;
  "gif-low") gif_low ;;
  "kill") killrecording ;;
  *) return ;;
esac
