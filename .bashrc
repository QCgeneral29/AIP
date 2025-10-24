#
# ~/.bashrc
#

# Helpful commands
alias wifi-on='rfkill unblock wifi'
alias wifi-off='rfkill block wifi'
alias getsong='yt-dlp -f bestaudio --extract-audio --audio-format mp3 -o "%(title)s.%(ext)s"'

# For Japanese Input Manager
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
GLFW_IM_MODULE=ibus

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto -I' # Ignore binary files
PS1='[\u@\h \W]\$ '

### Compress a video to 10mb and convert to mp4
# Note: Made with AI and is probably bad. Seems to work well-enough
compressVideo10MB() {
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

