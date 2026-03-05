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

- **🧠 Memory that lives in Git** — AI Brain is just Markdown files in a Git repo. Version-controlled, diffable, greppable. You own your data.
- **🔌 Modular Skills** — 10 self-contained behavioral modules. Enable what you need, customize what you want, create your own.
- **🏗️ Structured methodology** — Enforces DDD → BDD → TDD with user checkpoints, so your AI thinks before it codes.
- **✅ Verifiable outputs** — Every response ends with a stamp proving what was checked and what wasn't.
- **📚 Cross-project learning** — Common Brain accumulates wisdom across all your projects. Fix a Docker DNS issue once, every project knows about it.
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
│  10 self-contained modules with             │
│  triggers, rules, and authority levels      │
├─────────────────────────────────────────────┤
│  AI Brain (_common/ + _example/)            │  ← Persistent memory
│  Git-versioned Markdown files               │
│  Project Brain + Common Brain               │
└─────────────────────────────────────────────┘
```

#### Skills Reference

| Skill | Type | Purpose |
|-------|------|---------|
| `warm-persona` | Always Active | Tone, communication style, dynamic role adaptation |
| `response-protocol` | Always Active | Thinking protocol, response priority, action authority, decision dimensions |
| `ai-brain` | Always Active | Long-term memory system, Brain loading procedure |
| `ddd-bdd-tdd` | Conditional | Structured development: Domain → Behavior → Test-Driven, codebase learning |
| `code-verification` | Conditional | Verification loop, escalation protocol, response ending stamps |
| `tech-defaults` | Conditional | Default tech stack and technology selection guidance |
| `git-workflow` | Conditional | Commit conventions, branch naming, PR standards |
| `conversation-logger` | Conditional | Observe and record recurring patterns |
| `skill-extractor` | Conditional | Analyze patterns and propose new Skills |
| `prompt-engineer` | Conditional | Diagnose and fix rule violations in Skills |

> **Always Active** Skills load in every conversation. **Conditional** Skills activate only when their trigger conditions are met (e.g., `ddd-bdd-tdd` activates for new features, `git-workflow` activates when committing).

---

### Project Structure

```
ai-coding-flow/
├── README.md
├── LICENSE
├── .gitignore
├── setup.sh                        ← One-time installer (symlinks + hooks → ~/.claude/)
├── system-prompt-v5.md              ← Core system prompt (orchestrator)
├── scripts/
│   ├── brain-loader.sh              ← SessionStart hook (tiered Brain loading)
│   └── brain-gate.sh                ← PreToolUse hook (forces text response before tools)
├── _common/                         ← Common Brain templates
│   ├── _catalog.json                ← Category index (auto-managed by AI)
│   ├── SCHEMA.md                    ← Data structure reference
│   ├── preferences.md               ← Personal preferences template
│   ├── troubleshooting.md           ← Cross-project troubleshooting template
│   ├── toolchain.md                 ← Toolchain experience template
│   ├── conversation-patterns.md     ← Conversation pattern log (skill-owned)
│   ├── skill-experience.md          ← Skill tuning and pitfall log (skill-owned)
│   └── prompt-violations.md         ← Rule violation tracker (skill-owned)
├── _example/                        ← Example Brain folder (reference for new projects)
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
    ├── skill-extractor/SKILL.md
    └── prompt-engineer/SKILL.md
```

---

### Quick Start

#### 1. Clone the framework

```bash
git clone https://github.com/JTH58/ai-coding-flow.git
```

#### 2. Set up AI Brain (your private memory)

AI Brain is a **separate repo** that lives alongside your project directories. The AI reads and writes to it during work.

```bash
# Create and initialize your Brain repo
mkdir -p ~/Documents/Github/ai-brain
cd ~/Documents/Github/ai-brain
git init

# Copy templates from the framework
cp -r ~/Documents/Github/ai-coding-flow/_common .
cp -r ~/Documents/Github/ai-coding-flow/_example .

git add -A && git commit -m "init: AI Brain"
```

> **Recommended:** Push to a private GitHub repo to back up your Brain and enable cross-machine access.
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
├── ai-brain/            ← Your Brain data (private)
│   ├── _common/         ← Shared across all projects
│   └── _example/        ← Templates for new projects
└── my-project/          ← Your code project
```

> The AI automatically derives the Brain path from your working directory: `$(dirname "$PWD")/ai-brain/`. As long as `ai-brain/` sits beside your project folders, it just works.

#### 3. Apply to your AI tool

<details>
<summary><b>Claude Code (recommended — full Skill support)</b></summary>

Claude Code natively supports the modular Skill architecture via `CLAUDE.md` + custom Skills.

**Install (one-time):**

```bash
cd ~/Documents/Github/ai-coding-flow
./setup.sh
```

This creates symlinks from `~/.claude/` to the project files and registers two hooks: `SessionStart` (auto-loads Brain) and `PreToolUse` (ensures the AI responds before using tools). Edits to project files take effect immediately — no manual sync needed.

> Claude Code reads `CLAUDE.md` hierarchically: global (`~/.claude/CLAUDE.md`) applies everywhere, project-level (`.claude/CLAUDE.md`) adds project-specific context. Skills in `~/.claude/skills/` are available globally.

**What the hooks do:**
- **`brain-loader.sh` (SessionStart)** — Uses tiered loading: critical files (`architecture_decisions.md`, `known_issues.md`) are injected as full text (Tier 1), while other Brain files are listed as paths for on-demand reading (Tier 2/3). The AI detects the `=== AI BRAIN ===` marker and skips manual loading.
- **`brain-gate.sh` (PreToolUse)** — Blocks the first tool call after Brain loading, forcing the AI to produce a text response first. This prevents the AI from silently jumping into code changes before acknowledging context. Subsequent tool calls pass through normally.

If no Brain repo exists next to your project, both hooks silently do nothing.

**Updating:** When the framework releases a new version, just pull — symlinks pick up changes automatically:

```bash
cd ~/Documents/Github/ai-coding-flow && git pull
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

Gemini CLI doesn't have a native Skill system. Use the system prompt as your base — it provides the core identity, response principles, and skill loading references.

**Option A: Per-project (recommended)**

```bash
mkdir -p .gemini
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md .gemini/system.md
echo 'GEMINI_SYSTEM_MD=1' >> .gemini/.env
```

**Option B: Global environment variable**

```bash
# Add to ~/.zshrc or ~/.bashrc
export GEMINI_SYSTEM_MD="$HOME/Documents/Github/ai-coding-flow/system-prompt-v5.md"
source ~/.zshrc
```

> **Note:** For full Skill functionality, you can append relevant Skill contents to the system prompt file. The Skills are plain Markdown — concatenate as needed.
>
> **Recommended minimum bundle:** `response-protocol` + `ai-brain` + `code-verification`

</details>

<details>
<summary><b>OpenAI Codex</b></summary>

Codex uses `AGENTS.md` for custom instructions.

**Option A: Global**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md ~/.codex/AGENTS.md
```

**Option B: Per-project**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md AGENTS.md
```

> Like Gemini CLI, Codex doesn't natively support Skills. Append relevant Skill contents to `AGENTS.md` as needed.
>
> **Recommended minimum bundle:** `response-protocol` + `ai-brain` + `code-verification`

</details>

<details>
<summary><b>Other AI Tools</b></summary>

The framework works with any AI tool that accepts custom system prompts:

1. Copy the content of `system-prompt-v5.md` into your tool's system prompt field
2. For full methodology, append the contents of relevant `skills/*/SKILL.md` files
3. Ensure the AI has shell access to read/write Brain files

> The system prompt is written in English by design — English instructions yield better AI compliance and ~17% fewer tokens compared to Chinese instructions for the same semantics.

</details>

---

### How It Works

#### AI Brain: Memory That Lives in Git

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

> **Tip:** These are just defaults. Each project's `architecture_decisions.md` in AI Brain overrides them. You don't need to modify Skills for per-project changes.

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

| Tool | System Prompt | Skills | AI Brain | Methodology |
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

- **🧠 活在 Git 裡的記憶** — AI Brain 只是 Git repo 中的 Markdown 檔案。可版控、可 diff、可 grep。資料完全屬於你。
- **🔌 模組化 Skills** — 10 個獨立的行為模組。啟用你需要的，自訂你想改的，建立你自己的。
- **🏗️ 結構化方法論** — 強制執行 DDD → BDD → TDD 並設立用戶檢查點，讓 AI 先思考再寫程式。
- **✅ 可驗證的輸出** — 每個回應結尾都有戳記，證明驗證了什麼、跳過了什麼。
- **📚 跨專案學習** — Common Brain 在所有專案間積累智慧。修過一次 Docker DNS 問題，所有專案都知道解法。
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
│  10 個獨立模組，各有觸發條件、規則、授權等級  │
├─────────────────────────────────────────────┤
│  AI Brain (_common/ + _example/)            │  ← 持久記憶
│  Git 版控的 Markdown 檔案                    │
│  Project Brain + Common Brain               │
└─────────────────────────────────────────────┘
```

#### Skills 總覽

| Skill | 類型 | 用途 |
|-------|------|------|
| `warm-persona` | 常駐 | 語氣、溝通風格、動態角色適應 |
| `response-protocol` | 常駐 | 思考協議、回應優先順序、行動授權、決策維度 |
| `ai-brain` | 常駐 | 長期記憶系統、Brain 載入程序 |
| `ddd-bdd-tdd` | 條件觸發 | 結構化開發：領域驅動 → 行為驅動 → 測試驅動、既有程式碼學習 |
| `code-verification` | 條件觸發 | 驗證迴圈、升級協議、回應結尾戳記 |
| `tech-defaults` | 條件觸發 | 預設技術棧與選型指南 |
| `git-workflow` | 條件觸發 | 提交約定、分支命名、PR 標準 |
| `conversation-logger` | 條件觸發 | 觀察並記錄重複模式 |
| `skill-extractor` | 條件觸發 | 分析模式並提議新 Skill |
| `prompt-engineer` | 條件觸發 | 診斷並修復 Skill 規則違反 |

> **常駐** Skill 在每次對話中載入。**條件觸發** Skill 僅在觸發條件成立時啟動（如 `ddd-bdd-tdd` 在新功能開發時啟動，`git-workflow` 在提交時啟動）。

---

### 專案結構

```
ai-coding-flow/
├── README.md
├── LICENSE
├── .gitignore
├── setup.sh                        ← 一次性安裝腳本（symlink + hooks → ~/.claude/）
├── system-prompt-v5.md              ← 核心系統提示詞（協調者）
├── scripts/
│   ├── brain-loader.sh              ← SessionStart hook（分層載入 Brain 到 context）
│   └── brain-gate.sh                ← PreToolUse hook（強制先回應再用工具）
├── _common/                         ← Common Brain 模板
│   ├── _catalog.json                ← 分類索引（AI 自動管理）
│   ├── SCHEMA.md                    ← 資料結構參考
│   ├── preferences.md               ← 個人偏好模板
│   ├── troubleshooting.md           ← 跨專案踩坑紀錄模板
│   ├── toolchain.md                 ← 工具鏈經驗模板
│   ├── conversation-patterns.md     ← 會話模式日誌（Skill 專用）
│   ├── skill-experience.md          ← Skill 調校與踩坑日誌（Skill 專用）
│   └── prompt-violations.md         ← 規則違反追蹤（Skill 專用）
├── _example/                        ← 範例 Brain 資料夾（新專案參考用）
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
    ├── skill-extractor/SKILL.md
    └── prompt-engineer/SKILL.md
```

---

### 快速開始

#### 1. Clone 框架

```bash
git clone https://github.com/JTH58/ai-coding-flow.git
```

#### 2. 設定 AI Brain（你的私有記憶）

AI Brain 是**獨立的 repo**，與你的專案目錄並排放置。AI 工作時會自動讀寫。

```bash
# 建立並初始化你的 Brain repo
mkdir -p ~/Documents/Github/ai-brain
cd ~/Documents/Github/ai-brain
git init

# 從框架複製模板
cp -r ~/Documents/Github/ai-coding-flow/_common .
cp -r ~/Documents/Github/ai-coding-flow/_example .

git add -A && git commit -m "init: AI Brain"
```

> **建議：** 推送到私有 GitHub repo，備份你的 Brain 並支援跨機器存取。
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
├── ai-brain/            ← 你的 Brain 資料（私有）
│   ├── _common/         ← 所有專案共享
│   └── _example/        ← 新專案的模板
└── my-project/          ← 你的程式碼專案
```

> AI 會從你的工作目錄自動推導 Brain 路徑：`$(dirname "$PWD")/ai-brain/`。只要 `ai-brain/` 和你的專案資料夾放在同一層，就能自動運作。

#### 3. 套用到你的 AI 工具

<details>
<summary><b>Claude Code（推薦 — 完整 Skill 支援）</b></summary>

Claude Code 透過 `CLAUDE.md` + 自訂 Skills 原生支援模組化 Skill 架構。

**安裝（一次性）：**

```bash
cd ~/Documents/Github/ai-coding-flow
./setup.sh
```

這會從 `~/.claude/` 建立 symlink 指向專案檔案，並註冊兩個 hook：`SessionStart`（自動載入 Brain）和 `PreToolUse`（確保 AI 先回應再使用工具）。編輯專案檔後立即生效，不需手動同步。

> Claude Code 階層式讀取 `CLAUDE.md`：全域（`~/.claude/CLAUDE.md`）適用所有專案，專案級（`.claude/CLAUDE.md`）添加專案上下文。`~/.claude/skills/` 中的 Skills 全域可用。

**Hook 做了什麼：**
- **`brain-loader.sh`（SessionStart）** — 採用分層載入：關鍵檔案（`architecture_decisions.md`、`known_issues.md`）以全文注入（Tier 1），其他 Brain 檔案僅列出路徑供按需讀取（Tier 2/3）。AI 偵測到 `=== AI BRAIN ===` 標記就跳過手動載入。
- **`brain-gate.sh`（PreToolUse）** — 在 Brain 載入後攔截第一個 tool call，強制 AI 先產生文字回應。這可防止 AI 在未確認 context 的情況下直接跳入修改程式碼。後續 tool call 正常放行。

若專案旁邊沒有 Brain repo，兩個 hook 都靜默不做任何事。

**更新：** 框架發布新版本時，拉取即可 — symlink 會自動反映變更：

```bash
cd ~/Documents/Github/ai-coding-flow && git pull
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

Gemini CLI 沒有原生 Skill 系統。使用系統提示詞作為基礎 — 它提供核心身份、回應原則和 Skill 載入參考。

**方式 A：單一專案（推薦）**

```bash
mkdir -p .gemini
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md .gemini/system.md
echo 'GEMINI_SYSTEM_MD=1' >> .gemini/.env
```

**方式 B：全域環境變數**

```bash
# 加到 ~/.zshrc 或 ~/.bashrc
export GEMINI_SYSTEM_MD="$HOME/Documents/Github/ai-coding-flow/system-prompt-v5.md"
source ~/.zshrc
```

> **備註：** 如需完整 Skill 功能，可將相關 Skill 內容附加到系統提示詞檔案中。Skills 都是純 Markdown — 視需要串接即可。
>
> **建議最小組合：** `response-protocol` + `ai-brain` + `code-verification`

</details>

<details>
<summary><b>OpenAI Codex</b></summary>

Codex 透過 `AGENTS.md` 載入自訂指令。

**方式 A：全域**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md ~/.codex/AGENTS.md
```

**方式 B：單一專案**

```bash
cp ~/Documents/Github/ai-coding-flow/system-prompt-v5.md AGENTS.md
```

> 與 Gemini CLI 相同，Codex 不原生支援 Skills。視需要將相關 Skill 內容附加到 `AGENTS.md` 中。
>
> **建議最小組合：** `response-protocol` + `ai-brain` + `code-verification`

</details>

<details>
<summary><b>其他 AI 工具</b></summary>

本框架適用於任何接受自訂系統提示詞的 AI 工具：

1. 將 `system-prompt-v5.md` 的內容複製到工具的系統提示詞欄位
2. 如需完整方法論，附加相關 `skills/*/SKILL.md` 的內容
3. 確保 AI 有 Shell 存取權限以讀寫 Brain 檔案

> 提示詞刻意使用全英文 — 英文指令的 AI 遵從率更高，且比中文指令節省約 17% token。

</details>

---

### 運作原理

#### AI Brain：活在 Git 裡的記憶

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

> **提示：** 這些只是預設值。每個專案的 `architecture_decisions.md`（在 AI Brain 中）會覆蓋它們。

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

| 工具 | 系統提示詞 | Skills | AI Brain | 方法論 |
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
