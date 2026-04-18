# SPReAD Builder

文部科学省「AI for Science 萌芽的挑戦研究創出事業（SPReAD）」公募支援 GitHub Copilot Agent Skills スイート。

## インストール

```bash
npm install spread1000-builder
```

インストール時に以下のファイルがプロジェクトの `.github/` ディレクトリへ自動配置されます。

| 配置先 | 内容 |
|--------|------|
| `.github/skills/spread1000-*/` | 9つのサブスキル（SKILL.md + assets/ + references/） |
| `.github/agents/*.agent.md` | カスタムエージェント定義 |
| `.github/AGENTS.md` | オーケストレーター（WHEN/DO ルーティング） |
| `.github/copilot-instructions.md` | スイート固有の規約 |

> `.github/AGENTS.md` と `copilot-instructions.md` は既存ファイルがある場合スキップされます。

### アンインストール

```bash
npm uninstall spread1000-builder
```

スキルとエージェント定義が `.github/` から削除されます（`AGENTS.md` と `copilot-instructions.md` は保持）。

## 概要

AI を自身の研究に組み込みたいがアプローチがわからない研究者を対象に、以下のワークフローを一貫して支援します。

0. **コンテキスト収集** — 1問1答で不足情報を収集しメタプロンプトを生成（shikigami パターン）
1. **研究プラン策定** — Web リサーチを通じた AI 活用研究計画の作成
2. **Azure 構成設計** — 研究プランに最適な Microsoft Azure アーキテクチャの設計
3. **コスト算出** — Azure 構成に基づく費用の見積もり
4. **申請書作成** — SPReAD 公募申請書の作成支援
5. **応募手続き** — AIインタビュー・e-Rad提出・応募資格確認
6. **システム構成図** — draw.io MCP による Azure 構成図生成
7. **採択後管理** — 交付申請・中間報告・最終報告・予算変更
8. **IaC / CI/CD** — Bicep テンプレート生成とデプロイパイプライン構築

## サブスキル一覧

| スキル | 概要 |
|--------|------|
| `spread1000-context-collector` | 1問1答コンテキスト収集・メタプロンプト生成 |
| `spread1000-research-planner` | AI 活用研究プランの策定支援 |
| `spread1000-azure-architect` | Azure アーキテクチャ設計 |
| `spread1000-cost-estimator` | Azure コスト算出 |
| `spread1000-proposal-writer` | SPReAD 申請書作成支援 |
| `spread1000-submission-guide` | 応募手続き・ AIインタビュー・e-Rad・資格確認 |
| `spread1000-diagram-generator` | draw.io MCP によるシステム構成図生成 |
| `spread1000-post-award` | 採択後管理・中間報告・最終報告・予算変更 |
| `spread1000-iac-deployer` | Bicep / CI/CD パイプライン生成 |

## デプロイ後のディレクトリ構成

```
.github/
├── AGENTS.md                          # オーケストレーター
├── copilot-instructions.md            # スイート規約
├── agents/
│   ├── research-advisor.agent.md      # フルツールエージェント
│   └── proposal-reviewer.agent.md     # 読み取り専用レビューア
└── skills/
    ├── spread1000-context-collector/
    ├── spread1000-research-planner/
    ├── spread1000-azure-architect/
    ├── spread1000-cost-estimator/
    ├── spread1000-proposal-writer/
    ├── spread1000-submission-guide/
    ├── spread1000-diagram-generator/
    ├── spread1000-post-award/
    └── spread1000-iac-deployer/
```

## draw.io MCP Server のセットアップ

`spread1000-diagram-generator` スキルで Azure システム構成図を生成するには、[draw.io MCP Server](https://github.com/jgraph/drawio-mcp) のセットアップが必要です。3つの方法から環境に合ったものを選択してください。

### 方法比較

| | MCP App Server | MCP Tool Server | Skill + CLI |
|---|---|---|---|
| **セットアップ** | リモート URL を追加するだけ | npm パッケージをインストール | draw.io Desktop + スキルファイルコピー |
| **図の出力先** | チャット内にインライン表示 | ブラウザで draw.io エディタが開く | `.drawio` ファイル（PNG/SVG/PDF エクスポート可） |
| **インストール不要** | ✅ | ❌ | ❌ |
| **XML / CSV / Mermaid** | XML のみ | ✅ 全対応 | XML のみ |
| **推奨環境** | VS Code + Copilot Chat | Claude Desktop / 汎用 MCP クライアント | Claude Code |

### 方法 1: MCP App Server（推奨・インストール不要）

VS Code の MCP 設定にリモートサーバーを追加するだけで使えます。

`.vscode/mcp.json`:

```json
{
  "servers": {
    "drawio": {
      "type": "http",
      "url": "https://mcp.draw.io/mcp"
    }
  }
}
```

> チャット内に図がインライン表示されます。「Open in draw.io」ボタンで編集も可能です。

### 方法 2: MCP Tool Server（ローカル実行）

npm パッケージ `@drawio/mcp` をローカルで実行します。図はブラウザの draw.io エディタで開きます。

`.vscode/mcp.json`:

```json
{
  "servers": {
    "drawio": {
      "command": "npx",
      "args": ["@drawio/mcp"]
    }
  }
}
```

XML に加えて CSV・Mermaid 形式もサポートします。

### 方法 3: Skill + CLI（ファイル出力）

[draw.io Desktop](https://github.com/jgraph/drawio-desktop) をインストールし、`.drawio` ファイルとして出力します。PNG/SVG/PDF エクスポートにも対応。

```bash
# draw.io Desktop のインストール（Linux）
sudo snap install drawio

# または AppImage
wget https://github.com/jgraph/drawio-desktop/releases/download/v26.2.2/drawio-x86_64-26.2.2.AppImage
chmod +x drawio-x86_64-26.2.2.AppImage
```

### 利用可能な MCP ツール

| ツール | 説明 |
|--------|------|
| `search_shapes` | 10,000+ のシェイプ（Azure / AWS / GCP / UML 等）をキーワード検索。正確な style 文字列を返す |
| `create_diagram` | draw.io XML からダイアグラムを生成・表示 |

### 使用例

```
@research-advisor Phase 1 の Azure 構成設計書からシステム構成図を
draw.io 形式で生成してください。Azure 公式アイコンを使用してください。
```

エージェントが `search_shapes("Azure Virtual Machine")` 等で公式アイコンの style を取得し、`create_diagram` でプロフェッショナルな構成図を生成します。出力先は `output/diagrams/` です。

## バージョン

v0.2.0
