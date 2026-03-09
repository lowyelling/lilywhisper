# Bash Meta — Questions & Answers

## Why is the Whisper model stored under `/opt/homebrew/`?

That's a Homebrew convention. When you `brew install whisper-cpp`, Homebrew installs everything into its prefix directory — `/opt/homebrew/` on Apple Silicon Macs (on Intel Macs it's `/usr/local/`).

Homebrew puts shared data files (like model weights) under `/opt/homebrew/share/<package>/`. So the model lands at:

```
/opt/homebrew/share/whisper-cpp/ggml-small.en.bin
```

The alternative would be downloading the model yourself and putting it wherever you want — `~/models/`, the project directory, etc. The path in the script is just pointing to where Homebrew happened to put it. You could change `WHISPER_MODEL` to any valid path.

The reason `/opt/homebrew/` exists at all: Apple Silicon broke the old `/usr/local/` convention because macOS started protecting that path more aggressively. Homebrew moved to `/opt/homebrew/` to avoid conflicts with the system.
