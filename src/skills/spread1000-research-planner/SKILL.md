---
name: spread1000-research-planner
description: |
  AI for Science の研究プランを策定する。研究者の専門分野にAIをどう組み込むかを
  Webリサーチ・論文調査を通じて提案し、具体的な研究計画書を生成する。
  Use when 研究テーマへのAI活用方法がわからない、研究プランを作りたい、
  AI for Scienceの最新動向を知りたい場合。
---

# Research Planner

研究者の専門分野に最適な AI 活用研究プランを策定する。

## Use This Skill When

- 研究テーマは決まっているが AI の活用方法がわからない
- AI for Science の成功事例や最新動向を調査したい
- SPReAD に応募するための研究計画書を作成したい

## Required Inputs

- 研究者の専門分野（例: 材料科学、生命科学、気象学など）
- 研究テーマまたは課題の概要
- 現在の研究手法・使用データの概要（任意）

## Workflow

1. **ヒアリング**: 研究者の分野・テーマ・現在の課題を確認する
2. **Web リサーチ**: 以下を調査する
   - 同分野における AI for Science の成功事例（国内外）
   - 適用可能な AI/ML 手法（深層学習、強化学習、生成AI、シミュレーション等）
   - 利用可能なデータセット・計算基盤
   - 文部科学省 AI for Science 推進委員会の最新方針
3. **AI 活用方針の策定**:
   - 研究課題に対する AI 手法のマッピング
   - 期待される成果・ブレークスルーの明確化
   - 必要な計算リソース（GPU、ストレージ、ネットワーク等）の概算
4. **研究プラン生成**: `output/phase0-research-plan.md` として保存
   - Reuse `assets/research-plan-template.md` when producing the research plan
5. **レビュー**: 研究プランの技術的実現可能性を検証

## Deliverables

- `output/phase0-research-plan.md`: AI 活用研究プラン（完全版）
- `output/phase0-research-survey.md`: Web リサーチ結果のサマリー

## Quality Gates

- [ ] 研究テーマと AI 手法の対応が明確に記述されている
- [ ] 3 件以上の関連事例が引用されている
- [ ] 必要な計算リソースが定量的に見積もられている
- [ ] 研究スケジュール（マイルストーン）が含まれている
- [ ] AI for Science の文脈での新規性・革新性が説明されている

## Gotchas

- AI 手法の選定は研究データの特性に強く依存する。データ形式（画像、時系列、テキスト、3D構造等）を必ず確認すること
- 「AI を使えば何でもできる」という過度な期待を研究計画に反映しないこと。技術的制約を明示する
- 計算リソースの見積もりは、学習データサイズ・モデル規模・学習回数から具体的に算出すること
- 研究分野によって利用すべきフレームワーク（PyTorch/TensorFlow/JAX等）が異なる

## Validation Loop

1. 研究プランを生成する
2. Check:
   - AI手法と研究課題の対応が論理的か
   - 計算リソース見積もりが現実的か
   - スケジュールが実行可能か
3. If any check fails:
   - 該当セクションを特定し修正
   - Web リサーチで補足情報を取得
   - 再検証する
4. 全ゲートをパスした後のみ成果物を最終化する
