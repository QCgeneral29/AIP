#
# ~/.bashrc
# Provided by Arch Install Plus
#

# For Japanese Input Manager
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
GLFW_IM_MODULE=ibus

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto -I' # Ignore binary files
alias feh='feh --scale-down' # Scale image to fit window
PS1='[\u@\h \W]\$ '

########################
### Helpful commands ###
########################
alias wifion='rfkill unblock wifi'
alias wifioff='rfkill block wifi'
alias getsong='yt-dlp -f bestaudio --extract-audio --audio-format mp3 -o "%(title)s.%(ext)s"'

# Strip metadata from a jpg and compress for web use.
convertJpgForWeb() {
    if [ -z "$1" ]; then
        echo "Usage: convertJpgForWeb <input.jpg>"
        echo "Converts a JPG to a web-optimized version (progressive, stripped metadata, quality 85)."
        return 1
    fi

    local input="$1"
    local output="${input%.jpg}-web.jpg"

    magick "$input" -strip -interlace Plane -sampling-factor 4:2:0 -quality 75 "$output"

    echo "Created: $output"
}

convertWebpToJpg() {
    if [ -z "$1" ]; then
        echo "Usage: convertWebpToJpg <input.webp>"
        echo "Converts a WEBP to JPG with maximum quality (no visible loss)."
        return 1
    fi

    local input="$1"
    local output="${input%.webp}.jpg"

    magick "$input" -quality 100 "$output"

    echo "Created: $output"
}

convertJpgForWebp() {
    if [ -z "$1" ]; then
        echo "Usage: convertJpgForWebp <input.jpg>"
        echo "Converts a JPG to a web-optimized WEBP image (quality 85, efficient compression)."
        return 1
    fi

    local input="$1"
    local output="${input%.jpg}.webp"

    magick "$input" -strip -quality 85 -define webp:method=6 "$output"

    echo "Created: $output"
}

# Compress a video with an optional crf value.
convertVideo() {
    if [ $# -lt 1 ]; then
        echo "Usage: compressVideo <input> [crf]"
        echo "Example: compressVideo MyVideo.mp4 28"
        echo "CRF: lower = higher quality & larger file (e.g., 18)"
        echo "     higher = lower quality & smaller file (e.g., 35)"
		echo "     default = 30"
        return 1
    fi

    input="$1"
    output="${input%.*}-compressed.mp4"
    crf="${2:-30}"

    ffmpeg -i "$input" \
        -c:v libx264 \
        -tag:v avc1 \
        -movflags faststart \
        -crf "$crf" \
        -preset superfast \
        "$output"
}
    
### Compress a video to 10mb and convert to mp4
# Note: Made with AI and is probably bad. Seems to work well-enough
convertVideo10MB() {
    if [ $# -eq 0 ]; then
        echo "Usage: compressVideo10MB <input_file>"
        return 1
    fi

	# Start timer
    start_time=$(date +%s)

	input="$1"
    filename="${input%.*}"
    extension="${input##*.}"
    output="${filename}-10mb.mp4"
    
    # Get video duration and fps
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
    fps=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$input" | awk -F'/' '{if ($2) print $1/$2; else print $1}')
    
    # Calculate target bitrate for 9.5MB to account for overhead
    target_bitrate=$(awk "BEGIN {printf \"%.0f\", (9.5 * 8 * 1024) / $duration - 128}")
    
    # Determine if we need to scale down to 480 based on bitrate
    if [ "$target_bitrate" -lt 500 ]; then
        scale_filter="scale='min(854,iw)':'min(480,ih)':force_original_aspect_ratio=decrease:force_divisible_by=2,"
    else
        scale_filter=""
    fi
    
    # Cap FPS at 30
    target_fps=$(awk "BEGIN {print ($fps > 30) ? 30 : $fps}")
    
    # Ensure minimum bitrate
    if [ "$target_bitrate" -lt 100 ]; then
        target_bitrate=100
    fi
    
    echo "==> Starting first pass..."
    ffmpeg -i "$input" \
        -c:v libx264 \
        -b:v ${target_bitrate}k \
        -maxrate ${target_bitrate}k \
        -bufsize $((target_bitrate * 2))k \
        -vf "${scale_filter}fps=${target_fps}" \
        -pass 1 \
        -an \
        -f mp4 \
        -y /dev/null
    
    echo "==> Starting second pass..."
    ffmpeg -i "$input" \
        -c:v libx264 \
        -b:v ${target_bitrate}k \
        -maxrate ${target_bitrate}k \
        -bufsize $((target_bitrate * 2))k \
        -vf "${scale_filter}fps=${target_fps}" \
        -pass 2 \
        -c:a aac -b:a 128k \
        -preset medium \
        -y "$output"
    
    # Clean up log files
    rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree

	# Calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    minutes=$((elapsed / 60))
    seconds=$((elapsed % 60))
    
    echo "==> Compressed video saved as: $output"
	echo "==> Total time taken: ${minutes}m ${seconds}s"
}

