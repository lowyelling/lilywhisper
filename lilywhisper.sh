#!/bin/bash

# lilywhisper - push-to-talk dictation
# Record → Transcribe → Paste, all local
#
# Usage: ./lilywhisper.sh
#   Press Enter to start recording
#   Press Enter again to stop
#   Transcription gets pasted wherever your cursor is

WHISPER_MODEL="/opt/homebrew/share/whisper-cpp/ggml-small.en.bin"
RECORDING="/tmp/lilywhisper_recording.wav"
HISTORY_DIR="$HOME/.voice-history"

mkdir -p "$HISTORY_DIR"

echo "lilywhisper ready."
echo ""

while true; do
    echo "Press Enter to start recording..."
    read

    # Start recording in the background
    rec "$RECORDING" rate 16k channels 1 2>/dev/null &
    REC_PID=$!
    echo "Recording... Press Enter to stop."

    read

    # Stop recording
    kill $REC_PID 2>/dev/null
    wait $REC_PID 2>/dev/null

    echo "Transcribing..."

    # Transcribe
    TRANSCRIPTION=$(whisper-cli \
        -m "$WHISPER_MODEL" \
        -f "$RECORDING" \
        --no-timestamps -nt \
        2>/dev/null)

    # Trim whitespace
    TRANSCRIPTION=$(echo "$TRANSCRIPTION" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ -z "$TRANSCRIPTION" ]; then
        echo "Nothing detected. Try again."
        echo ""
        continue
    fi

    echo "Got: $TRANSCRIPTION"

    # Copy to clipboard, give you 3 seconds to click into another app, then paste
    echo -n "$TRANSCRIPTION" | pbcopy
    echo "Pasting in 3 seconds — click into the app where you want the text..."
    sleep 3
    osascript -e 'tell application "System Events" to keystroke "v" using command down'

    # Save to history
    TODAY="$HISTORY_DIR/$(date +%Y-%m-%d).md"
    echo -e "\n## $(date +%H:%M:%S)\n$TRANSCRIPTION" >> "$TODAY"

    echo "Pasted and saved."
    echo ""
done
