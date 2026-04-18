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
2. **単価取得（MANDATORY — LLM の記憶・推定値の使用を禁止）**:
   エージェントは**必ず以下の手順で最新価格を実際に取得**し、取得結果を見積もり書に貼付すること。
   Web フェッチまたは API 呼び出しが失敗した場合は、見積もり書に「価格未取得」と明記し、
   推定値であることを太字で警告表示する。

   #### Step 2a: Azure Retail Prices API を呼び出す（推奨・最優先）
   以下の URL パターンでブラウザまたは `fetch_webpage` / `curl` で JSON を取得する:
   ```
   https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Machines' and armRegionName eq 'japaneast' and armSkuName eq 'Standard_ND96asr_v4'
   ```
   - `armSkuName` を対象 VM に置き換える（例: `Standard_NC24ads_A100_v4`, `Standard_HB120rs_v3`）
   - `armRegionName` はユーザー指定リージョン（既定: `japaneast`）
   - レスポンス JSON の `retailPrice`（USD/hour）を単価として使用
   - `type` フィールドで `Consumption`（Pay-as-you-go）と `Reservation`（RI）を区別
   - Spot 価格: `$filter` に `and priceType eq 'Consumption' and skuName eq '... Spot'` を追加

   #### Step 2b: Azure 公式価格ページを Web フェッチする（API 失敗時のフォールバック）
   - [Azure VM 価格](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) — GPU VM の Pay-as-you-go / Spot / RI 価格
   - [Azure Storage 価格](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/) — Blob / ADLS Gen2
   - [Azure ML 価格](https://azure.microsoft.com/en-us/pricing/details/machine-learning/) — ML Compute
   - [Azure AI Services 価格](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/) — OpenAI / AI Foundry
   - [Azure Managed Lustre 価格](https://azure.microsoft.com/en-us/pricing/details/managed-lustre/) — HPC ストレージ
   - [Azure Cosmos DB 価格](https://azure.microsoft.com/en-us/pricing/details/cosmos-db/) — グラフ DB
   - [Azure AI Search 価格](https://azure.microsoft.com/en-us/pricing/details/search/) — 検索サービス

   #### Step 2c: 取得する価格項目
   - Pay-as-you-go 価格（USD/hour）
   - Reserved Instance 1年・3年 価格
   - Spot VM 価格
   - Azure for Research / Academic 割引の適用可否

   #### Step 2d: 記録
   - **価格取得日**を見積もり書に必ず記録する
   - **価格ソース**（API URL またはページ URL）を見積もり書に記録する
   - **為替レート**は取得日時点の TTM を使用し、出典を明記する
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

## HARD GATE — 価格検証

見積もり書を最終化する前に、以下のチェックを必ず実行する。**1つでも FAIL した場合、見積もり書を「ドラフト（価格未検証）」と明記し、ユーザーに警告する。**

- [ ] 全 VM SKU の単価が Azure Retail Prices API または公式価格ページから取得されている
- [ ] 取得日が見積もり書に記録されている
- [ ] 取得元 URL が見積もり書に記録されている
- [ ] 為替レートの出典が明記されている
- [ ] LLM の記憶・推定値のみで算出された費目が存在しない

## Gotchas

- **🚫 LLM の学習データに含まれる過去の価格を使ってはならない。** エージェントは必ず `fetch_webpage` ツールまたはターミナルの `curl` で Azure Retail Prices API（`prices.azure.com`）を呼び出し、レスポンス JSON から `retailPrice` を抽出すること。API 呼び出しをスキップして推定値を使った場合、見積もり書に `⚠️ 価格未検証（推定値）` と太字で警告表示すること
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
