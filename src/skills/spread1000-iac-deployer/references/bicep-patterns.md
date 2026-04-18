# Bicep パターンリファレンス

研究基盤の Bicep テンプレート生成時に準拠するパターン集。

## ディレクトリ構造

```
infra/
├── main.bicep              # エントリーポイント
├── modules/
│   ├── network.bicep       # VNet, NSG, Subnets
│   ├── storage.bicep       # Storage Account, Containers
│   ├── keyvault.bicep      # Key Vault
│   ├── monitoring.bicep    # Log Analytics, App Insights
│   ├── machinelearning.bicep  # AML Workspace, Compute
│   └── compute.bicep       # VM, Batch (必要時)
├── parameters/
│   ├── dev.bicepparam      # 開発環境
│   ├── staging.bicepparam  # ステージング
│   └── prod.bicepparam     # 本番環境
└── bicepconfig.json        # Bicep 設定
```

## 命名規則

| リソースタイプ | パターン | 例 |
|-------------|---------|-----|
| Resource Group | rg-{project}-{env} | rg-myresearch-dev |
| Storage Account | st{project}{env} | stmyresearchdev |
| Key Vault | kv-{project}-{env} | kv-myresearch-dev |
| Virtual Network | vnet-{project}-{env} | vnet-myresearch-dev |
| ML Workspace | mlw-{project}-{env} | mlw-myresearch-dev |
| Compute Cluster | cc-{purpose} | cc-training |

## モジュール設計原則

1. **1モジュール = 1リソースタイプ**: 関連リソースをまとめる
2. **パラメータで差異を吸収**: 環境ごとの差はパラメータファイルで管理
3. **出力で接続**: モジュール間の依存は output/input で明示的に接続
4. **タグの統一**: 全リソースに共通タグを適用

## セキュリティパターン

### マネージド ID
```bicep
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-identity'
  location: location
  tags: tags
}
```

### Private Endpoint
```bicep
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${prefix}-pe-${serviceName}'
  location: location
  properties: {
    subnet: { id: subnetId }
    privateLinkServiceConnections: [
      {
        name: '${prefix}-plsc-${serviceName}'
        properties: {
          privateLinkServiceId: serviceResourceId
          groupIds: [groupId]
        }
      }
    ]
  }
}
```

## GPU コンピュートクラスタ

```bicep
resource computeCluster 'Microsoft.MachineLearningServices/workspaces/computes@2024-04-01' = {
  parent: workspace
  name: 'gpu-cluster'
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: 'Standard_NC24ads_A100_v4'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 4
        nodeIdleTimeBeforeScaleDown: 'PT15M'
      }
      vmPriority: 'LowPriority' // スポット VM
      subnet: { id: subnetId }
    }
  }
}
```

## パラメータファイル例

```bicepparam
using '../main.bicep'

param projectName = 'myresearch'
param environment = 'dev'
param ownerName = 'researcher@university.ac.jp'
param researchTopic = 'AI-driven materials discovery'
```
