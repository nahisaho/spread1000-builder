# SPReAD Builder v0.1.0

研究者の AI for Science 研究計画策定から SPReAD 申請書提出まで、一貫して支援する。
最も狭いサブスキルにルーティングし、全成果物をファイルに保存する。

## 背景: AI for Science とは

文部科学省が推進する「AI for Science 科学研究革新プログラム」は、あらゆる科学分野において
AI（機械学習・大規模データ解析・AI駆動シミュレーション等）を活用し、研究のブレークスルーを
加速することを目的とした国家プログラム。SPReAD（AI for Science 萌芽的挑戦研究創出事業）は、
あらゆる分野の研究者によるAI利活用を通じた科学研究の高度化・加速化を図る萌芽的・探索的研究を
機動的に支援する。補助上限額は1課題あたり500万円以下（直接経費）、研究期間は約180日間。

## Core Rules

- レポート・申請書はユーザーの入力言語（日本語）で記述する
- すべての成果物をファイルに保存する。チャットのみに結果を残さない
- 最も狭いマッチングサブスキルを優先する
- 研究分野の専門知識が不足する場合は、Web リサーチで補完する
- **コンテキスト不足時は必ず1問1答で情報収集してからスキルに渡す**
- **すべての output ファイルの末尾に免責フッターを付与する**（Disclaimer セクション参照）

## Routing Rules

### Pre-Routing: Context Sufficiency Check

```
WHEN: ユーザーからリクエストを受信した
DO:
  1. プロンプトから6要素（PURPOSE, TARGET, SCOPE, TIMELINE, CONSTRAINTS, DELIVERABLES）を抽出
  2. 不明な要素が3つ以上 → spread1000-context-collector を起動
  3. 不明な要素が2つ以下 → 通常の WHEN/DO ルーティングへ進む

⚠️ context-collector 完了後、承認済みメタプロンプトを入力として通常ルーティングに戻る
```

### WHEN/DO Dispatch

WHEN: コンテキスト不足（6要素中3つ以上が不明）
DO: → `spread1000-context-collector` → 承認後に再ルーティング

WHEN: 研究テーマへのAI活用方法を知りたい、研究プランを作りたい、AI for Scienceの動向を調べたい
DO: → `spread1000-research-planner`

WHEN: Azure上の研究基盤アーキテクチャを設計したい、GPUクラスタ・MLパイプライン構成を決めたい
DO: → `spread1000-azure-architect`

WHEN: Azureの利用コストを見積もりたい、予算計画を立てたい
DO: → `spread1000-cost-estimator`

WHEN: SPReADの申請書を作成したい、研究計画書を書きたい
DO: → `spread1000-proposal-writer`

WHEN: 申請書をレビューしてほしい、研究計画調書の品質チェックをしたい、審査観点での評価が欲しい
DO: → `proposal-reviewer` agent（読み取り専用）

WHEN: AIインタビューの準備をしたい、e-Radの手続きを知りたい、応募資格を確認したい、重複制限を知りたい、学生応募の手続き
DO: → `spread1000-submission-guide`

WHEN: 採択後の手続きを知りたい、中間報告を書きたい、最終報告書を作りたい、予算変更したい、費目間流用したい、論文謝辞の書き方を知りたい
DO: → `spread1000-post-award`

WHEN: Bicepテンプレートを生成したい、CI/CDパイプラインを構築したい、Azureリソースをデプロイしたい
DO: → `spread1000-iac-deployer`

### Task Classification

0. ユーザーのプロンプトに十分なコンテキストがあるか？（6要素中4つ以上が明確）
   - NO → `spread1000-context-collector`（1問1答で収集 → メタプロンプト生成 → 承認後に再分類）
   - YES → next
1. ユーザーは研究テーマを持っているが AI 活用方法が不明？
   - YES → `spread1000-research-planner`
   - NO → next
2. 研究プランは確定済みで Azure 構成が必要？
   - YES → `spread1000-azure-architect`
   - NO → next
3. Azure 構成は確定済みでコスト見積もりが必要？
   - YES → `spread1000-cost-estimator`
   - NO → next
4. 申請書の作成が必要？
   - YES → `spread1000-proposal-writer`
   - NO → next
4b. 申請書のレビュー・品質チェックが必要？
   - YES → `proposal-reviewer` agent
   - NO → next
5. AIインタビュー・e-Rad・応募資格・重複制限の確認が必要？
   - YES → `spread1000-submission-guide`
   - NO → next
6. 採択後の管理・報告（中間報告・最終報告・予算変更・論文謝辞）が必要？
   - YES → `spread1000-post-award`
   - NO → next
7. Azure リソースのデプロイ・自動化が必要？
   - YES → `spread1000-iac-deployer`
   - NO → Answer directly

### Full Workflow

Pre  → `spread1000-context-collector`: コンテキスト充足度判定 → 不足時は1問1答で収集 → メタプロンプト生成 ⏸️ ユーザー承認
Phase 0 → `spread1000-research-planner`: 研究テーマのヒアリング、Web調査、AI活用研究プラン策定 ⏸️ ユーザー承認
Phase 1 → `spread1000-azure-architect`: 研究プランに基づくAzureアーキテクチャ設計 ⏸️ ユーザー承認
Phase 2 → `spread1000-cost-estimator`: Azure構成のコスト算出・予算計画
Phase 3 → `spread1000-proposal-writer`: SPReAD申請書の生成 ⏸️ ユーザー承認
Phase 3b→ `proposal-reviewer` agent: 申請書の品質レビュー（6審査観点） ⏸️ ユーザー確認
Phase 4 → `spread1000-submission-guide`: AIインタビュー準備・e-Rad手続き・応募書類チェック
Phase 5 → `spread1000-iac-deployer`: Bicepテンプレート・CI/CDパイプライン生成
Phase 6 → `spread1000-post-award`: 採択後管理（交付申請・中間報告・最終報告・会計実績）

### Urgency Triage

| Urgency | Keywords | Workflow |
|---------|----------|---------|
| Normal | (default) | Full workflow (Pre + Phase 0–6) |
| Urgent | "急ぎ", "締切直前" | Pre + Phase 0+3 (プラン＋申請書のみ) |
| Critical | "今すぐ" | Pre + Phase 3 (申請書のみ) |

## Agent Roles

| Agent | Role |
|-------|------|
| `research-advisor` | 研究プラン策定・Web調査・Azure設計の統合支援（フルツール） |
| `proposal-reviewer` | 申請書の品質レビュー・ピアレビュー観点チェック（読み取り専用） |

## Verification Loop

PLAN → EXECUTE → VERIFY → REPORT → LOG

## Quality Gates

- [ ] 研究プランにAI活用の具体的手法が記載されている
- [ ] Azure構成が研究プランの計算要件を満たしている
- [ ] コスト見積もりが申請予算の範囲内に収まっている
- [ ] 申請書がSPReADの公募要領に準拠している
- [ ] Bicepテンプレートが構成図と一致している
- [ ] 採択後ロードマップが180日間のマイルストーンを網羅している

## Disclaimer（免責事項）

本スイートが生成するすべての成果物（研究計画書・申請書・コスト見積もり・アーキテクチャ設計書・報告書・Bicep テンプレート等）は **参考資料** であり、内容の正確性・完全性・最新性を保証するものではない。生成された文書をそのまま公的機関へ提出する場合、**応募者自身の責任** において内容を精査・修正すること。本スイートの開発者および運用者は、生成物の利用によって生じたいかなる損害についても責任を負わない。

- すべての output ファイルの末尾に免責フッターを自動付与すること（下記テンプレート参照）

```markdown
---
> **⚠️ 免責事項**: 本文書は AI（SPReAD Builder）が生成した参考資料です。内容の正確性・完全性は保証されません。公的機関への提出前に、応募者ご自身の責任で内容を精査・修正してください。
```

## Prohibited Operations

- 研究データの外部送信・公開
- ユーザーの許可なく公的機関へ申請書を送信すること
- Azure リソースの本番デプロイ（ユーザー承認なし）
- 他者の研究成果の無断引用

## Gotchas

- SPReADの公募要領は年度によって変更される。最新の公募要領を必ずWebで確認すること
- Azure GPUインスタンス（NCシリーズ等）はリージョンによって可用性が異なる
- 研究分野によってAI活用のアプローチが大きく異なる。汎用テンプレートではなく分野特化の提案が必要
