# 各ツールにおける設定ファイルの場所

## 共通

### skills
skillsは、エージェントに特定の作業手順や専門知識を追加するための再利用可能な単位である。通常は1 skillごとに1ディレクトリを持ち、そのルートに`SKILL.md`を配置する。`SKILL.md`には、そのskillをいつ使うか、どのような手順で使うか、補助ファイルをどこまで参照するかといった利用規約を記述する。

基本的な構成は、以下のようになる。

```
skills/
└─ <skill-name>/
   ├─ SKILL.md
   ├─ references/
   ├─ templates/
   └─ scripts/
```

`SKILL.md`が入口になり、必要に応じて`references/`の補足資料、`templates/`の雛形、`scripts/`の補助スクリプトを参照する。これらの補助ファイルは常時読み込まれる前提ではなく、`SKILL.md`の指示に従って必要な範囲だけを参照する。

また、`SKILL.md`の先頭にはYAMLフロントマターを置くことができる。フロントマターには、そのskillを識別し、呼び出し判断に使うためのメタデータを記述する。基本例は以下の通りである。

```yaml
---
name: sysmlv2-model-generator
description: "Generate SysML v2 models from a user prompt or from the contents of a specified file."
---
```

`name`はskillの識別名であり、ディレクトリ名や呼び出し時の名称と対応づけやすい値を付ける。`description`はそのskillをどのような依頼で使うべきかを説明する要約であり、適用場面や対象タスクが分かるように記述する。

フロントマターの後ろに、本文として目的、入力、手順、参照先、制約事項などをMarkdownで記述する。つまり、フロントマターは「このskillが何者か」を表す定義、本文は「このskillをどう使うか」を表す手順書という役割分担になる。

このため、skillsは単なるプロンプト断片ではなく、作業判断の条件、実行手順、参照資料、テンプレートをひとまとめにしたローカルな作業パッケージとして扱う。

## GitHub Copilot + VSCode
VS Code上のGitHub Copilotは、単一の設定ファイルだけでなく、instructions、prompt files、custom agents、skills、hooks、MCP、pluginsを組み合わせて拡張する。2026年3月時点では、主なカスタマイズ対象は以下の通りである。

- 常時適用のinstructions
- 手動呼び出し用のprompt files
- 役割と利用ツールを切り替えるcustom agents
- 専門的な作業能力を追加するskills
- エージェント実行時にコマンドを差し込むhooks
- 外部ツール接続用のMCP servers
- これらをまとめて配布するplugins
- これらを呼び出すslash commands

代表的な構成例は、以下のようになる。

```
repo-root/
├─ .github/
│  ├─ copilot-instructions.md
│  ├─ instructions/
│  │  ├─ frontend.instructions.md
│  │  └─ backend.instructions.md
│  ├─ prompts/
│  │  ├─ review.prompt.md
│  │  └─ readme.prompt.md
│  ├─ agents/
│  │  ├─ planner.agent.md
│  │  └─ reviewer.agent.md
│  ├─ skills/
│  │  └─ webapp-testing/
│  │     └─ SKILL.md
│  ├─ hooks/
│  │  └─ format.json
│  └─ mcp.json
└─ AGENTS.md
```

### instructions

VS Codeのcustom instructionsは、複数ファイルを組み合わせてchat contextに加える方式である。主な配置先は以下の通りである。

- `.github/copilot-instructions.md`
  リポジトリ全体に常時適用する共通ルールを書く。
- `.github/instructions/**/*.instructions.md`
  パスやファイル種別ごとに適用する追加ルールを書く。
- `AGENTS.md`
  Copilotでも参照されるagent instructionsであり、他ツールとの共有にも向く。

`*.instructions.md`はYAMLフロントマターで適用条件を付けられる。

```yaml
---
name: Python Standards
description: Coding conventions for Python files
applyTo: "**/*.py"
---
```

- `name`
  instruction fileの表示名。省略時はファイル名が使われる。
- `description`
  instruction fileの概要説明。
- `applyTo`
  自動適用対象のglobパターン。

関連設定は以下である。

- `chat.instructionsFilesLocations`
- `chat.useAgentsMdFile`
- `chat.useNestedAgentsMdFiles`
- `chat.includeApplyingInstructions`
- `chat.includeReferencedInstructions`

### prompt files

`*.prompt.md`は、特定の作業を再利用可能な形で保存するprompt templateである。常時適用ではなく、必要なときに明示的に呼び出す。レビュー、README生成、テスト作成、説明文生成などの用途に向く。prompt filesはpublic previewである。

### custom agents

custom agentsは、特定の役割ごとに指示と利用ツールを束ねた設定であり、`.github/agents/*.agent.md`に配置する。例えば、planner、reviewer、security reviewerのように役割別のagentを定義できる。

`.agent.md`では、YAMLフロントマターで`name`、`description`、`tools`、`model`、`handoffs`などを設定できる。VS Code 1.106以降ではcustom chat modesではなくcustom agentsという呼称になっている。

関連設定は以下である。

- `chat.agentFilesLocations`

### skills

Agent Skillsは、instructions、scripts、references、templatesなどをまとめた再利用可能な能力単位である。VS Codeでは`.github/skills/<skill-name>/SKILL.md`を配置して使う。skillsはon-demandで読み込まれ、常時適用のinstructionsよりも重いが、専門的な作業手順を持たせやすい。

skillsはchat上でslash commandとしても使える。例えば、`/webapp-testing`のように呼び出せる。2026年1月以降のVS Codeでは、skillsが`/`メニューに表示され、追加コンテキストを続けて渡すこともできる。

VS Codeでは、skillの公開方法を制御するために、`SKILL.md`のフロントマターで以下も使える。

- `user-invocable`
  `false`にすると`/`メニューに出さず、モデルの自動選択のみに使う。
- `disable-model-invocation`
  モデルによる自動起動を無効にし、ユーザ明示呼び出しだけに制限する。

関連設定は以下である。

- `chat.useAgentSkills`
- `chat.agentSkillsLocations`

### hooks

hooksは、エージェントのライフサイクル上の特定タイミングでshell commandを実行する仕組みである。VS Codeでは`.github/hooks/*.json`にhook定義を置く。format自体はCopilot CLIやClaude Codeと互換である。hooksはpreviewであり、組織ポリシーで無効化される場合がある。

VS Codeの主なhook eventは以下である。

- `SessionStart`
- `UserPromptSubmit`
- `PreToolUse`
- `PostToolUse`
- `PreCompact`
- `SubagentStart`
- `SubagentStop`
- `Stop`

また、custom agentのフロントマター内に`hooks`を書いて、そのagentにだけhookを適用することもできる。これはpreview機能である。

### MCP servers

MCP serverは、外部API、CLI、データソースなどをCopilotに接続するための仕組みである。VS Codeでは`mcp.json`で管理する。database参照、外部ドキュメント検索、社内API呼び出しなど、instructionsだけでは足りない外部能力を追加するときに使う。

### plugins

Agent pluginは、slash commands、skills、agents、hooks、MCP serversをまとめて配布するパッケージである。VS Codeではplugin marketplaceから導入できる。plugin自体はpreviewである。

関連設定は以下である。

- `chat.plugins.enabled`

### commands

VS Codeのchatでは、組み込みのslash commandと、customizationから生えるslash commandの両方を使う。

代表的な組み込みcommandは以下である。

- `/agents`
- `/hooks`
- `/instructions`
- `/prompts`
- `/skills`
- `/plan`
- `/new`
- `/explain`
- `/tests`

また、次のような追加commandも使える。

- `/<skill name>`
  skillを直接呼び出す。
- `/<prompt name>`
  prompt fileを直接呼び出す。
- pluginが提供する独自slash command
  plugin導入後に`/`メニューへ追加される。

なお、旧来の設定画面ベースのcustom instructionsの一部はdeprecatedであり、現在はファイルベースのinstructions、prompt files、agents、skillsを組み合わせる構成が推奨されている。


## Codex

Codexでは、Claude Codeのように`agent`が役割、`skill`が能力のような分け方ではなく、Codexという主体にどの文脈と能力を与えるかという考え方で設定する。
[OpenAI Customization](https://developers.openai.com/codex/concepts/customization/?utm_source=chatgpt.com)

以下の4つの要素がCodexの主体に与えられる文脈と能力の例である。
- Project guidance (AGENTS.md)
- Skills
- MCP
- Multi-agents

```
Codex本体
├─ AGENTS.md      : 常時効く方針・規範・文脈
├─ Skills         : 必要時に読み込む再利用可能なワークフロー/専門知識
├─ MCP            : 外部ツール・外部システム接続
└─ Multi-agents   : 必要に応じた委譲・分業
```
ユーザ単位の設定もあるが、ここではリポジトリ単位の設定ファイルについて説明する。リポジトリ単位の設定ファイルは、`.codex/config.toml`に配置される。このファイルには、Codexの全体的な設定が含まれる。

```
repo-root/
├─ AGENTS.md
├─ .codex/
│  └─ config.toml
├─ agents/
│  ├─ explorer.toml
│  ├─ reviewer.toml
│  ├─ worker.toml
│  └─ docs-researcher.toml
└─ .agents/
   └─ skills/
      ├─ repo-navigation/
      │  └─ SKILL.md
      ├─ code-review/
      │  └─ SKILL.md
      ├─ test-design/
      │  └─ SKILL.md
      └─ docs-editor/
         └─ SKILL.md
```

### agents/
codexのサブエージェント機能。
[OpenAI Multi-agent](https://developers.openai.com/codex/multi-agent/)

サブエージョンと機能を利用する場合は、`.codex/config.toml`の`[agents]`セクションで、エージェントの設定を行う必要がある。以下は、エージェントの設定例である。

```toml
[agents]
max_threads = 6
max_depth = 1
job_max_runtime_seconds = 1800

[agents.explorer]
description = "Read-only codebase explorer for locating relevant code paths."
config_file = "agents/explorer.toml"

[agents.reviewer]
description = "Reviewer focused on correctness, security, and test risks."
config_file = "agents/reviewer.toml"

[agents.docs_researcher]
description = "Research agent that verifies framework and API details."
config_file = "agents/docs-researcher.toml"
```

エージェントの設定ファイルは、`config_file`で指定された場所に配置される必要がある。例えば、`explorer`エージェントの設定ファイルは、`agents/explorer.toml`に配置される必要がある。
```toml
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
developer_instructions = """
Stay in exploration mode.
Trace the real execution path, cite files and symbols, and avoid proposing fixes unless the parent agent asks for them.
Prefer fast search and targeted file reads over broad scans.
"""
```

### .agents/skills

スキルは、`.agents/skills/`ディレクトリ内に配置されます。各スキルは、独自のサブディレクトリを持ち、その中に`SKILL.md`ファイルが含まれています。
例えば、`repo-navigation`スキルは、`.agents/skills/repo-navigation/SKILL.md`に配置されます。スキルのサブディレクトリは、スキルの名前に対応しています。
