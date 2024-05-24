#!/bin/bash
# ╭──────────────────────────────────────────────────────────────────────────────╮
# │                                                                              │
# │     Return the timestamps of the most popular parts of a youtube video       │
# │                                                                              │
# ╰──────────────────────────────────────────────────────────────────────────────╯

# ╭──────────────────────────────────────────────────────────╮
# │                       Set Defaults                       │
# ╰──────────────────────────────────────────────────────────╯

if [[ "${DEBUG-0}" == "1" ]]; then set -o xtrace; fi        # DEBUG=1 will show debugging.



# ╭──────────────────────────────────────────────────────────╮
# │                        VARIABLES                         │
# ╰──────────────────────────────────────────────────────────╯
URL="https://yt.lemnoslife.com/videos?part=mostReplayed&id="
YOUTUBE_VIDEO_ID=""
COUNT=1
DURATION=5

# ╭──────────────────────────────────────────────────────────╮
# │                          Usage.                          │
# ╰──────────────────────────────────────────────────────────╯

usage()
{
    if [ "$#" -lt 2 ]; then
        printf "ℹ️ Usage:\n $0 -v <YOUTUBE_VIDEO_ID> -n <NUMBER>\n\n" >&2 

        printf "Summary:\n"
        printf "Uses an unsharp mask to alter the luma,chroma and alpha of a video.\n\n"

        printf "Flags:\n"

        printf " -v | --videoid <YOUTUBE_VIDEO_ID>\n"
        printf "\tSupply the youtube video ID to scan.\n\n"

        printf " -c | --count <NUMBER>\n"
        printf "\tNumber of timestamps to return (most watched first).\n\n"

        exit 1
    fi
}


# ╭──────────────────────────────────────────────────────────╮
# │         Take the arguments from the command line         │
# ╰──────────────────────────────────────────────────────────╯
function arguments()
{
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
    case $1 in


        -v|--videoid)
            YOUTUBE_VIDEO_ID=$2
            shift
            shift
            ;;

        -c|--count)
            COUNT=$2
            shift
            shift
            ;;


        -d|--download)
            DOWNLOAD="TRUE"
            shift
            shift
            ;;

        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;


        *)
            POSITIONAL_ARGS+=("$1") # save positional arg back onto variable
            shift                   # remove argument and shift past it.
            ;;
    esac
    done

}



# ╭──────────────────────────────────────────────────────────╮
# │                                                          │
# │                      Main Function                       │
# │                                                          │
# ╰──────────────────────────────────────────────────────────╯
function main()
{
    # printf "%-80s\n" "🎬 YouTube Snippets - Get the timestamps of most watched parts."

    if [ -z "$YOUTUBE_VIDEO_ID" ]; then
        echo "Error: URL is empty. Please provide a valid URL."
        exit 1
    fi

    JSON_RESPONSE=$(curl -s "${URL}${YOUTUBE_VIDEO_ID}")

    # Read the JSON file and parse the top N highest intensity scores with their startMillis values
    TOP_VALUES=$(echo "$JSON_RESPONSE" | jq -r --argjson num "$COUNT" '.items[0].mostReplayed.markers | sort_by(-.intensityScoreNormalized) | .[:$num] | map({startMillis}) | .[] | "\(.startMillis)"')

    # echo $TOP_VALUES

    # Create a bash array from the output of jq
    declare -a MILLI_ARRAY
    while read -r startMillis intensityScoreNormalized; do
        MILLI_ARRAY+=("$startMillis")
    done <<< "$TOP_VALUES"

    # If -d DOWNLOAD Is not set, escape now.
    if [ -z "$DOWNLOAD" ]; then exit 0; fi

    # Print the top N startMillis values
    # printf "%s\n" "${MILLI_ARRAY[@]}"

    for MILLIS in "${MILLI_ARRAY[@]}"; do
        # Run your command for each millisecond value
        echo "Running command for $MILLIS milliseconds"

        # Calculate
        START_TIME=$(echo "scale=2; ($MILLIS - ($DURATION * 1000 / 2)) / 1000" | bc)

        # download
        yt-dlp --postprocessor-args "-ss $START_TIME -t $DURATION" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 "https://www.youtube.com/watch?v=$VIDEO_ID" -o "output_clip.%(ext)s"

    done
}

usage $@
arguments $@
main $@