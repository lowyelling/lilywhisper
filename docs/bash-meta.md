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
