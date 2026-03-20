# =============================================================================
# AI-NATIVE — Windows Laptop Setup Script
# Run this ONCE in PowerShell (Run as Administrator)
# =============================================================================
# Usage:
#   1. Open PowerShell as Administrator
#   2. Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
#   3. .\setup-laptop-windows.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  AI-NATIVE Laptop Setup for Windows" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# --- Config -------------------------------------------------------------------
$GITHUB_USER  = "junelloso"
$REPO_NAME    = "AI-NATIVE"
$REPO_URL     = "https://github.com/$GITHUB_USER/$REPO_NAME.git"
$REPO_PATH    = "$env:USERPROFILE\repos\$REPO_NAME"
$VAULT_PATH   = "$REPO_PATH\vault"
# Forward slashes for JSON/Node compatibility
$VAULT_PATH_J = $VAULT_PATH -replace "\\", "/"
$REPO_PATH_J  = $REPO_PATH  -replace "\\", "/"

# --- Helper -------------------------------------------------------------------
function Step($n, $msg) {
    Write-Host ""
    Write-Host "[$n] $msg" -ForegroundColor Yellow
}

function Ok($msg)   { Write-Host "    OK  $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "    !!  $msg" -ForegroundColor Magenta }
function Info($msg) { Write-Host "        $msg" -ForegroundColor Gray }

function CommandExists($cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

# =============================================================================
# Step 1 — Ensure winget is available
# =============================================================================
Step 1 "Checking winget (Windows Package Manager)"
if (-not (CommandExists "winget")) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
    exit 1
}
Ok "winget available"

# =============================================================================
# Step 2 — Install Git
# =============================================================================
Step 2 "Installing Git"
if (CommandExists "git") {
    Ok "Git already installed: $(git --version)"
} else {
    Info "Installing Git via winget..."
    winget install --id Git.Git -e --source winget --silent
    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    Ok "Git installed"
}

# =============================================================================
# Step 3 — Install Node.js LTS (includes npm)
# =============================================================================
Step 3 "Installing Node.js LTS"
if (CommandExists "node") {
    Ok "Node.js already installed: $(node --version)"
} else {
    Info "Installing Node.js LTS via winget..."
    winget install --id OpenJS.NodeJS.LTS -e --source winget --silent
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    Ok "Node.js installed"
}

# =============================================================================
# Step 4 — Install Obsidian
# =============================================================================
Step 4 "Installing Obsidian"
$obsidianInstalled = winget list --id Obsidian.Obsidian 2>$null | Select-String "Obsidian"
if ($obsidianInstalled) {
    Ok "Obsidian already installed"
} else {
    Info "Installing Obsidian via winget..."
    winget install --id Obsidian.Obsidian -e --source winget --silent
    Ok "Obsidian installed"
}

# =============================================================================
# Step 5 — Install Claude Code CLI
# =============================================================================
Step 5 "Installing Claude Code CLI"
if (CommandExists "claude") {
    Ok "Claude Code already installed"
} else {
    Info "Installing @anthropic-ai/claude-code..."
    npm install -g @anthropic-ai/claude-code
    Ok "Claude Code installed"
}

# =============================================================================
# Step 6 — Install MCP Filesystem Server
# =============================================================================
Step 6 "Installing MCP Filesystem Server"
$mcpCheck = npm list -g @modelcontextprotocol/server-filesystem 2>$null | Select-String "server-filesystem"
if ($mcpCheck) {
    Ok "MCP server already installed"
} else {
    Info "Installing @modelcontextprotocol/server-filesystem..."
    npm install -g @modelcontextprotocol/server-filesystem
    Ok "MCP server installed"
}

# =============================================================================
# Step 7 — Clone Repository
# =============================================================================
Step 7 "Cloning AI-NATIVE repository"
if (Test-Path "$REPO_PATH\.git") {
    Ok "Repo already cloned at $REPO_PATH"
    Info "Pulling latest changes..."
    git -C $REPO_PATH pull origin main 2>$null
    git -C $REPO_PATH pull origin claude/ai-native-enterprise-app-wXyeU 2>$null
} else {
    $reposDir = "$env:USERPROFILE\repos"
    if (-not (Test-Path $reposDir)) {
        New-Item -ItemType Directory -Path $reposDir | Out-Null
    }
    Info "Cloning $REPO_URL ..."
    git clone $REPO_URL $REPO_PATH
    Ok "Cloned to $REPO_PATH"
}

# =============================================================================
# Step 8 — Create settings.local.json
# =============================================================================
Step 8 "Configuring Claude Code MCP (settings.local.json)"
$settingsPath = "$REPO_PATH\.claude\settings.local.json"
if (Test-Path $settingsPath) {
    Warn "settings.local.json already exists — skipping to avoid overwriting your config"
    Info "Location: $settingsPath"
} else {
    $json = @"
{
  "_note": "This file is gitignored. Add personal tokens and connection strings here.",
  "mcpServers": {
    "obsidian-docs": {
      "command": "mcp-server-filesystem",
      "args": [
        "$VAULT_PATH_J"
      ]
    },
    "project-code": {
      "command": "mcp-server-filesystem",
      "args": [
        "$REPO_PATH_J"
      ]
    },
    "postgres-db": {
      "_disabled": true,
      "_enable_when": "Phase 1 — PostgreSQL created. Remove _disabled to activate.",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:password@localhost:5432/ai_native_db"
      }
    },
    "github": {
      "_disabled": true,
      "_enable_when": "Phase 1 — Add your GitHub PAT here. Remove _disabled to activate.",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_REPLACE_WITH_YOUR_TOKEN"
      }
    }
  }
}
"@
    $json | Set-Content -Path $settingsPath -Encoding UTF8
    Ok "Created $settingsPath"
}

# =============================================================================
# Step 9 — Open Obsidian on the vault
# =============================================================================
Step 9 "Opening Obsidian with the vault"
if (Test-Path $VAULT_PATH) {
    Info "Launching Obsidian..."
    Info "When prompted, click 'Open' or 'Trust author'"
    Start-Process "obsidian" "--path `"$VAULT_PATH`"" -ErrorAction SilentlyContinue
    if ($LASTEXITCODE -ne 0 -or -not (CommandExists "obsidian")) {
        Warn "Could not auto-launch Obsidian. Open it manually:"
        Info "  Obsidian -> Open folder as vault -> $VAULT_PATH"
    } else {
        Ok "Obsidian launched with vault at $VAULT_PATH"
    }
} else {
    Warn "Vault folder not found at $VAULT_PATH — check repo clone"
}

# =============================================================================
# Summary
# =============================================================================
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Repo:   $REPO_PATH" -ForegroundColor White
Write-Host "  Vault:  $VAULT_PATH" -ForegroundColor White
Write-Host "  MCP:    $settingsPath" -ForegroundColor White
Write-Host ""
Write-Host "  Next — verify Claude MCP connection:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    cd $REPO_PATH" -ForegroundColor Cyan
Write-Host "    claude" -ForegroundColor Cyan
Write-Host "    /mcp       <- should show obsidian-docs + project-code green" -ForegroundColor Cyan
Write-Host ""
Write-Host "  If Obsidian didn't open automatically:" -ForegroundColor Yellow
Write-Host "    Obsidian -> Open folder as vault -> $VAULT_PATH" -ForegroundColor Cyan
Write-Host ""
