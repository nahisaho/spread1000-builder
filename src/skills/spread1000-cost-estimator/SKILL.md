---
name: spread1000-cost-estimator
description: |
  Azure 構成設計書に基づいてコストを算出する。月額・研究期間全体（約180日間）の
  費用見積もりを生成し、SPReAD の予算申請に必要なコスト明細を作成する。
  Use when Azureのコストを見積もりたい、予算計画を立てたい、申請書の経費欄を書きたい場合。
---

# Cost Estimator

Azure 構成設計書からコストを算出し、SPReAD の予算申請に対応した見積もりを生成する。

## Use This Skill When

- Azure 構成設計が完了し費用を見積もる段階
- SPReAD 申請書の経費計画を作成したい
- コスト最適化（スポット VM、リザーブドインスタンス等）を検討したい

## Required Inputs

- `output/phase1-azure-architecture.md`（Azure 構成設計書）
- 研究期間（約180日間 = 約6ヶ月）
- 月間利用時間の見込み（GPU稼働時間等）

## Workflow

1. **構成設計書の解析**: リソース一覧・SKU・数量を抽出する
2. **単価取得**: Web リサーチで Azure の最新価格を取得する
   - **必ず以下の公式ページから最新価格を取得すること**（キャッシュ・記憶の価格を使わない）:
     - [Azure VM 価格](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) — GPU VM (NC/ND シリーズ) の Pay-as-you-go / Spot / RI 価格
     - [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices) — プログラマティックに最新単価を取得可能（`https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Machines' and armRegionName eq 'japaneast' and skuName eq '...'`）
     - [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) — 構成全体の見積もり作成
     - [Azure Storage 価格](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/) — Blob / ADLS Gen2
     - [Azure ML 価格](https://azure.microsoft.com/en-us/pricing/details/machine-learning/) — ML Compute
   - 取得する価格:
     - Pay-as-you-go 価格
     - Reserved Instance (1年/3年) 価格
     - Spot VM 価格
     - Azure for Research / Academic 割引の適用可否
   - **価格取得日を見積もり書に必ず記録する**
3. **コスト算出**:
   - 月額コスト（通常利用・ピーク利用）
   - 研究期間全体（約180日間）の総コスト
   - コスト最適化オプションの比較
   - 直接経費500万円以下への収毾確認
4. **予算計画書生成**: `output/phase2-cost-estimate.md` として保存
   - Reuse `assets/cost-estimate-template.md` when producing the estimate
5. **検証**: SPReAD の予算上限（直接経費500万円以下）との整合性を確認

## Deliverables

- `output/phase2-cost-estimate.md`: コスト見積もり書（完全版）

## Quality Gates

- [ ] 全リソースの単価根拠が明記されている
- [ ] 月額・総額の2段階で見積もりが提示されている
- [ ] コスト最適化オプション（スポットVM、RI、シャットダウンスケジュール）が検討されている
- [ ] SPReAD の予算要件（直接経費500万円以下・間接経費30%）との整合性が確認されている
- [ ] 為替レート（JPY/USD）が明記されている

## Gotchas

- Azure の GPU VM 価格は頻繁に変動する。**必ず Web リサーチで最新価格を取得し**、見積もり時点の日付を記録すること。LLM の学習データに含まれる過去の価格を使ってはならない
- Azure Retail Prices API (`prices.azure.com`) を使えば JSON で最新単価を取得できる。`armRegionName` は `japaneast` を既定とし、ユーザーの希望リージョンに合わせて変更すること
- スポット VM は最大90%割引だが、プリエンプションのリスクがある。学習の中断耐性（チェックポイント）を前提とすること
- Azure for Research プログラムの割引率は申請内容によって異なる。確定額ではなく参考値として記載すること
- 隠れコスト（データ転送、ログストレージ、Key Vault 操作）を見落とさないこと

## Validation Loop

1. コスト見積もりを生成する
2. Check:
   - 全リソースがカバーされているか
   - 合計金額が予算上限内か
   - コスト最適化の余地が検討されているか
3. If any check fails:
   - VM サイズのダウングレードまたはスポット VM 切替を検討
   - 利用時間の最適化（夜間シャットダウン等）を提案
   - 再計算する
4. 全ゲートをパスした後のみ成果物を最終化する
