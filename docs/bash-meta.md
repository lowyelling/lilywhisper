# Bash Meta — Questions & Answers

## Why is the Whisper model stored under `/opt/homebrew/`?

That's a Homebrew convention. When you `brew install whisper-cpp`, Homebrew installs everything into its prefix directory — `/opt/homebrew/` on Apple Silicon Macs (on Intel Macs it's `/usr/local/`).

Homebrew puts shared data files (like model weights) under `/opt/homebrew/share/<package>/`. So the model lands at:

```
/opt/homebrew/share/whisper-cpp/ggml-small.en.bin
```

The alternative would be downloading the model yourself and putting it wherever you want — `~/models/`, the project directory, etc. The path in the script is just pointing to where Homebrew happened to put it. You could change `WHISPER_MODEL` to any valid path.

The reason `/opt/homebrew/` exists at all: Apple Silicon broke the old `/usr/local/` convention because macOS started protecting that path more aggressively. Homebrew moved to `/opt/homebrew/` to avoid conflicts with the system.

## What is AppleScript? How is it different from a regular bash script?

AppleScript is macOS's built-in automation language for controlling applications. It talks to apps through their GUI — clicking buttons, typing keystrokes, opening menus, moving windows. Bash talks to the **OS kernel** (files, processes, pipes). AppleScript talks to **applications** (Finder, Safari, System Events).

The line in lilywhisper:

```applescript
tell application "System Events" to keystroke "v" using command down
```

This is asking the System Events app to simulate a human pressing Cmd+V. Bash has no way to do that — it doesn't know about keyboards or GUI apps. So `osascript` is the bridge: a bash command that executes AppleScript.

The key difference is **who you're talking to**:

| | Bash | AppleScript |
|---|---|---|
| **Talks to** | The OS (kernel, filesystem, processes) | macOS applications (via their GUI/scripting interface) |
| **Good at** | Files, pipes, text processing, running programs | Clicking things, typing, automating app workflows |
| **Feels like** | Giving orders to the machine | Puppeteering apps like a human would |
| **Runs on** | Any Unix system | macOS only |

AppleScript is why lilywhisper can paste into *any* app — it's not interacting with a specific program, it's simulating a keystroke at the OS GUI layer. The app doesn't know the difference between you pressing Cmd+V and AppleScript doing it.

## Is there a Windows or Linux equivalent of AppleScript?

**Windows:** PowerShell can do some of it, but the closer equivalent is **AutoHotkey** — a scripting language specifically for simulating keystrokes, mouse clicks, and automating GUI apps. There's also the COM automation model (similar idea to AppleScript's "tell application" — you talk to apps through a scripting interface), which PowerShell and VBScript can use.

**Linux:** There's no single built-in equivalent because Linux desktops are more fragmented. The closest tools:

- **`xdotool`** — simulates keystrokes and mouse events on X11 (the traditional display server). The lilywhisper paste line would be something like `xdotool key ctrl+v`.
- **`ydotool`** — same idea but works on Wayland (the newer display server that's replacing X11).
- **D-Bus** — a message bus that apps can expose interfaces through, conceptually similar to how AppleScript talks to apps. But there's no universal standard for what apps expose.

The fragmentation is the tradeoff. macOS controls the whole stack (OS, window manager, app framework), so Apple can mandate "every app must respond to AppleScript." Linux doesn't have that authority — different desktops (GNOME, KDE, etc.), different display servers (X11, Wayland), different app toolkits. More freedom, less guaranteed interop.

If you ever ported lilywhisper to Linux, you'd swap two lines: `pbcopy` → `xclip` or `wl-copy`, and the `osascript` line → `xdotool key ctrl+v`.

## What is a shebang line?

The `#!` at the top of a script — pronounced "shebang" (or "hashbang"). In lilywhisper:

```bash
#!/bin/bash
```

It tells the OS **which program should interpret this file**. When you run `./lilywhisper.sh`, the OS reads that first line and thinks: "oh, I should hand this file to `/bin/bash` to execute."

Without it, the OS doesn't know what to do with the file. Is it Python? Ruby? Bash? The shebang answers that question.

Some common shebangs:

- `#!/bin/bash` — run with bash
- `#!/usr/bin/env python3` — run with python3 (the `env` version searches your PATH, more portable)
- `#!/bin/zsh` — run with zsh
- `#!/usr/bin/env node` — run with Node.js

The name "shebang" comes from combining **sh**arp (`#`) and **bang** (`!`). It's one of those Unix conventions that's been around since the early 1980s.

One subtlety: it only matters when you run the script directly (`./lilywhisper.sh`). If you run `bash lilywhisper.sh`, you're explicitly telling it to use bash, so the shebang is ignored.

## Is `.voice-history` a secret hidden folder?

Half right. The folder *is* created by the `mkdir -p "$HISTORY_DIR"` line. But it's not secret — it's just a **dotfile convention**.

On Unix systems, any file or folder starting with `.` is hidden from normal `ls` output. You need `ls -a` to see them. That's it — there's no special permission or encryption. It's just "don't clutter up the user's home directory with stuff they don't need to see day-to-day."

Your home directory is full of these: `~/.zshrc`, `~/.claude/`, `~/.config/`, `~/.git/`. They're all configuration or data folders that apps create for themselves. The convention is: if it's for the *program* and not for the *human*, make it a dotfile.

So `~/.voice-history/` is just lilywhisper's way of saying "I'll keep my logs here, out of your way." You can `ls -a ~` to see it, `cat` the files inside, delete it — nothing hidden about it beyond the dot.
