FROM ubuntu:22.04

RUN apt-get update

# Dependencies
RUN apt-get install --no-install-recommends -y \
    jq              \
    rclone          \
    ssh             \
    sshpass         \
    sed             \
    curl            \
    tar             \
    git             \
    xz-utils        \
    ca-certificates  \
    python3

# YouTube Downloader
RUN cd /usr/local/bin && \
    curl --insecure -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ./yt-dlp && \
    chmod a+rx ./yt-dlp

# FFMPEG
RUN curl --insecure -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg-release-full.tar.xz && \
    tar -xf /tmp/ffmpeg-release-full.tar.xz --wildcards -O '**/ffmpeg' > /usr/local/bin/ffmpeg && \
    tar -xf /tmp/ffmpeg-release-full.tar.xz --wildcards -O '**/ffprobe' > /usr/local/bin/ffprobe && \
    chmod +x /usr/local/bin/ffmpeg && \
    chmod +x /usr/local/bin/ffprobe

# FFMPEG Bash Scripts
WORKDIR /usr/local/bin
RUN git clone https://github.com/IORoot/ffmpeg__bash-scripts.git && \
    mv ffmpeg__bash-scripts/* . && \
    rm -Rf ffmpeg__bash-scripts/

# Keep the Container Running
CMD ["sh", "-c", "while :; do sleep 2073600; done"]