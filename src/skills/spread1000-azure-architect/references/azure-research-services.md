# Azure 研究基盤向けサービスリファレンス

Azure サービス選定時に参照する。研究用途に特化したサービスと推奨構成を記載。

## コンピューティング

### GPU VM シリーズ（ML/DL 学習向け）

| シリーズ | GPU | VRAM | 用途 |
|---------|-----|------|------|
| NC A100 v4 | NVIDIA A100 | 80GB | 大規模モデル学習 |
| ND H100 v5 | NVIDIA H100 | 80GB | 超大規模モデル学習 |
| NC T4 v3 | NVIDIA T4 | 16GB | 推論・小規模学習 |
| NV v3 | NVIDIA M60 | 8GB | 可視化・軽量推論 |

### コンピューティングサービス

| サービス | 用途 | 推奨シナリオ |
|---------|------|-------------|
| Azure Machine Learning | ML ワークフロー全般 | 実験管理・モデル学習・デプロイ |
| Azure Batch | 大規模バッチ処理 | パラメータスイープ・シミュレーション |
| Azure CycleCloud | HPC クラスタ管理 | MPI 並列計算・伝統的HPC |
| Azure Kubernetes Service | コンテナオーケストレーション | マイクロサービス型MLパイプライン |

## ストレージ

| サービス | 用途 | 推奨シナリオ |
|---------|------|-------------|
| Azure Blob Storage | オブジェクトストレージ | 学習データ・モデルアーティファクト |
| Azure Data Lake Storage Gen2 | 階層型ストレージ | 大規模データレイク |
| Azure NetApp Files | NFS 共有ストレージ | HPC ノード間共有データ |
| Azure Managed Lustre | 高性能並列ファイルシステム | 超大規模並列I/O |

## AI サービス

| サービス | 用途 | 推奨シナリオ |
|---------|------|-------------|
| Azure OpenAI Service | LLM API | テキスト生成・要約・分類 |
| Azure AI Search | ベクトル検索 | 論文検索・知識ベース |
| Azure AI Document Intelligence | 文書解析 | 論文PDF解析・データ抽出 |

## 分野特化データ基盤

| サービス | 用途 | 推奨シナリオ |
|---------|------|-------------|
| Azure Health Data Services (DICOM) | 医用画像保存・検索 | CT/MRI/X線の AI 解析研究 |
| Azure Health Data Services (FHIR) | 臨床データ標準化 | 患者情報・検査結果の研究活用 |
| De-identification service | 臨床テキスト匿名化 | PHI 除去・HIPAA 準拠 |
| Microsoft Planetary Computer | 地球環境データ分析 | 衛星画像・気候・生物多様性データ |
| Azure Trusted Research Environment | セキュアリサーチ基盤 | 機密データ（臨床・ゲノム等）の安全な分析環境 |

## ネットワーク

| サービス | 用途 |
|---------|------|
| Azure Virtual Network | ネットワーク分離 |
| Azure Private Endpoint | プライベート接続 |
| Azure Bastion | セキュアなVM接続 |
| Azure ExpressRoute | オンプレミス接続（大学ネットワーク） |

## セキュリティ・ガバナンス

| サービス | 用途 |
|---------|------|
| Azure Key Vault | シークレット管理 |
| Microsoft Entra ID | ID管理・RBAC |
| Azure Policy | コンプライアンス |
| Microsoft Defender for Cloud | セキュリティ監視 |
