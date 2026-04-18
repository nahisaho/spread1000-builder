# SPReAD Builder

文部科学省「AI for Science 萌芽的挑戦研究創出事業（SPReAD）」公募支援 GitHub Copilot Agent Skills スイート。

## インストール

```bash
npm install spread1000-builder
```

インストール時に以下のファイルがプロジェクトの `.github/` ディレクトリへ自動配置されます。

| 配置先 | 内容 |
|--------|------|
| `.github/skills/spread1000-*/` | 8つのサブスキル（SKILL.md + assets/ + references/） |
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
6. **採択後管理** — 交付申請・中間報告・最終報告・予算変更
7. **IaC / CI/CD** — Bicep テンプレート生成とデプロイパイプライン構築

## サブスキル一覧

| スキル | 概要 |
|--------|------|
| `spread1000-context-collector` | 1問1答コンテキスト収集・メタプロンプト生成 |
| `spread1000-research-planner` | AI 活用研究プランの策定支援 |
| `spread1000-azure-architect` | Azure アーキテクチャ設計 |
| `spread1000-cost-estimator` | Azure コスト算出 |
| `spread1000-proposal-writer` | SPReAD 申請書作成支援 |
| `spread1000-submission-guide` | 応募手続き・ AIインタビュー・e-Rad・資格確認 |
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
    ├── spread1000-post-award/
    └── spread1000-iac-deployer/
```

## バージョン

v0.1.0
