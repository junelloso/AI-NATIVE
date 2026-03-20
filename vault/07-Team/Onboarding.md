# Team Onboarding Guide — AI DevSecOps Team

> **For:** All team members joining the AI-NATIVE project

---

## How Documentation + Code Works

Everything lives in **one repository**: `github.com/junelloso/AI-NATIVE`

```
AI-NATIVE/
├── vault/          ← Obsidian documentation (open this folder in Obsidian)
├── .claude/        ← Claude Code MCP config (shared, auto-loaded)
├── CLAUDE.md       ← Claude's project context (auto-loaded every session)
└── ... (source code added here in Phase 1+)
```

You clone once. Obsidian opens `vault/`. Claude Code reads both.

---

## Prerequisites

```bash
# macOS
brew install git node

# Linux (Ubuntu/Debian)
sudo apt install git nodejs npm

# Claude Code CLI
npm install -g @anthropic-ai/claude-code

# MCP filesystem server (Claude reads your vault)
npm install -g @modelcontextprotocol/server-filesystem
```

**Obsidian Desktop:** https://obsidian.md — download and install for your OS.

---

## Step 1: Clone the Repository

```bash
# macOS / Linux
git clone https://github.com/junelloso/AI-NATIVE.git ~/repos/AI-NATIVE
cd ~/repos/AI-NATIVE
```

```powershell
# Windows
git clone https://github.com/junelloso/AI-NATIVE.git C:\repos\AI-NATIVE
cd C:\repos\AI-NATIVE
```

---

## Step 2: Open Vault in Obsidian

1. Open **Obsidian** → click **"Open folder as vault"**
2. Select the `vault/` folder inside your cloned repo:
   - macOS/Linux: `~/repos/AI-NATIVE/vault`
   - Windows: `C:\repos\AI-NATIVE\vault`
3. Trust the author when prompted

You now have all architecture docs, ADRs, threat models, and runbooks in Obsidian.

---

## Step 3: Configure Claude Code MCP

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

Edit `.claude/settings.local.json` — update the two paths to match your system:

```json
"args": ["/YOUR/PATH/TO/AI-NATIVE/vault"]
"args": ["/YOUR/PATH/TO/AI-NATIVE"]
```

Examples:
- macOS: `/Users/yourname/repos/AI-NATIVE/vault`
- Linux: `/home/yourname/repos/AI-NATIVE/vault`
- Windows: `C:/Users/yourname/repos/AI-NATIVE/vault`

> `settings.local.json` is gitignored — never commit it. Tokens go here, never in `settings.json`.

---

## Step 4: Verify Claude MCP Connection

```bash
cd ~/repos/AI-NATIVE
claude
```

Inside Claude Code, run:
```
/mcp
```

You should see `obsidian-docs` and `project-code` with **green** status.

Test it:
```
"Read the threat model in my vault and summarize the top 3 AI-specific risks."
```

---

## Day 1 Checklist

- [ ] Repo cloned
- [ ] Obsidian open on `vault/` folder inside the repo
- [ ] Claude MCP verified (`/mcp` shows green)
- [ ] Read `CLAUDE.md` (Claude's project context)
- [ ] Read `vault/04-Security/Threat-Model.md`
- [ ] Read `vault/05-DevSecOps/CICD-Pipeline-Design.md`
- [ ] Request access: GitHub repo write access, AWS/GCP, Anthropic API key

## Access Requests (send to IT Head)

| Resource | Who to ask |
|----------|-----------|
| GitHub repo write access | IT Head |
| Anthropic API key | IT Head |
| AWS/GCP access | Infrastructure Team Lead |
| Vault secrets (HashiCorp) | Infrastructure Team Lead |

---

## How We Work Day-to-Day

| Task | How |
|------|-----|
| Architecture questions | Ask Claude Code (it has vault + code context via MCP) |
| New technology decision | Create ADR in `vault/08-Decisions/` first |
| Before any PR | CI/CD pipeline auto-runs — do not bypass hooks |
| Updating docs | Edit Markdown in Obsidian → `git commit` → `git push` |
| Production incident | Auto-heal fires first → check Grafana → follow runbook |

## Getting Help

1. **Ask Claude Code first** — it has full project context via MCP
2. Check the vault docs (`vault/`)
3. Ask your team lead
4. Blockers → GitHub issue with `blocked` label
