# Azure Well-Architected Framework (WAF) チェックリスト — 研究基盤向け

Azure 構成設計書のベストプラクティス適合を検証するための WAF 5本柱チェックリスト。
各項目に対応する Microsoft Learn のサービスガイド URL を記載。

## 参照すべき WAF Service Guides

設計で採用した Azure サービスごとに、以下の WAF Service Guide を参照すること:

| サービス | WAF Service Guide URL |
|---------|----------------------|
| Azure Machine Learning | https://learn.microsoft.com/azure/well-architected/service-guides/azure-machine-learning |
| Azure Blob Storage | https://learn.microsoft.com/azure/well-architected/service-guides/azure-blob-storage |
| Azure Key Vault | https://learn.microsoft.com/azure/well-architected/service-guides/azure-key-vault |
| Azure Virtual Network | https://learn.microsoft.com/azure/well-architected/service-guides/azure-virtual-network |
| Azure Batch | https://learn.microsoft.com/azure/well-architected/service-guides/azure-batch |
| Azure Kubernetes Service | https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service |

> **Microsoft Learn MCP が利用可能な場合**: `fetch` ツールで上記 URL を取得し、最新のチェックリストと構成推奨事項を参照する。

---

## 1. 信頼性 (Reliability)

> 参照: https://learn.microsoft.com/azure/well-architected/reliability/checklist

### 研究基盤向けチェック項目

- [ ] **可用性ゾーン**: コンピューティングリソースが可用性ゾーンに分散配置されているか
- [ ] **チェックポイント**: 大規模モデル学習にチェックポイント機能（PyTorch / TensorFlow）が設計に含まれているか
- [ ] **リカバリ戦略**: AML ワークスペースと依存リソース（Key Vault, Storage, ACR）のリカバリ戦略が定義されているか
- [ ] **データ冗長性**: Storage の冗長構成（LRS/ZRS/GRS/GZRS）が研究データの重要度に対して適切か
- [ ] **探索/本番分離**: 実験用ワークスペースと本番ワークスペースが分離されているか
- [ ] **Soft Delete**: Blob Storage の Soft Delete / バージョニング / ポイントインタイムリストアが有効か

### 構成推奨事項

| 推奨事項 | 理由 |
|---------|------|
| Dedicated VM tier をバッチ推論に使用 | Low-priority VM はプリエンプトされる可能性がある |
| 学習チェックポイントを有効化 | 中断からの復旧が可能 |
| Storage を ZRS 以上で構成 | AZ 障害時のデータ保護 |

---

## 2. セキュリティ (Security)

> 参照: https://learn.microsoft.com/azure/well-architected/security/checklist

### 研究基盤向けチェック項目

- [ ] **ネットワーク分離**: AML ワークスペースへのアクセスが VNet 内に制限されているか
- [ ] **Private Endpoint**: Storage / Key Vault / ACR に Private Endpoint が構成されているか
- [ ] **マネージド ID**: サービス間認証にマネージド ID を使用し、接続文字列のハードコードがないか
- [ ] **RBAC 最小権限**: ワークスペース / ストレージへの RBAC が最小権限の原則に従っているか
- [ ] **データ流出防止**: AML ワークスペースの送信モードが「承認された送信のみ許可」か
- [ ] **公開 SSH ポート無効**: コンピューティングクラスタの SSH ポートが無効化されているか
- [ ] **パブリック IP なし**: コンピューティングに `enableNodePublicIp: false` が設定されているか
- [ ] **ローカル認証無効**: コンピューティングのローカル認証が無効化されているか
- [ ] **暗号化**: 保存時暗号化（SSE）+ TLS 1.2 以上。CMK の要否が明記されているか
- [ ] **Storage 匿名アクセス無効**: Blob コンテナの匿名読み取りが無効か
- [ ] **Storage 共有キー無効**: Shared Key 認証が無効化されているか

### 構成推奨事項

| 推奨事項 | 理由 |
|---------|------|
| Managed VNet Isolation を構成 | ワークスペースをネットワーク的に隔離 |
| Storage の公開エンドポイントを無効化 | 攻撃面の最小化 |
| Microsoft Defender for Storage を有効化 | 異常活動の脅威検出 |
| Resource Manager ロックを適用 | 誤削除からの保護 |

---

## 3. コスト最適化 (Cost Optimization)

> 参照: https://learn.microsoft.com/azure/well-architected/cost-optimization/checklist

### 研究基盤向けチェック項目

- [ ] **適切なリソース選定**: CPU vs GPU、SKU サイズが研究ワークロードに最適か
- [ ] **アイドル時シャットダウン**: コンピューティングインスタンスにアイドル時シャットダウンが設定されているか
- [ ] **オートスケール**: コンピューティングクラスタの最小ノード数が 0 に設定されているか
- [ ] **Spot VM 活用**: 中断耐性のあるバッチワークロードに Low-priority / Spot VM を使用しているか
- [ ] **早期終了ポリシー**: 学習のパフォーマンス不良時に早期終了するポリシーが設定されているか
- [ ] **ストレージ階層化**: データアクセス頻度に応じて Hot/Cool/Archive が適切に選択されているか
- [ ] **ライフサイクル管理**: ストレージのライフサイクルポリシーが構成されているか
- [ ] **予算ガードレール**: Azure Budget / Policy によるコスト上限が設定されているか
- [ ] **SPReAD 予算制約**: 直接経費500万円以下の制約に収まっているか

### 構成推奨事項

| 推奨事項 | 理由 |
|---------|------|
| 学習クラスタの最小ノード = 0 | 未使用時のコスト排除 |
| 学習の並列化テスト | 低コスト SKU で要件を満たせる可能性 |
| アクセス層への直接アップロード | 不要な階層変更コストの回避 |

---

## 4. 運用優秀性 (Operational Excellence)

> 参照: https://learn.microsoft.com/azure/well-architected/operational-excellence/checklist

### 研究基盤向けチェック項目

- [ ] **MLOps パイプライン**: データ準備 → 学習 → スコアリングの自動パイプラインが計画されているか
- [ ] **IaC**: AML ワークスペース / コンピュート / 依存リソースが Bicep / Terraform で定義されているか
- [ ] **モデルレジストリ**: モデルのバージョン管理と共有が計画されているか
- [ ] **監視**: デプロイ済みモデルのパフォーマンス監視とデータドリフト検出が計画されているか
- [ ] **Application Insights**: オンラインエンドポイントに Application Insights が有効化されているか
- [ ] **キュレーション環境**: AML の事前構築済み環境（Azure Container for PyTorch 等）を活用しているか
- [ ] **Storage 監視**: Storage Insights ダッシュボードが計画されているか
- [ ] **リソースログ**: 診断設定で Azure Monitor Logs へのログ転送が構成されているか

### 構成推奨事項

| 推奨事項 | 理由 |
|---------|------|
| ノートブックより**スクリプト**で学習 | 自動パイプラインへの統合容易性 |
| ワークスペース数を最小化 | 運用メンテナンスコストの削減 |
| IaC + Azure Policy で構成を標準化 | 構成ドリフトの防止 |

---

## 5. パフォーマンス効率 (Performance Efficiency)

> 参照: https://learn.microsoft.com/azure/well-architected/performance-efficiency/checklist

### 研究基盤向けチェック項目

- [ ] **学習時間目標**: 許容される学習時間と再学習頻度が定義されているか
- [ ] **コンピュート選定**: CPU vs GPU の選定根拠が明確か。テスト結果に基づいているか
- [ ] **オートスケール**: デプロイ環境にオートスケール機能があるか
- [ ] **リージョン最適化**: ストレージと計算リソースが同一リージョンに配置されているか
- [ ] **GPU 活用率**: GPU メモリ / コアの活用率が監視計画に含まれているか
- [ ] **Storage IOPS**: ストレージの IOPS / スループットがデータ処理要件を満たすか
- [ ] **インフラ監視**: CPU/GPU/メモリ使用率のモニタリングが計画されているか

### 構成推奨事項

| 推奨事項 | 理由 |
|---------|------|
| 学習にはコンピュートインスタンスよりクラスタを使用 | オートスケールによるパフォーマンス向上 |
| 同一リージョンに Storage とコンピュートを配置 | レイテンシ削減 + リージョン内転送無料 |
| 複数 SKU でベンチマークテスト | コスト対パフォーマンスの最適化 |

---

## Azure Policy によるガバナンス検証

以下の Azure Policy ビルトイン定義による自動チェックが推奨される:

| ポリシー | チェック内容 |
|---------|------------|
| AML ワークスペースの公開ネットワーク無効 | ネットワーク分離の強制 |
| AML コンピュートの VNet 配置 | コンピュートのネットワーク分離 |
| AML のローカル認証無効 | 認証のセキュリティ |
| AML ワークスペースの Private Link 使用 | Private Endpoint の強制 |
| AML の CMK 暗号化 | データ保護 |
| AML のユーザー割り当てマネージド ID | ID 管理 |
| AML コンピュートのアイドルシャットダウン | コスト最適化 |
| AML のレジストリ制限 | 承認済みレジストリのみ許可 |
| Storage の匿名アクセス無効 | セキュリティ |
| Storage の HTTPS 強制 | 通信暗号化 |
| Storage のファイアウォール規則 | ネットワーク制限 |

> 参照: https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#machine-learning

---

## 使用方法

1. **設計完了後**: 構成設計書（`phase1-azure-architecture.md`）をこのチェックリストで照合
2. **Microsoft Learn MCP 参照**: `fetch` ツールで各サービスの WAF Service Guide URL を取得し、最新のチェック項目を確認
3. **不適合項目の修正**: チェックに不合格の項目について設計を修正
4. **検証結果の記録**: 各チェック項目の合否を構成設計書に追記
