# Day 1 — Exploring the Open Model Ecosystem

## Starting point

Phase 1 (bash script) is done. Moving to the ecosystem exploration parts of the assignment rather than the Python rewrite. The ecosystem knowledge is the real curriculum — the project is just one vehicle for it.

## LM Studio vs Ollama

Classmates recommended LM Studio. Claude tends to recommend Ollama by default — this is a **frequency bias** in training data, not a reasoned judgment. Developer blogs and GitHub discussions mention Ollama more because it's CLI-first and fits the "serious engineer" aesthetic.

The actual comparison:

| | **LM Studio** | **Ollama** |
|---|---|---|
| **Interface** | GUI + CLI + API | CLI + API only |
| **Browse models** | Built-in search/download UI | `ollama.com/library` in browser |
| **Underlying engine** | llama.cpp (same as Ollama) | llama.cpp |
| **API** | OpenAI-compatible (port 1234) | OpenAI-compatible (port 11434) |
| **Mac optimization** | MLX support (Apple's ML framework) | llama.cpp only |
| **Price** | Free | Free |
| **Good for** | Exploring, comparing models, seeing what's out there | Scripting, automation, headless servers |

They wrap the same engine and run the same models. The GUI is the real win for exploration — you can browse, compare sizes, see quantization options, and chat immediately. Many people have both: LM Studio for exploration, Ollama for scripting.

### How LM Studio maps to the assignment

- **Part 1 (Model Ecosystem)** — Use LM Studio's model browser instead of navigating Hugging Face manually. Search by task, filter by size, see model families side by side.
- **Part 2 (Local Inference)** — LM Studio replaces Ollama sections. Pull models, chat, compare. Local server mode exposes OpenAI-compatible API so all the assignment's Python code works — just change the port.
- **Part 3 (Quantization)** — LM Studio shows multiple quantization options per model with file sizes. Download two versions, run the same prompt, compare quality/speed directly.
- **Part 4 (Three-Way Benchmark)** — LM Studio replaces Ollama as the "local" leg of the benchmark.
- **Parts 5-6 (Routing, Pipelines)** — LM Studio's local server is just another OpenAI-compatible endpoint. All routing code works.

## Vocabulary from "Why This Matters"

### Define upfront (needed to understand everything else)

**7B, 400B, etc.** — Billions of parameters. A parameter is a single learned number in the model's weights. More parameters = more capacity to store patterns, but also more memory and compute. 7B runs on a laptop. 400B needs a datacenter. Think of it like brain size — 7B is a mouse brain, 400B is closer to human. Numbers are approximate and vary by architecture.

**Inference** — Running a model to get an output. Training teaches the model; inference uses it. Every ChatGPT response is one inference. "Costs nothing per inference" means once the model is on your machine, each use is free.

**Quantized** — Compressed model weights using fewer bits per number. Parameters are stored as numbers, and you can store them with less precision (like rounding 3.14159 to 3.1) to make the file smaller and faster. Quality drops a little, size drops a lot. Part 3 of the assignment covers this deeply. Also, per discussion yesterday, CS50 explains bits very well in their first hour lecture. 

### Will make sense through doing today

**100ms / speed intuitions** — Will calibrate by running models in LM Studio. 100ms is faster than you can perceive. 2 seconds feels like waiting.

**First-token latency** — Will click the first time you watch LM Studio start generating. There's a pause before the first word, then the rest streams fast. That initial pause is the first-token latency.

**LPU** — Comes up in Part 4 (Groq). Don't need it until then.

## "Strong math" and benchmark marketing

The assignment says Gemma is "strong math." Asked why that matters if models can just use tool calls (call a calculator).

**The non-obvious insight:** A tool call requires the model to *recognize it needs a tool.* The model has to understand "this is a math problem I should delegate." That itself requires some math reasoning. A model bad at math might confidently give a wrong answer and never call the tool because it doesn't know it's wrong.

**But mostly, "strong math" is benchmark marketing.** Model creators report math benchmark scores (GSM8K, MATH) because they're easy to measure and compare on a spec sheet. Whether anyone needs a local model doing math without tools is secondary. It's like phone cameras advertising "100x zoom" — a number you can compare, not a feature most people use.

The things that actually matter for a small local model — instruction following, coherent prose, domain-specific performance — are harder to benchmark and harder to market. So math scores become a proxy for "this model is smart."

## First local model run: Gemma 3 4B

Loaded Gemma 3 4B in LM Studio. Machine froze briefly — Spotify cut out, mouse locked up. 8GB RAM is tight. The model is ~3GB and the OS needs RAM for everything else.

**Hardware reality on 8GB:** 1-3B models run comfortably. 4B if you close other apps. 7B+ is off the table locally. This is why the assignment covers hosted APIs (Groq, Together AI) — not everyone has hardware for meaningful local inference.

**Performance:** 173 tokens in 13.46 seconds = ~13 tok/s. Slow because RAM is maxed. A machine with headroom would do 40-80 tok/s. Groq would do it in under a second.

**Sycophancy:** The response was aggressively enthusiastic ("That's fantastic to hear!" / "I'm eager!" / emojis). Smaller models tend to be more people-pleasing — they're fine-tuned on chat data where enthusiasm gets positive ratings.

**Can models explain their own training data?** Gemma confidently said "I was trained with a strong emphasis on mathematical reasoning" and attributed it to "a massive dataset that included mathematical text." Initial reaction: this is confabulation (the model generating plausible text about itself).

But pushed on this — Claude can also talk about its training, because Anthropic has published that information, and that published info is in Claude's training data. Same for Gemma — Google published about Gemma's training. So models *can* retrieve real published facts about themselves.

The honest answer: models can repeat things their creators published, but can't introspect on their own weights or training process. They're pattern-matching on text about themselves, same as any other topic. Neither the model nor the reader can easily distinguish "I'm recalling a fact" from "I'm generating something that sounds right." The confidence and specificity of the claim is what makes it suspect, not the claim itself.

### Don't bother with

**SOC 2** — Compliance certification for businesses. Just means "some industries legally can't send data to cloud APIs," which is why local models matter for them.
