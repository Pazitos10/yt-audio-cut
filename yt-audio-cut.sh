#!/bin/sh

# Download and cut audio from a yt video

print_usage(){
    echo "Usage: ./yt-audio-cut.sh -u <URL> -f <from_timestamp> -t <to_timestamp> -o <output_filename>"
    echo "Example: ./yt-audio-cut.sh -u <URL> -f 00:01:30 -t 00:02:00 -o test.mp3"
    echo "Dependencies: youtube-dl and ffmpeg"
}

while getopts ':u:f:t:o:h' flag; do
  case "${flag}" in
    u) url=$2;;
    f) from=$4;;
    t) to=$6;;
    o) output_filename=$8;;
    h) print_usage && exit;;
  esac
done

if [ -z "$url" ]
then
    echo "You must provide the yt video URL in order to extract the audio."
    echo "Run ./ytacut.sh -h for help"
else
    if [ -z "$output_filename" ]
    then
        output_filename="audio_cut.mp3"
    fi
    echo "[1/3] Downloading video from $url"
    ytdl_output=$((youtube-dl -x --audio-format mp3 $url) 2>&1) 
    filename=$(echo $ytdl_output | egrep -Eo "\[ffmpeg\] Destination: .*.mp3" | cut -d ":" -f 2 | cut -c 1 --complement)
    echo "[2/3] Preparing to cut"
    if [ -z "$from" ] || [ -z "$to" ]
    then
        echo "The flags -f and/or -t were not used, cutting process not executed."
    else
        ffmpeg -i $filename -ss $from -to $to -y -c copy $output_filename -loglevel quiet
    fi
    echo "[3/3] Done! :D"
fi 