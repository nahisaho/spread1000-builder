# Azure 研究基盤構成設計書

## 1. 設計概要

### 対象研究
<!-- 研究テーマ名を記載 -->

### 設計方針
<!-- アーキテクチャの設計方針・コンセプト -->

## 2. アーキテクチャ図

```mermaid
graph TB
    subgraph "Azure Subscription"
        subgraph "Resource Group: rg-research"
            subgraph "Virtual Network"
                AML[Azure Machine Learning]
                Compute[Compute Cluster<br/>NC/ND Series]
                Storage[Azure Blob Storage]
                KV[Azure Key Vault]
            end
        end
    end
    
    Researcher[研究者] --> AML
    AML --> Compute
    AML --> Storage
    AML --> KV
```

## 3. リソース構成

### コンピューティング

| リソース | サービス | SKU | 数量 | 用途 |
|---------|---------|-----|------|------|
| | | | | |

### ストレージ

| リソース | サービス | SKU | 容量 | 用途 |
|---------|---------|-----|------|------|
| | | | | |

### ネットワーク

| リソース | サービス | 構成 | 用途 |
|---------|---------|------|------|
| | | | |

### セキュリティ

| リソース | サービス | 構成 | 用途 |
|---------|---------|------|------|
| | | | |

## 4. データフロー

```mermaid
flowchart LR
    Data[研究データ] --> Upload[データアップロード]
    Upload --> Blob[Azure Blob Storage]
    Blob --> Preprocess[前処理パイプライン]
    Preprocess --> Train[モデル学習]
    Train --> Registry[モデルレジストリ]
    Registry --> Deploy[推論デプロイ]
```

## 5. セキュリティ設計

### ネットワーク分離
<!-- VNet, NSG, Private Endpoint の構成 -->

### アクセス制御
<!-- RBAC, Managed Identity の構成 -->

### データ保護
<!-- 暗号化、バックアップの構成 -->

## 6. スケーラビリティ設計

### オートスケール設定
<!-- Compute Cluster のスケール設定 -->

### スポット VM 活用
<!-- コスト最適化のためのスポットVM設定 -->

## 7. リージョン選定

| 候補リージョン | GPU 可用性 | レイテンシ | 選定理由 |
|-------------|-----------|----------|---------|
| Japan East | | | |
| Japan West | | | |
| East US | | | |
