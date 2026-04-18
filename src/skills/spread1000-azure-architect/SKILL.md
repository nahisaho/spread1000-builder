---
name: spread1000-azure-architect
description: |
  研究プランに基づいて Microsoft Azure 上の研究基盤アーキテクチャを設計する。
  GPU クラスタ、ML パイプライン、データストレージ、ネットワーク構成を含む
  包括的な構成設計書を生成する。Microsoft Learn MCP を参照して最適な構成を提案する。
  Use when Azure構成を設計したい、GPUクラスタを構築したい、MLパイプラインを設計したい場合。
---

# Azure Architect

研究プランに最適な Microsoft Azure アーキテクチャを設計する。

## Use This Skill When

- 研究プランが確定し Azure 上の研究基盤を設計する段階
- GPU クラスタ・ML パイプラインの構成を決めたい
- データストレージ・ネットワーク構成を最適化したい

## Required Inputs

- `output/phase0-research-plan.md`（研究プラン）
- 研究で必要な計算リソースの概算
- データの種類・サイズ・アクセスパターン

## Workflow

1. **研究プラン分析**: 計算要件・データ要件を抽出する
2. **Azure サービス選定**: 以下の観点で最適なサービスを選択
   - Read `references/azure-research-services.md` when selecting Azure services
   - 計算: Azure Machine Learning, Azure Batch, Azure HPC (NC/ND シリーズ)
   - ストレージ: Azure Blob Storage, Azure Data Lake, Azure NetApp Files
   - データ処理: Azure Databricks, Azure Synapse Analytics
   - AI サービス: Azure OpenAI Service, Azure AI Services
   - ネットワーク: Azure Virtual Network, ExpressRoute
3. **アーキテクチャ設計**:
   - コンポーネント構成図（Mermaid）を作成
   - データフロー図を作成
   - セキュリティ・コンプライアンス要件を定義
   - 可用性・スケーラビリティの設計
4. **WAF ベストプラクティス検証**: Azure Well-Architected Framework の5本柱で設計を検証
   - Read `references/waf-checklist.md` for the full checklist
   - 信頼性: 可用性ゾーン、チェックポイント、リカバリ戦略
   - セキュリティ: ネットワーク分離、Private Endpoint、マネージド ID、RBAC
   - コスト最適化: オートスケール、Spot VM、ストレージ階層化
   - 運用優秀性: IaC、MLOps パイプライン、監視
   - パフォーマンス効率: GPU 活用率、リージョン配置、IOPS
   - 各サービスの WAF Service Guide を `fetch` で参照し、最新の推奨構成を確認
5. **構成設計書生成**: `output/phase1-azure-architecture.md` として保存
   - Reuse `assets/architecture-template.md` when producing the design document
   - WAF 検証結果を「WAF ベストプラクティス適合状況」セクションとして設計書に含める
6. **最終検証**: 研究プランの要件を満たしているか確認

## Deliverables

- `output/phase1-azure-architecture.md`: Azure 構成設計書（完全版）
- アーキテクチャ図（Mermaid 形式で設計書内に埋め込み）

## Quality Gates

- [ ] 研究プランの全計算要件が Azure リソースにマッピングされている
- [ ] GPU 仕様が研究に必要なモデルサイズ・学習量に適合している
- [ ] データストレージの容量・スループットが研究データの要件を満たす
- [ ] セキュリティ（RBAC、ネットワーク分離、暗号化）が設計されている
- [ ] スケーラビリティ（オートスケール、スポット VM 活用）が考慮されている
- [ ] リージョン選定の根拠が明記されている
- [ ] WAF 5本柱のチェックリストで検証済み（`references/waf-checklist.md` 参照）
- [ ] WAF Service Guide の構成推奨事項が設計に反映されている

## Gotchas

- Azure の GPU VM（NCシリーズ、NDシリーズ）はリージョンによって可用性が大きく異なる。Japan East で利用可能か必ず確認すること
- Azure Machine Learning のコンピューティングクラスタとコンピューティングインスタンスは用途が異なる。学習にはクラスタ、開発にはインスタンスを使う
- Azure Blob Storage のアクセス層（Hot/Cool/Archive）はデータのアクセス頻度に応じて適切に選択すること
- 学術研究向けの Azure Sponsorship / Academic Grant が利用可能か確認すること

## Security Guardrails

- 医療データ（DICOM・FHIR・ゲノム）を扱う場合、Azure Health Data Services の Private Endpoint と RBAC を必須とする
- 個人情報・機密データを含む研究は Azure TRE の Restricted Workspace + Airlock を設計に含めること
- ストレージはデフォルトで保存時暗号化（SSE）+ TLS 1.2 以上。カスタマーマネージドキー（CMK）の要否を明記すること
- Key Vault でシークレット管理。接続文字列・キーをテンプレートやコードにハードコードしないこと

## Validation Loop

1. 構成設計書を生成する
2. **研究要件チェック**:
   - 研究プランの計算要件カバレッジ ≥ 100%
   - 選定したVMサイズのGPUメモリが学習に十分か
   - ストレージIOPSがデータ処理要件を満たすか
3. **WAF ベストプラクティスチェック**:
   - `references/waf-checklist.md` の5本柱チェックリストを全項目検証
   - 採用した各 Azure サービスの WAF Service Guide を `fetch` で取得:
     - Azure Machine Learning: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-machine-learning`
     - Azure Blob Storage: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-blob-storage`
     - Azure Key Vault: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-key-vault`
     - その他採用サービス: `https://learn.microsoft.com/azure/well-architected/service-guides/` で検索
   - 「構成推奨事項 (Configuration recommendations)」セクションの各項目を設計と照合
4. If any check fails:
   - VM サイズまたはサービスを再選定
   - WAF Service Guide の構成推奨事項に従って設計を修正
   - 再検証する
5. 全ゲートをパスした後のみ成果物を最終化する
