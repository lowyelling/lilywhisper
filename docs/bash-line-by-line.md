# lilywhisper.sh — Line-by-Line Analysis

## Architecture

The loop is: **Record audio → Transcribe locally → Paste into active app**. No cloud, no API keys. Everything stays on your machine.

Three tools do the heavy lifting:

1. **`rec`** (from SoX) — records audio from your mic
2. **`whisper-cli`** (whisper.cpp) — transcribes audio to text locally using a small English model
3. **`osascript`** — macOS AppleScript to simulate Cmd+V

---

## Setup (Lines 1–17)

```bash
#!/bin/bash
```

Shebang line — tells the OS to run this with bash.

```bash
WHISPER_MODEL="/opt/homebrew/share/whisper-cpp/ggml-small.en.bin"
RECORDING="/tmp/lilywhisper_recording.wav"
HISTORY_DIR="$HOME/.voice-history"
```

Three constants:

- **`WHISPER_MODEL`** — the small English-only Whisper model. Good speed/accuracy tradeoff.
- **`RECORDING`** — temp file that gets overwritten every time. Only the latest recording exists.
- **`HISTORY_DIR`** — where daily transcription logs are stored (`~/.voice-history/`).

```bash
mkdir -p "$HISTORY_DIR"
```

Creates the history directory if it doesn't exist. `-p` means "don't error if it's already there."

```bash
echo "lilywhisper ready."
echo ""
```

Startup message. You know it's listening.

---

## The Main Loop (Lines 20–65)

```bash
while true; do
```

Runs forever until you Ctrl+C.

### Start Recording (Lines 21–27)

```bash
echo "Press Enter to start recording..."
read
```

`read` with no variable just blocks until you hit Enter. It's the "push" in push-to-talk.

```bash
rec "$RECORDING" rate 16k channels 1 2>/dev/null &
REC_PID=$!
echo "Recording... Press Enter to stop."
```

This is the interesting mechanical bit:

- **`rec`** starts recording in the **background** (`&`).
- **`$!`** captures the PID (process ID) of that background process so you can kill it later.
- **`rate 16k`** — 16kHz sample rate, exactly what Whisper expects.
- **`channels 1`** — mono audio. Whisper doesn't need stereo.
- **`2>/dev/null`** — suppresses SoX's noisy stderr output.

### Stop Recording (Lines 29–33)

```bash
read
```

Blocks again — second Enter press is the "release" of push-to-talk.

```bash
kill $REC_PID 2>/dev/null
wait $REC_PID 2>/dev/null
```

- **`kill`** sends SIGTERM to the `rec` process.
- **`wait`** waits for it to actually finish and exit cleanly. This is important — without it, the wav file might not be fully written when Whisper tries to read it.

### Transcribe (Lines 35–42)

```bash
echo "Transcribing..."

TRANSCRIPTION=$(whisper-cli \
    -m "$WHISPER_MODEL" \
    -f "$RECORDING" \
    --no-timestamps -nt \
    2>/dev/null)
```

Runs Whisper inference locally:

- **`-m`** — path to the model file.
- **`-f`** — path to the audio file.
- **`--no-timestamps -nt`** — strips the `[00:00:00 --> 00:00:03]` prefixes so you get clean text.
- **`2>/dev/null`** — suppresses Whisper's diagnostic output.
- **`$(...)`** — command substitution captures stdout into the variable.

### Trim Whitespace (Line 45)

```bash
TRANSCRIPTION=$(echo "$TRANSCRIPTION" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
```

`sed` with two substitutions chained by `;`:

1. `s/^[[:space:]]*//` — strip leading whitespace
2. `s/[[:space:]]*$//` — strip trailing whitespace

### Empty Check (Lines 47–51)

```bash
if [ -z "$TRANSCRIPTION" ]; then
    echo "Nothing detected. Try again."
    echo ""
    continue
fi
```

`-z` tests if the string is empty. If Whisper returned nothing (silence, noise), skip the rest and loop back. `continue` jumps to the top of the `while` loop.

### Paste into Active App (Lines 53–59)

```bash
echo "Got: $TRANSCRIPTION"

echo -n "$TRANSCRIPTION" | pbcopy
echo "Pasting in 3 seconds — click into the app where you want the text..."
sleep 3
osascript -e 'tell application "System Events" to keystroke "v" using command down'
```

Three-step paste:

1. **`pbcopy`** — macOS clipboard. `echo -n` prevents a trailing newline.
2. **`sleep 3`** — waits 3 seconds, giving you time to click into the app where you want the text. Without this, the paste would fire immediately in the terminal window.
3. **`osascript`** — tells macOS to simulate Cmd+V via AppleScript. This pastes wherever your cursor currently is — any app, any text field.

### Save to History (Lines 62–63)

```bash
TODAY="$HISTORY_DIR/$(date +%Y-%m-%d).md"
echo -e "\n## $(date +%H:%M:%S)\n$TRANSCRIPTION" >> "$TODAY"
```

Appends each transcription to a daily markdown file with a timestamp header. So `~/.voice-history/2026-03-09.md` becomes a running log of everything you dictated that day. `>>` appends rather than overwrites.

---

## Prerequisites

1. **SoX** — `brew install sox` (provides the `rec` command)
2. **whisper.cpp** — `brew install whisper-cpp` (provides `whisper-cli` and the model)
3. **Accessibility permissions** — your terminal app needs permission in System Settings → Privacy & Security → Accessibility (required for the `osascript` paste)
4. The model path assumes **Homebrew on Apple Silicon** (`/opt/homebrew/...`)
