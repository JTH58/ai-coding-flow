# AI Coding Flow

**A modular system prompt framework for AI coding assistants — with persistent memory, structured methodology, and verifiable outputs.**

[繁體中文版](#繁體中文) | [English](#english)

---

<a id="english"></a>

## English

### The Problem

Every time you start a new AI coding session, you lose everything — the architecture decisions you discussed, the bugs you found, the conventions you agreed on. Your AI assistant has amnesia.

Most AI tools offer some form of memory, but it's locked inside their platform. Switch from Claude Code to Gemini CLI? Start over. Want to version-control your AI's knowledge? Can't.

### The Solution

AI Coding Flow gives your AI:

- **🧠 Memory that lives in Git** — AI-Brain is just Markdown files in a Git repo. Version-controlled, diffable, greppable. You own your data.
- **🔌 Modular Skills** — 11 self-contained behavioral modules. Enable what you need, customize what you want, create your own.
- **🏗️ Structured methodology** — Enforces DDD → BDD → TDD with user checkpoints, so your AI thinks before it codes.
- **✅ Verifiable outputs** — Every response ends with a stamp proving what was checked and what wasn't.
- **📚 Cross-project learning** — Common AI-Brain accumulates wisdom across all your projects. Fix a Docker DNS issue once, every project knows about it.
- **📦 Zero dependencies** — No database, no server, no API keys. Just `git clone` and go.

### How It's Different

| Approach | Platform-locked? | Version-controlled? | Cross-tool? | Survives tool migration? |
|----------|:-:|:-:|:-:|:-:|
| ChatGPT Memory | ✅ | ❌ | ❌ | ❌ |
| Claude Projects | ✅ | ❌ | ❌ | ❌ |
| CLAUDE.md / GEMINI.md | ❌ | ✅ | ❌ (tool-specific) | ❌ |
| **AI Coding Flow** | **❌** | **✅** | **✅** | **✅** |

---

### Architecture

v5.0 uses a **modular Skill architecture**. The system prompt is a thin orchestrator that delegates specialized behavior to self-contained Skills.

```
┌─────────────────────────────────────────────┐
│  System Prompt (system-prompt-v5.md)        │  ← Orchestrator
│  Core identity, response principles,        │
│  skill loading rules                        │
├─────────────────────────────────────────────┤
│  Skills (skills/*/SKILL.md)                 │  ← Modular behavior
│  11 self-contained modules with             │
│  triggers, rules, and authority levels      │
├─────────────────────────────────────────────┤
│  AI-Brain (_common/ + _example/)            │  ← Persistent memory
│  Git-versioned Markdown files               │
│  Project AI-Brain + Common AI-Brain               │
└─────────────────────────────────────────────┘
```

#### Skills Reference

| Skill | Type | Purpose |
|-------|------|---------|
| `warm-persona` | Always Active | Tone, communication style, dynamic role adaptation |
| `response-protocol` | Always Active | Thinking protocol, response priority, action authority, decision dimensions |
| `ai-brain` | Always Active | Long-term memory system, AI-Brain loading procedure |
| `ddd-bdd-tdd` | Conditional | Structured development: Domain → Behavior → Test-Driven, codebase learning |
| `code-verification` | Conditional | Verification loop, escalation protocol, response ending stamps |
| `tech-defaults` | Conditional | Default tech stack and technology selection guidance |
| `git-workflow` | Conditional | Commit conventions, branch naming, PR standards |
| `conversation-logger` | Conditional | Observe and record recurring patterns |
| `skill-extractor` | Conditional | Analyze patterns and propose new Skills |
| `brain-distiller` | Conditional | Distill bloated AI-Brain files: cluster, merge, archive stale entries |
| `prompt-engineer` | Conditional | Diagnose and fix rule violations in Skills |

> **Always Active** Skills load in every conversation. **Conditional** Skills activate only when their trigger conditions are met (e.g., `ddd-bdd-tdd` activates for new features, `git-workflow` activates when committing).

---

### Project Structure

```
ai-coding-flow/
├── README.md
├── LICENSE
├── .gitignore
├── setup.sh                        ← Multi-tool installer (Claude / Gemini / Codex)
├── system-prompt-v5.md              ← Core system prompt (orchestrator)
├── claude/
│   └── settings.json                ← Claude Code settings template (hooks + statusLine)
├── gemini/
│   └── settings.json                ← Gemini CLI hook template (2 hooks)
├── scripts/
│   ├── brain-loader.sh              ← SessionStart hook (AI-Brain Map injection)
│   ├── brain-gate.sh                ← PreToolUse hook (forces text response before tools)
│   ├── no-coauthor-guard.sh         ← PreToolUse hook (blocks Co-Authored-By in commits)
│   ├── journal-reminder.sh         ← PreToolUse hook (reminds to update journal.md)
│   └── statusline.sh               ← Status line (model, context bar, diff stats, branch)
├── _common/                         ← Common AI-Brain templates
│   ├── _catalog.json                ← Category index (auto-managed by AI)
│   ├── SCHEMA.md                    ← Data structure reference
│   ├── preferences.md               ← Personal preferences template
│   ├── troubleshooting.md           ← Cross-project troubleshooting template
│   ├── toolchain.md                 ← Toolchain experience template
│   ├── conversation-patterns.md     ← Conversation pattern log (skill-owned)
│   ├── skill-experience.md          ← Skill tuning and pitfall log (skill-owned)
│   └── prompt-violations.md         ← Rule violation tracker (skill-owned)
├── _example/                        ← Example AI-Brain folder (reference for new projects)
│   ├── architecture_decisions.md
│   ├── todo.md
│   ├── known_issues.md
│   └── journal.md
└── skills/                          ← Modular Skills (v5.0)
    ├── warm-persona/SKILL.md
    ├── response-protocol/SKILL.md
    ├── ai-brain/SKILL.md
    ├── ddd-bdd-tdd/SKILL.md
    ├── code-verification/SKILL.md
    ├── git-workflow/SKILL.md
    ├── tech-defaults/SKILL.md
    ├── conversation-logger/SKILL.md
    ├── brain-distiller/SKILL.md
    ├── skill-extractor/SKILL.md
    └── prompt-engineer/SKILL.md
```

---

### Quick Start

#### 1. Clone the framework

```bash
git clone https://github.com/JTH58/ai-coding-flow.git
```

#### 2. Set up AI-Brain (your private memory)

AI-Brain is a **separate repo** that lives alongside your project directories. The AI reads and writes to it during work.

```bash
# Create and initialize your AI-Brain repo
mkdir -p ~/Documents/Github/ai-brain
cd ~/Documents/Github/ai-brain
git init

# Copy templates from the framework
cp -r ~/Documents/Github/ai-coding-flow/_common .
cp -r ~/Documents/Github/ai-coding-flow/_example .

git add -A && git commit -m "init: AI-Brain"
```

> **Recommended:** Push to a private GitHub repo to back up your AI-Brain and enable cross-machine access.
>
> ```bash
> # Create a private repo on GitHub first, then:
> git remote add origin https://github.com/<your-username>/ai-brain.git
> git push -u origin main
> ```

Your directory structure should look like:

```
~/Documents/Github/
├── ai-coding-flow/      ← This framework (public)
├── ai-brain/            ← Your AI-Brain data (private)
│   ├── _common/         ← Shared across all projects
│   └── _example/        ← Templates for new projects
└── my-project/          ← Your code project
```

> The AI automatically derives the AI-Brain path from your working directory: `$(dirname "$PWD")/ai-brain/`. As long as `ai-brain/` sits beside your project folders, it just works.

#### 3. Apply to your AI tool

Run the unified installer and select your tool:

```bash
cd ~/Documents/Github/ai-coding-flow
./setup.sh
```

The installer supports **Claude Code**, **Gemini CLI**, and **OpenAI Codex**. You can set up one tool or all three at once.

<details>
<summary><b>Claude Code (recommended — full Skill support)</b></summary>

Claude Code natively supports the modular Skill architecture via `CLAUDE.md` + custom Skills.

**What `setup.sh` does (option 1):**
- Symlinks all Skills to `~/.claude/skills/`
- Symlinks `system-prompt-v5.md` to `~/.claude/CLAUDE.md`
- Symlinks all scripts to `~/.claude/scripts/`
- Merges settings into `~/.claude/settings.json` (hooks + statusLine, idempotent)

Edits to project files take effect immediately — no manual sync needed.

> Claude Code reads `CLAUDE.md` hierarchically: global (`~/.claude/CLAUDE.md`) applies everywhere, project-level (`.claude/CLAUDE.md`) adds project-specific context. Skills in `~/.claude/skills/` are available globally.

**What the hooks do:**
- **`brain-loader.sh` (SessionStart)** — Injects a **AI-Brain Map** (~20 lines): file paths, descriptions, and entry counts. No full file contents are injected. The AI reads the user's message, selects relevant files, and reads them on demand (directly if < 15 entries, via Explore sub-agent if ≥ 15). The `=== AI BRAIN ===` marker tells the AI to skip manual loading.
- **`brain-gate.sh` (PreToolUse)** — Blocks the first tool call after AI-Brain loading, forcing the AI to produce a text response first. This prevents the AI from silently jumping into code changes before acknowledging context. Subsequent tool calls pass through normally.
- **`no-coauthor-guard.sh` (PreToolUse:Bash)** — Blocks `git commit` commands that contain `Co-Authored-By` trailers, enforcing the git-workflow Skill rule.
- **`journal-reminder.sh` (PreToolUse:Edit|Write|NotebookEdit)** — Non-blocking reminder to update `journal.md` in the same response when editing project files. Skips AI-Brain files. Works with the Stop hook (hard block) as a two-layer defense.

**Status line:**
- **`statusline.sh`** — Displays a 2-line status bar: model name + context window usage bar (color-coded green/yellow/red) on line 1, lines added/removed + Git branch + worktree name on line 2.

If no AI-Brain repo exists next to your project, the AI-Brain hooks silently do nothing.

**Updating:** When the framework releases a new version, just pull — symlinks pick up changes automatically:

```bash
cd ~/Documents/Github/ai-coding-flow && git pull
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

**What `setup.sh` does (option 2):**
- Generates a bundled prompt at `~/.gemini/GEMINI.md` (system-prompt + essential Skills)
- Symlinks `brain-loader.sh` and `brain-gate.sh` to `~/.gemini/scripts/`
- Merges hooks into `~/.gemini/settings.json`

The bundled prompt includes `response-protocol` + `ai-brain` + `code-verification` — the recommended minimum for structured AI behavior.

> **Note:** Gemini CLI hook format may differ from the template. Test with `gemini` and adjust `~/.gemini/settings.json` if needed.

**Manual alternative (per-project):**

```bash
mkdir -p .gemini
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md .gemini/system.md
```

> For full Skill functionality, append relevant `skills/*/SKILL.md` contents to the prompt file.

</details>

<details>
<summary><b>OpenAI Codex</b></summary>

**What `setup.sh` does (option 3):**
- Generates a bundled prompt at `~/.codex/AGENTS.md` (system-prompt + essential Skills)

Codex has no lifecycle hooks, so AI-Brain loading relies on prompt-level instructions (the `ai-brain` Skill's manual path).

**Manual alternative (per-project):**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md AGENTS.md
```

> For full Skill functionality, append relevant `skills/*/SKILL.md` contents to `AGENTS.md`.

</details>

<details>
<summary><b>Other AI Tools</b></summary>

The framework works with any AI tool that accepts custom system prompts:

1. Copy the content of `system-prompt-v5.md` into your tool's system prompt field
2. For full methodology, append the contents of relevant `skills/*/SKILL.md` files
3. Ensure the AI has shell access to read/write AI-Brain files

> The system prompt is written in English by design — English instructions yield better AI compliance and ~17% fewer tokens compared to Chinese instructions for the same semantics.

</details>

---

### How It Works

#### AI-Brain: Memory That Lives in Git

Your AI reads and writes to plain Markdown files — no proprietary format, no platform lock-in.

```
~/Documents/Github/ai-brain/
├── _common/                 ← Shared across ALL projects
│   ├── preferences.md       ← "I prefer Prisma over Drizzle"
│   └── troubleshooting.md   ← "Docker DNS fix: use host.docker.internal"
├── my-web-app/              ← Project-specific memory (auto-created)
│   ├── architecture_decisions.md  ← "Next.js 15 + Tailwind + Prisma"
│   └── known_issues.md      ← "SSR hydration bug on /dashboard"
└── my-mobile-app/
    └── ...
```

Because it's Git:
- `git log` shows when decisions were made and why
- `git diff` shows what changed between sessions
- `git branch` lets you experiment with different architectural approaches
- Team members can share project knowledge via pull requests

#### DDD → BDD → TDD: Think Before You Code

Activated automatically for new features and complex logic (via the `ddd-bdd-tdd` skill):

```
1. DDD Phase → AI defines domain terms, entities, business rules
                You confirm ✓

2. BDD Phase → AI writes Given-When-Then scenarios
                You confirm ✓

3. TDD Phase → AI writes failing tests first, then implements
                Tests pass ✓ → Code delivered
```

Each phase requires your explicit approval before proceeding. Simple bug fixes and config changes skip this entirely.

> Before writing tests, the AI studies 2+ similar implementations in your codebase to match existing patterns and reuse existing utilities.

#### Verification Stamps

Code responses end with a verification-phase stamp (via the `code-verification` skill):

| Stamp | Meaning |
|-------|---------|
| `📌 DDD Complete — Awaiting Confirmation` | Domain model ready for review |
| `📌 BDD Complete — Awaiting Confirmation` | Scenarios ready for review |
| `✅ Tests: [X/X] \| Build: [Command]` | Code delivered with passing tests |
| `✅ Build Verified: [Command]` | Code delivered, build confirmed |
| `⚠️ Verification Skipped: [Reason]` | Discussion only, no code |

> If the same error persists after 3 attempts, the AI stops, documents what was tried, and proposes a fundamentally different approach (Escalation Protocol).

---

### Customization Guide

This framework is designed to be forked and personalized. Here's what to change and where:

#### Persona & Language

| What to change | File | Default |
|----------------|------|---------|
| How AI addresses you | `system-prompt-v5.md` → Core Identity table | `"dear" (親愛的)` |
| Output language | `system-prompt-v5.md` → Core Identity table | `Traditional Chinese (繁體中文)` |
| Personality tone | `system-prompt-v5.md` → Core Identity table | `Opinionated Neutrality` |
| Communication style | `skills/warm-persona/SKILL.md` | Warm, Pyramid Principle |

#### Tech Stack Defaults

Edit `skills/tech-defaults/SKILL.md` to change default technology choices (used when no project-specific stack is defined).

> **Tip:** These are just defaults. Each project's `architecture_decisions.md` in AI-Brain overrides them. You don't need to modify Skills for per-project changes.

#### BDD Keywords

Edit `skills/ddd-bdd-tdd/SKILL.md` to change Gherkin keywords (default: `假如 / 當 / 那麼 / 而且`).

#### Git Conventions

Edit `skills/git-workflow/SKILL.md` to change commit message format, branch naming, and PR standards.

#### Creating Custom Skills

You can create your own Skills by adding a `SKILL.md` file in a new subdirectory under `skills/`:

```
skills/
└── my-custom-skill/
    └── SKILL.md
```

Each `SKILL.md` needs a YAML front matter with `name` and `description` (including trigger conditions), followed by the skill's rules and procedures. See existing Skills for reference.

---

### Compatibility

This framework is primarily designed for **Claude Code** with full Skill support. It also works with other AI tools with varying levels of functionality:

| Tool | System Prompt | Skills | AI-Brain | Methodology |
|------|:-:|:-:|:-:|:-:|
| Claude Code | ✅ | ✅ Native | ✅ | ✅ Full |
| Gemini CLI | ✅ | ⚠️ Manual append | ✅ | ✅ Full |
| OpenAI Codex | ✅ | ⚠️ Manual append | ✅ | ✅ Full |
| Other CLI tools | ✅ | ⚠️ Manual append | ✅ | ✅ Full |

> **Verification stamp compliance** may differ between models — some follow it 100%, others need reinforcement. If your AI isn't following a specific rule consistently, the issue is likely attention competition in the prompt, not a bug. Feel free to open an issue.

### Contributing

Contributions are welcome! Feel free to:

- Open issues for bugs, suggestions, or rule compliance problems
- Submit PRs for new Skills, improvements, or translations
- Share your custom Skills with the community

### License

[MIT](LICENSE)

---

<a id="繁體中文"></a>

## 繁體中文

### 問題

每次啟動新的 AI 編程對話，一切都會遺失 — 討論過的架構決策、發現的 Bug、約定的慣例。你的 AI 助手有失憶症。

大多數 AI 工具提供某種形式的記憶功能，但都鎖在自家平台裡。從 Claude Code 換到 Gemini CLI？重新開始。想版本控制 AI 的知識？做不到。

### 解決方案

AI Coding Flow 讓你的 AI 擁有：

- **🧠 活在 Git 裡的記憶** — AI-Brain 只是 Git repo 中的 Markdown 檔案。可版控、可 diff、可 grep。資料完全屬於你。
- **🔌 模組化 Skills** — 11 個獨立的行為模組。啟用你需要的，自訂你想改的，建立你自己的。
- **🏗️ 結構化方法論** — 強制執行 DDD → BDD → TDD 並設立用戶檢查點，讓 AI 先思考再寫程式。
- **✅ 可驗證的輸出** — 每個回應結尾都有戳記，證明驗證了什麼、跳過了什麼。
- **📚 跨專案學習** — Common AI-Brain 在所有專案間積累智慧。修過一次 Docker DNS 問題，所有專案都知道解法。
- **📦 零依賴** — 不需要資料庫、不需要伺服器、不需要 API key。`git clone` 就能用。

### 有何不同

| 方案 | 平台綁定？ | 可版控？ | 跨工具？ | 換工具後保留？ |
|------|:-:|:-:|:-:|:-:|
| ChatGPT Memory | ✅ | ❌ | ❌ | ❌ |
| Claude Projects | ✅ | ❌ | ❌ | ❌ |
| CLAUDE.md / GEMINI.md | ❌ | ✅ | ❌（工具專用） | ❌ |
| **AI Coding Flow** | **❌** | **✅** | **✅** | **✅** |

---

### 架構

v5.0 採用**模組化 Skill 架構**。系統提示詞是精簡的協調者，將專業行為委派給獨立的 Skill。

```
┌─────────────────────────────────────────────┐
│  系統提示詞 (system-prompt-v5.md)            │  ← 協調者
│  核心身份、回應原則、Skill 載入規則           │
├─────────────────────────────────────────────┤
│  Skills (skills/*/SKILL.md)                 │  ← 模組化行為
│  11 個獨立模組，各有觸發條件、規則、授權等級  │
├─────────────────────────────────────────────┤
│  AI-Brain (_common/ + _example/)            │  ← 持久記憶
│  Git 版控的 Markdown 檔案                    │
│  Project AI-Brain + Common AI-Brain               │
└─────────────────────────────────────────────┘
```

#### Skills 總覽

| Skill | 類型 | 用途 |
|-------|------|------|
| `warm-persona` | 常駐 | 語氣、溝通風格、動態角色適應 |
| `response-protocol` | 常駐 | 思考協議、回應優先順序、行動授權、決策維度 |
| `ai-brain` | 常駐 | 長期記憶系統、AI-Brain 載入程序 |
| `ddd-bdd-tdd` | 條件觸發 | 結構化開發：領域驅動 → 行為驅動 → 測試驅動、既有程式碼學習 |
| `code-verification` | 條件觸發 | 驗證迴圈、升級協議、回應結尾戳記 |
| `tech-defaults` | 條件觸發 | 預設技術棧與選型指南 |
| `git-workflow` | 條件觸發 | 提交約定、分支命名、PR 標準 |
| `conversation-logger` | 條件觸發 | 觀察並記錄重複模式 |
| `skill-extractor` | 條件觸發 | 分析模式並提議新 Skill |
| `brain-distiller` | 條件觸發 | 蒸餾膨脹的 AI-Brain 檔案：聚類、合併、歸檔過期條目 |
| `prompt-engineer` | 條件觸發 | 診斷並修復 Skill 規則違反 |

> **常駐** Skill 在每次對話中載入。**條件觸發** Skill 僅在觸發條件成立時啟動（如 `ddd-bdd-tdd` 在新功能開發時啟動，`git-workflow` 在提交時啟動）。

---

### 專案結構

```
ai-coding-flow/
├── README.md
├── LICENSE
├── .gitignore
├── setup.sh                        ← 多工具安裝腳本（Claude / Gemini / Codex）
├── system-prompt-v5.md              ← 核心系統提示詞（協調者）
├── claude/
│   └── settings.json                ← Claude Code 設定模板（hooks + statusLine）
├── gemini/
│   └── settings.json                ← Gemini CLI hook 模板（2 個 hook）
├── scripts/
│   ├── brain-loader.sh              ← SessionStart hook（AI-Brain Map 注入到 context）
│   ├── brain-gate.sh                ← PreToolUse hook（強制先回應再用工具）
│   ├── no-coauthor-guard.sh         ← PreToolUse hook（攔截 Co-Authored-By 提交）
│   ├── journal-reminder.sh         ← PreToolUse hook（提醒更新 journal.md）
│   └── statusline.sh               ← 狀態列（模型、context 進度條、diff 統計、分支）
├── _common/                         ← Common AI-Brain 模板
│   ├── _catalog.json                ← 分類索引（AI 自動管理）
│   ├── SCHEMA.md                    ← 資料結構參考
│   ├── preferences.md               ← 個人偏好模板
│   ├── troubleshooting.md           ← 跨專案踩坑紀錄模板
│   ├── toolchain.md                 ← 工具鏈經驗模板
│   ├── conversation-patterns.md     ← 會話模式日誌（Skill 專用）
│   ├── skill-experience.md          ← Skill 調校與踩坑日誌（Skill 專用）
│   └── prompt-violations.md         ← 規則違反追蹤（Skill 專用）
├── _example/                        ← 範例 AI-Brain 資料夾（新專案參考用）
│   ├── architecture_decisions.md
│   ├── todo.md
│   ├── known_issues.md
│   └── journal.md
└── skills/                          ← 模組化 Skills (v5.0)
    ├── warm-persona/SKILL.md
    ├── response-protocol/SKILL.md
    ├── ai-brain/SKILL.md
    ├── ddd-bdd-tdd/SKILL.md
    ├── code-verification/SKILL.md
    ├── git-workflow/SKILL.md
    ├── tech-defaults/SKILL.md
    ├── conversation-logger/SKILL.md
    ├── brain-distiller/SKILL.md
    ├── skill-extractor/SKILL.md
    └── prompt-engineer/SKILL.md
```

---

### 快速開始

#### 1. Clone 框架

```bash
git clone https://github.com/JTH58/ai-coding-flow.git
```

#### 2. 設定 AI-Brain（你的私有記憶）

AI-Brain 是**獨立的 repo**，與你的專案目錄並排放置。AI 工作時會自動讀寫。

```bash
# 建立並初始化你的 AI-Brain repo
mkdir -p ~/Documents/Github/ai-brain
cd ~/Documents/Github/ai-brain
git init

# 從框架複製模板
cp -r ~/Documents/Github/ai-coding-flow/_common .
cp -r ~/Documents/Github/ai-coding-flow/_example .

git add -A && git commit -m "init: AI-Brain"
```

> **建議：** 推送到私有 GitHub repo，備份你的 AI-Brain 並支援跨機器存取。
>
> ```bash
> # 先在 GitHub 建立私有 repo，然後：
> git remote add origin https://github.com/<your-username>/ai-brain.git
> git push -u origin main
> ```

你的目錄結構應該像這樣：

```
~/Documents/Github/
├── ai-coding-flow/      ← 本框架（公開）
├── ai-brain/            ← 你的 AI-Brain 資料（私有）
│   ├── _common/         ← 所有專案共享
│   └── _example/        ← 新專案的模板
└── my-project/          ← 你的程式碼專案
```

> AI 會從你的工作目錄自動推導 AI-Brain 路徑：`$(dirname "$PWD")/ai-brain/`。只要 `ai-brain/` 和你的專案資料夾放在同一層，就能自動運作。

#### 3. 套用到你的 AI 工具

執行統一安裝腳本並選擇你的工具：

```bash
cd ~/Documents/Github/ai-coding-flow
./setup.sh
```

安裝腳本支援 **Claude Code**、**Gemini CLI** 和 **OpenAI Codex**。你可以一次設定一個工具或全部一起。

<details>
<summary><b>Claude Code（推薦 — 完整 Skill 支援）</b></summary>

Claude Code 透過 `CLAUDE.md` + 自訂 Skills 原生支援模組化 Skill 架構。

**`setup.sh` 做了什麼（選項 1）：**
- 將所有 Skills symlink 到 `~/.claude/skills/`
- 將 `system-prompt-v5.md` symlink 到 `~/.claude/CLAUDE.md`
- 將所有腳本 symlink 到 `~/.claude/scripts/`
- 將設定合併到 `~/.claude/settings.json`（hooks + statusLine，冪等操作）

編輯專案檔後立即生效，不需手動同步。

> Claude Code 階層式讀取 `CLAUDE.md`：全域（`~/.claude/CLAUDE.md`）適用所有專案，專案級（`.claude/CLAUDE.md`）添加專案上下文。`~/.claude/skills/` 中的 Skills 全域可用。

**Hook 做了什麼：**
- **`brain-loader.sh`（SessionStart）** — 注入 **AI-Brain Map**（約 20 行）：檔案路徑、描述、條目數。不注入完整檔案內容。AI 讀取使用者訊息後選擇相關檔案按需讀取（< 15 條直接讀、≥ 15 條派 Explore sub-agent 蒸餾）。`=== AI BRAIN ===` 標記告訴 AI 跳過手動載入。
- **`brain-gate.sh`（PreToolUse）** — 在 AI-Brain 載入後攔截第一個 tool call，強制 AI 先產生文字回應。這可防止 AI 在未確認 context 的情況下直接跳入修改程式碼。後續 tool call 正常放行。
- **`no-coauthor-guard.sh`（PreToolUse:Bash）** — 攔截含有 `Co-Authored-By` 的 `git commit` 命令，強制遵守 git-workflow Skill 規則。
- **`journal-reminder.sh`（PreToolUse:Edit|Write|NotebookEdit）** — 編輯專案檔時非阻斷式提醒更新 `journal.md`，跳過 AI-Brain 檔案。與 Stop hook（硬攔截）形成雙層防線。

**狀態列：**
- **`statusline.sh`** — 顯示 2 行狀態列：第 1 行為模型名稱 + context window 使用量進度條（綠/黃/紅），第 2 行為行數增減 + Git 分支 + worktree 名稱。

若專案旁邊沒有 AI-Brain repo，AI-Brain hook 靜默不做任何事。

**更新：** 框架發布新版本時，拉取即可 — symlink 會自動反映變更：

```bash
cd ~/Documents/Github/ai-coding-flow && git pull
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

**`setup.sh` 做了什麼（選項 2）：**
- 在 `~/.gemini/GEMINI.md` 生成打包提示詞（系統提示詞 + 必要 Skills）
- 將 `brain-loader.sh` 和 `brain-gate.sh` symlink 到 `~/.gemini/scripts/`
- 將 hooks 合併到 `~/.gemini/settings.json`

打包的提示詞包含 `response-protocol` + `ai-brain` + `code-verification` — 結構化 AI 行為的建議最小組合。

> **備註：** Gemini CLI 的 hook 格式可能與模板不同。使用 `gemini` 測試後視需要調整 `~/.gemini/settings.json`。

**手動替代方案（單一專案）：**

```bash
mkdir -p .gemini
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md .gemini/system.md
```

> 如需完整 Skill 功能，將相關 `skills/*/SKILL.md` 內容附加到提示詞檔案。

</details>

<details>
<summary><b>OpenAI Codex</b></summary>

**`setup.sh` 做了什麼（選項 3）：**
- 在 `~/.codex/AGENTS.md` 生成打包提示詞（系統提示詞 + 必要 Skills）

Codex 沒有生命週期 hook，AI-Brain 載入依賴提示詞層級的指令（`ai-brain` Skill 的手動路徑）。

**手動替代方案（單一專案）：**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md AGENTS.md
```

> 如需完整 Skill 功能，將相關 `skills/*/SKILL.md` 內容附加到 `AGENTS.md`。

</details>

<details>
<summary><b>其他 AI 工具</b></summary>

本框架適用於任何接受自訂系統提示詞的 AI 工具：

1. 將 `system-prompt-v5.md` 的內容複製到工具的系統提示詞欄位
2. 如需完整方法論，附加相關 `skills/*/SKILL.md` 的內容
3. 確保 AI 有 Shell 存取權限以讀寫 AI-Brain 檔案

> 提示詞刻意使用全英文 — 英文指令的 AI 遵從率更高，且比中文指令節省約 17% token。

</details>

---

### 運作原理

#### AI-Brain：活在 Git 裡的記憶

AI 讀寫純 Markdown 檔案 — 沒有專有格式，沒有平台鎖定。

```
~/Documents/Github/ai-brain/
├── _common/                 ← 所有專案共享
│   ├── preferences.md       ← 「我偏好 Prisma 而非 Drizzle」
│   └── troubleshooting.md   ← 「Docker DNS 修復：用 host.docker.internal」
├── my-web-app/              ← 專案特定記憶（自動建立）
│   ├── architecture_decisions.md  ← 「Next.js 15 + Tailwind + Prisma」
│   └── known_issues.md      ← 「/dashboard 的 SSR hydration bug」
└── my-mobile-app/
    └── ...
```

因為是 Git：
- `git log` 顯示何時做了什麼決策、為什麼
- `git diff` 顯示兩次對話之間的知識變化
- `git branch` 讓你實驗不同的架構方向
- 團隊成員可以透過 Pull Request 共享專案知識

#### DDD → BDD → TDD：先思考再寫程式

遇到新功能或複雜邏輯時自動啟動（透過 `ddd-bdd-tdd` skill）：

```
1. DDD 階段 → AI 定義領域術語、實體、業務規則
                你確認 ✓

2. BDD 階段 → AI 撰寫 假如-當-那麼 場景
                你確認 ✓

3. TDD 階段 → AI 先寫失敗測試，再實作
                測試通過 ✓ → 交付程式碼
```

每個階段都需要你明確同意才會推進。簡單的 bug 修復和設定變更會自動跳過。

> 在撰寫測試前，AI 會在你的 codebase 中找 2 個以上類似實作，學習既有模式並重用既有工具。

#### 驗證戳記

涉及程式碼的回應需有一個驗證階段戳記（透過 `code-verification` skill）：

| 戳記 | 含義 |
|------|------|
| `📌 DDD Complete — Awaiting Confirmation` | 領域模型待審查 |
| `📌 BDD Complete — Awaiting Confirmation` | 場景待審查 |
| `✅ Tests: [X/X] \| Build: [Command]` | 程式碼交付，測試通過 |
| `✅ Build Verified: [Command]` | 程式碼交付，建置確認 |
| `⚠️ Verification Skipped: [Reason]` | 純討論，無程式碼 |

> 若同一錯誤連續 3 次嘗試仍失敗，AI 會停下、記錄嘗試過的方法，並提出根本不同的方案（升級協議）。

---

### 自訂指南

本框架設計為 fork 後個人化使用。以下是你可以修改的項目與位置：

#### 人格與語言

| 修改項目 | 檔案 | 預設值 |
|---------|------|--------|
| AI 如何稱呼你 | `system-prompt-v5.md` → Core Identity 表格 | `"dear" (親愛的)` |
| 輸出語言 | `system-prompt-v5.md` → Core Identity 表格 | `Traditional Chinese (繁體中文)` |
| 性格語氣 | `system-prompt-v5.md` → Core Identity 表格 | `Opinionated Neutrality` |
| 溝通風格 | `skills/warm-persona/SKILL.md` | 溫暖、金字塔原則 |

#### 預設技術棧

編輯 `skills/tech-defaults/SKILL.md` 修改預設技術選型（在沒有專案級定義時使用）。

> **提示：** 這些只是預設值。每個專案的 `architecture_decisions.md`（在 AI-Brain 中）會覆蓋它們。

#### BDD 關鍵字

編輯 `skills/ddd-bdd-tdd/SKILL.md` 修改 Gherkin 關鍵字（預設：`假如 / 當 / 那麼 / 而且`）。

#### Git 約定

編輯 `skills/git-workflow/SKILL.md` 修改提交訊息格式、分支命名和 PR 標準。

#### 建立自訂 Skill

在 `skills/` 下新增子目錄和 `SKILL.md` 即可建立你自己的 Skill：

```
skills/
└── my-custom-skill/
    └── SKILL.md
```

每個 `SKILL.md` 需要包含 YAML front matter（`name` 和 `description`，含觸發條件），接著是規則和流程。參考現有 Skills 了解格式。

---

### 相容性

本框架主要為 **Claude Code** 設計，提供完整 Skill 支援。其他工具亦可使用，功能程度有所不同：

| 工具 | 系統提示詞 | Skills | AI-Brain | 方法論 |
|------|:-:|:-:|:-:|:-:|
| Claude Code | ✅ | ✅ 原生 | ✅ | ✅ 完整 |
| Gemini CLI | ✅ | ⚠️ 手動附加 | ✅ | ✅ 完整 |
| OpenAI Codex | ✅ | ⚠️ 手動附加 | ✅ | ✅ 完整 |
| 其他 CLI 工具 | ✅ | ⚠️ 手動附加 | ✅ | ✅ 完整 |

> **驗證戳記遵守率**在不同模型間可能不同 — 某些 100% 遵守，某些需要加強。如果你的 AI 沒有穩定遵守某條規則，問題可能是 prompt 中的注意力競爭，而非 bug。歡迎開 issue 討論。

### 貢獻

歡迎貢獻！你可以：

- 開 issue 回報 Bug、建議、或規則遵從問題
- 提交 PR 新增 Skill、改進、或翻譯
- 與社群分享你的自訂 Skill

### 授權

[MIT](LICENSE)
