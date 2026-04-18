---
name: spread1000-proposal-writer
description: |
  SPReAD の申請書（研究計画書）を作成する。研究プラン、Azure 構成設計、
  コスト見積もりを統合し、公募要件に沿った申請書を生成する。
  Use when 申請書を書きたい、研究計画書を仕上げたい、公募書類を作成したい場合。
---

# Proposal Writer

研究プラン・Azure 構成設計・コスト見積もりを統合し、SPReAD の公募要件に沿った申請書を生成する。

## Use This Skill When

- 研究プラン・Azure 構成・コスト見積もりが揃い、申請書を作成する段階
- SPReAD の公募要件に沿った研究計画書を仕上げたい
- 申請書の品質チェック・推敲をしたい

## Required Inputs

- `output/phase0-research-plan.md`（研究プラン）
- `output/phase1-azure-architecture.md`（Azure 構成設計書）
- `output/phase2-cost-estimate.md`（コスト見積もり）
- 研究代表者・分担者の情報
- 所属機関の情報
- 研究期間: 交付決定日〜令和9年1月6日（約180日間）

## Workflow

1. **前提条件チェック（MANDATORY）**:
   - `output/phase2-cost-estimate.md` が存在することを確認する
   - 存在しない場合、**まず `spread1000-cost-estimator` を実行してコスト見積もりを生成してから申請書作成に進む**
   - Phase 2 が「ドラフト（価格未検証）」状態の場合、申請書の経費欄に `⚠️ 価格未検証（推定値）` と太字で警告表示する
   - **経費欄の数値を LLM の記憶で推定して埋めてはならない。必ず Phase 2 の取得済み単価を使用すること**
2. **入力統合**: Phase 0〜2 の成果物を読み込み統合する
2. **公募要件確認**: SPReAD の公募要件を確認
   - Read `references/proposal-guidelines.md` when checking requirements
3. **申請書構成**（様式1の各セクションに対応、文字数制限を厳守）:
   - **I. 研究目的**（80〜400文字）— 研究課題の目的、対象とする現象・課題
   - **II. 研究方法**（160〜800文字）— 工程ごとのAI適用、データ・評価指標・検証方法
   - **III. AI利活用の妥当性・実現可能性**（160〜800文字）— 従来手法の限界、AI導入の意義
   - **IV. 達成目標**（100〜500文字）— 中間（3ヶ月後）・最終（6ヶ月後）の到達目標
   - **V. AI利活用のノウハウ抽出・共有の実現計画**（60〜300文字）— コミュニティ共有・他分野展開
     - Reuse `assets/knowhow-sharing-template.md` when producing the know-how sharing section
   - **参考）図の貼付**（最大1枚）— Phase 1b の draw.io 構成図から選択
   - **VI. 研究業績等**（最大5件）— 学術論文・学会発表・著書の箇条書き
   - 研究基盤計画（Azure 構成）
   - 経費計画と積算根拠（直接経費500万円以下）
4. **申請書生成**: `output/phase3-proposal.md` として保存
   - Reuse `assets/proposal-template.md` when producing the proposal
5. **品質レビュー**: 公募要件との整合性、論理的一貫性を確認

## Deliverables

- `output/phase3-proposal.md`: SPReAD 申請書（完全版）

## Quality Gates

- [ ] 公募要件の全必須項目が網羅されている
- [ ] AI for Science としての革新性が明確に説明されている
- [ ] 研究計画と Azure 構成の整合性がとれている
- [ ] 経費計画の積算根拠がコスト見積もり書と一致している
- [ ] 研究スケジュールにマイルストーンが設定されている
- [ ] 日本語として自然で読みやすい文章になっている

## Gotchas

- **🚫 経費欄の数値を LLM の学習データや推定値で埋めてはならない。** 経費の積算根拠は必ず `output/phase2-cost-estimate.md` の Azure Retail Prices API 取得済み単価に基づくこと。Phase 2 が存在しない場合は `spread1000-cost-estimator` を先に実行する
- SPReAD は「AI を活用した科学研究の革新」が主旨。既存手法の単純な置き換えではなく、AI によって初めて可能になる研究アプローチを強調すること
- 経費計画は SPReAD の予算上限（直接経費500万円以下）に収まるようにコスト見積もりを調整すること
- 研究倫理・データ管理ポリシーへの言及を忘れないこと
  - Read `references/dmp-guide.md` when producing data management sections
- 申請書の文字数制限を厳守すること（各セクションに日本語/英語の文字数範囲が指定されている）
- 様式1はExcelのまま提出（PDF化不可）。テンプレートの文字数をカウントして範囲内に収めること
- 図は最大1枚。Phase 1b の draw.io 構成図から最も適切なものを選択すること

## Security Guardrails

- 申請書に実際の患者データ・個人情報・機密データを含めないこと。データ例は必ず匹名化・ダミー化する
- 研究倫理審査（IRB）およびデータ管理計画（DMP）への言及を必須とする
- 医療データを扱う研究では、データ保護規制（個人情報保護法・HIPAA 等）への準拠を明記すること

## Validation Loop

1. 申請書を生成する
2. Check:
   - 公募要件の全項目がカバーされているか
   - Phase 0〜2 の成果物との整合性があるか
   - 文章が論理的に一貫しているか
3. If any check fails:
   - 不足項目を追記する
   - 矛盾箇所を修正する
   - 文章を推敲する
4. 全ゲートをパスした後のみ成果物を最終化する
