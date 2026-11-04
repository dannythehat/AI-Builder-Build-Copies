<#
.SYNOPSIS
  Choose the AI that builds in AI Builder - Build Copies.
.DESCRIPTION
  Uses Craft Anything's existing provider-neutral AI backend and Builder role.
  Supports local coding-agent CLIs, API-backed models, and OpenAI-compatible local
  or remote servers. No keys are written to the repository or passed as arguments.
.EXAMPLE
  .\Setup-Any-AI.ps1 -Provider detect
  .\Setup-Any-AI.ps1 -Provider codex
  .\Setup-Any-AI.ps1 -Provider claude
  .\Setup-Any-AI.ps1 -Provider gemini
  .\Setup-Any-AI.ps1 -Provider openai -Model gpt-5
  .\Setup-Any-AI.ps1 -Provider openrouter -Model anthropic/claude-opus-5-5
  .\Setup-Any-AI.ps1 -Provider ollama -Model qwen3-coder:latest
  .\Setup-Any-AI.ps1 -Provider custom -BaseUrl http://localhost:1234/v1 -Model local-model
#>
[CmdletBinding()]
param(
    [ValidateSet('detect','list','claude','codex','copilot','gemini','antigravity','opencode','hermes','qwen','goose','maki','openai','anthropic','openrouter','gemini-api','ollama','lmstudio','custom')]
    [string]$Provider = 'detect',
    [string]$Model,
    [string]$BaseUrl,
    [string]$Name
)

$ErrorActionPreference = 'Stop'
$Cli = Join-Path $PSScriptRoot 'craft-anything-cli.exe'
if (-not (Test-Path -LiteralPath $Cli -PathType Leaf)) {
    throw "craft-anything-cli.exe not found next to Setup-Any-AI.ps1. Extract the entire Windows portable ZIP first."
}

function Invoke-Builder([string[]]$Arguments) {
    & $Cli @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "AI Builder command failed (exit code $LASTEXITCODE): $($Arguments -join ' ')"
    }
}

if ($Provider -eq 'detect') {
    Invoke-Builder -Arguments @('ai','detect')
    Write-Host ''
    Write-Host 'Installed coding agents can be selected with: .\Setup-Any-AI.ps1 -Provider codex'
    Write-Host 'Other supported choices: claude, copilot, gemini, opencode, qwen, goose, hermes, maki, antigravity.'
    Write-Host 'API choices: openai, anthropic, openrouter, gemini-api, ollama, lmstudio, custom.'
    exit 0
}
if ($Provider -eq 'list') {
    Invoke-Builder -Arguments @('ai','list')
    exit 0
}

# Local agent apps: authenticate with each agent's own official sign-in first.
$Agents = @{
    'claude'      = @('Claude Code','claude-code','claude')
    'codex'       = @('Codex','codex','codex')
    'copilot'     = @('GitHub Copilot','copilot','copilot')
    'gemini'      = @('Gemini CLI','gemini-cli','gemini')
    'antigravity' = @('Antigravity','antigravity','agy')
    'opencode'    = @('OpenCode','opencode','opencode')
    'hermes'      = @('Hermes Agent','hermes','hermes')
    'qwen'        = @('Qwen Code','qwen-code','qwen')
    'goose'       = @('Goose','goose','goose')
    'maki'        = @('Maki','maki','maki')
}
if ($Agents.ContainsKey($Provider)) {
    $Entry = $Agents[$Provider]
    $BackendName = if ($Name) { $Name } else { $Entry[0] }
    $Command = $Entry[2]
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "$Command is not installed or not on PATH. Install and sign in to the $BackendName CLI first, or set it up under Settings -> AI in the desktop app."
    }
    Invoke-Builder -Arguments @('ai','add',$BackendName,'--kind','agent_cli','--model',$Entry[1])
    if ($Model) {
        # Model selection is provider-dependent; the agent's native CLI must offer it.
        Invoke-Builder -Arguments @('ai','model',$BackendName,$Model)
    }
    Invoke-Builder -Arguments @('ai','builder',$BackendName)
    Write-Host "Builder selected: $BackendName. Open AI-Builder.exe to start building."
    exit 0
}

# API and OpenAI-compatible backends: keep API keys in environment or the
# application's own secret store, never in GitHub or a PowerShell command.
$Api = @{
    'openai'     = @('OpenAI','openai','OPENAI_API_KEY')
    'anthropic'  = @('Anthropic','anthropic','ANTHROPIC_API_KEY')
    'openrouter' = @('OpenRouter','openrouter','OPENROUTER_API_KEY')
    'gemini-api' = @('Gemini API','gemini','GEMINI_API_KEY')
    'ollama'     = @('Ollama','openai_compatible','')
    'lmstudio'   = @('LM Studio','openai_compatible','')
    'custom'     = @('Custom AI','openai_compatible','CUSTOM_AI_API_KEY')
}
$Entry = $Api[$Provider]
$BackendName = if ($Name) { $Name } else { $Entry[0] }
$Arguments = @('ai','add',$BackendName,'--kind',$Entry[1])

if ($Provider -eq 'ollama' -and -not $BaseUrl) { $BaseUrl = 'http://127.0.0.1:11434/v1' }
if ($Provider -eq 'lmstudio' -and -not $BaseUrl) { $BaseUrl = 'http://127.0.0.1:1234/v1' }
if ($Provider -eq 'custom' -and -not $BaseUrl) {
    throw 'A custom AI server needs -BaseUrl, e.g. https://your-server.example/v1'
}
if ($BaseUrl) { $Arguments += @('--base-url',$BaseUrl) }
if ($Model) { $Arguments += @('--model',$Model) }

$KeyVariable = $Entry[2]
if ($KeyVariable) {
    $Key = [Environment]::GetEnvironmentVariable($KeyVariable)
    if ([string]::IsNullOrWhiteSpace($Key)) {
        if ($Provider -ne 'custom') {
            throw "Set the $KeyVariable environment variable in this PowerShell session before selecting $BackendName. This is a separate API credential, not your chat-app login."
        }
    }
    else {
        $Arguments += @('--key-env',$KeyVariable)
    }
}
Invoke-Builder -Arguments $Arguments
Invoke-Builder -Arguments @('ai','builder',$BackendName)
Write-Host "Builder selected: $BackendName. Open AI-Builder.exe to start building."
