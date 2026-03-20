# Team Onboarding Guide — AI DevSecOps Team

> **For:** All new team members joining the AI-NATIVE project

---

## Prerequisites

Install the following before your first day:

```bash
# Core tools
brew install git node python@3.12 go terraform kubectl helm

# Claude Code CLI
npm install -g @anthropic-ai/claude-code

# MCP servers for Claude
npm install -g @modelcontextprotocol/server-filesystem

# Optional but recommended
brew install k9s kubectx stern   # Kubernetes helpers
brew install jq yq               # JSON/YAML tools
```

## Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR-ORG/AI-NATIVE.git
cd AI-NATIVE
```

## Step 2: Set Up Your Obsidian Vault

1. Download Obsidian: https://obsidian.md
2. Create a new vault at `~/obsidian-vault/AI-NATIVE/`
3. Copy the scaffold from `docs/obsidian-vault-scaffold/` into your vault:
   ```bash
   cp -r docs/obsidian-vault-scaffold/* ~/obsidian-vault/AI-NATIVE/
   ```
4. Open Obsidian → Open folder as vault → select `~/obsidian-vault/AI-NATIVE/`
5. Install the **Obsidian Git** plugin (Community plugins) for auto-sync

## Step 3: Configure Claude Code MCP

```bash
# Copy the example local settings
cp .claude/settings.local.json.example .claude/settings.local.json
```

Edit `.claude/settings.local.json`:
- Replace `YOUR_USERNAME` with your actual username in the vault path
- Add your `GITHUB_PERSONAL_ACCESS_TOKEN` (never commit this!)
- Add DB connection string when you have access

## Step 4: Verify Claude Connection

```bash
# Open Claude Code in the project
claude

# Inside Claude Code, verify MCP servers
/mcp
```

You should see `obsidian-docs` and `project-code` listed.

## Step 5: Understand the Architecture

Ask Claude to walk you through the architecture:
```
"Read the architecture docs in my Obsidian vault and give me a 10-minute
technical briefing on the AI-NATIVE platform design."
```

## Day 1 Checklist

- [ ] Tools installed
- [ ] Repo cloned
- [ ] Obsidian vault set up with scaffold
- [ ] Claude Code MCP verified (`/mcp` shows green)
- [ ] Read `CLAUDE.md` (Claude's project context)
- [ ] Read `04-Security/Threat-Model.md`
- [ ] Read `07-Team/Coding-Standards.md`
- [ ] Set up your local `.env` from `.env.example`
- [ ] Request access: GitHub repo, AWS/GCP (infra team), Anthropic API key

## How We Work

- **Daily:** Claude Code is your pair programmer for ALL coding tasks
- **Before any tech decision:** Create an ADR draft in `08-Decisions/`
- **Before any PR merge:** CI/CD pipeline runs SAST, container scan, tests
- **Security incidents:** Follow `05-DevSecOps/Runbooks/Security-Incident.md`
- **Production issues:** Auto-heal handles first; if not, check Grafana → follow runbook

## Getting Help

1. Ask Claude Code first (it has full project context)
2. Check the Obsidian vault docs
3. Ask your team lead
4. For blockers: create a GitHub issue with `blocked` label
