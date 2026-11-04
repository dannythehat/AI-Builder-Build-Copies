# AI Builder - Build Copies: use the AI you choose

This independent Windows build uses the original Craft Anything study/build/check/refine
engine. **It is not locked to one AI provider.** The source already supports a
per-project **Built by** selector, an AI settings page, and an open provider interface.
Our portable distribution includes `Setup-Any-AI.ps1` as an optional PowerShell shortcut.

## What works, and what is still experimental

- **Builder engine:** desktop application and CLI can study websites/apps/games, create a
  project, and run the existing checking/refinement pipeline.
- **Coding agents:** built-in adapters for Claude Code, Codex, GitHub Copilot,
  Gemini CLI, OpenCode, Qwen Code, Goose, Hermes, Maki, and Antigravity.
  Each requires its respective program to be installed, supported, and signed in.
  The upstream project reports Claude Code as the most live-tested builder.
  Other integrations vary in maturity and may not support all permissions,
  sessions, or MCP/ACP operations; do not assume every agent has passed a real build.
- **Direct APIs:** OpenAI, Anthropic, Google Gemini API, OpenRouter, and
  OpenAI-compatible endpoints (Ollama, LM Studio, vLLM, llama.cpp, etc.).
  An arbitrary model must support the tool calls or compatible fallback the
  build needs. API-driven building exists in the engine, but is described by
  upstream as partly tested. A chat-only model may be unsuitable.
- **Any AI** means *any compatible agent CLI or API backend*, not literally every AI
  service or a way to use a paid chat app's private credentials.

## Windows: install

1. Open [Build AI Builder for Windows](https://github.com/dannythehat/AI-Builder-Build-Copies/actions/workflows/build-ai-builder-windows.yml).
2. Select a **successful** build; download the artifact named
   `AI-Builder-Build-Copies-Windows-x64` (sign in to GitHub if requested).
3. Extract the ZIP; keep every file together.
4. Run `AI-Builder.exe` to open the interface. No Rust compilation needed on your computer.
5. In **Settings → AI**, add an installed coding agent or your own API provider/key.
   On the **Make** screen choose the AI under **Built by**.
6. Enter a website URL or app/game target and describe what you want.
   Start the build, approve any commands when asked, and review its checks.

The Windows ZIP is built by your repository and **unsigned**; this is a
self-produced test build, not a Microsoft-signed installer.

## Windows: optional one-command provider selection

Open PowerShell in the **extracted** folder, then choose one of these:

```powershell
# Show which coding agents and local AI servers are detected
.\Setup-Any-AI.ps1 -Provider detect

# Use an installed and separately authenticated coding agent
.\Setup-Any-AI.ps1 -Provider codex
.\Setup-Any-AI.ps1 -Provider claude
.\Setup-Any-AI.ps1 -Provider gemini
.\Setup-Any-AI.ps1 -Provider copilot
.\Setup-Any-AI.ps1 -Provider opencode

# An OpenAI-compatible local server that is already running:
.\Setup-Any-AI.ps1 -Provider ollama -Model qwen3-coder:latest
.\Setup-Any-AI.ps1 -Provider lmstudio

# Any other OpenAI-compatible API (including local/private endpoints):
.\Setup-Any-AI.ps1 -Provider custom -BaseUrl http://localhost:1234/v1 -Model your-model-id

# View everything configured:
.\Setup-Any-AI.ps1 -Provider list
```

For an API provider, first set its API key in **your local PowerShell session**
and specify the actual available model if needed:

```powershell
$env:OPENAI_API_KEY = '<your API key>'
.\Setup-Any-AI.ps1 -Provider openai -Model gpt-5

# Or:
$env:OPENROUTER_API_KEY = '<your API key>'
.\Setup-Any-AI.ps1 -Provider openrouter -Model 'provider/model-id'
```

Other API key names: `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`,
`CUSTOM_AI_API_KEY` (only if your custom endpoint needs one).
**Never commit API keys to GitHub.** Remove ephemeral keys from the
session when finished. You can instead add a key through **Settings → AI**.

## Building via CLI

You can choose a different AI on every build, after configuring it:

```powershell
.\craft-anything-cli.exe ai list
.\craft-anything-cli.exe rebuild 'https://example.com' 'Recreate this website' --backend 'Codex'
.\craft-anything-cli.exe rebuild - 'Make a simple playable game' --backend 'OpenAI' --rounds 1
```

## Caveats

The application does not magically bypass authentication, website access
controls, paywalls, third-party licences or application backends. Code copied
from third parties may require permissions; the default clean-room inspection
approach builds a fresh implementation from observable functionality.
Keep your own projects private if they contain sensitive code or credentials.

The browser-only/WebAssembly viewer in the source is **not** the full AI builder.
It analyses files inside the browser and does not host local coding agents.
Our first usable product is the full Windows desktop app.

## Source and provenance

- Independent repository: https://github.com/dannythehat/AI-Builder-Build-Copies
- Original project: https://github.com/storytold/craft-anything
- Source imported from upstream commit: `7a0d7de0e4343dac35acb58cc64d021febcb7157`.
- Open-source licences and attribution remain in the repository.
