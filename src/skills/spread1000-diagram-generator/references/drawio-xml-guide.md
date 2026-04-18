# draw.io 図面生成ガイド

[simonkurtz-MSFT/drawio-mcp-server](https://github.com/simonkurtz-MSFT/drawio-mcp-server) で使用する図面生成の規則。

## リジッドグリッド

全ノードの配置に以下のグリッドを使用する:

- x = `col_index * 180 + 40`（col 0 = 40, col 1 = 220, col 2 = 400, …）
- y = `row_index * 120 + 40`（row 0 = 40, row 1 = 160, row 2 = 280, …）

### ノードサイズ

| 形状 | width × height |
|------|---------------|
| 矩形 | 140 × 60 |
| ダイヤモンド | 140 × 80 |
| 円 | 60 × 60 |
| ドキュメント | 120 × 80 |
| シリンダー | 100 × 70 |
| Azure アイコン | 60 × 60（`search-shapes` 結果に従う） |

## Azure アーキテクチャ図の構成パターン

### コンテナのネスト構造

```
Resource Group（最外）
  └── VNet
       ├── Subnet: Compute
       │    ├── GPU VM (NC24ads_A100_v4)
       │    └── CPU VM (D16s_v5)
       ├── Subnet: Storage
       │    ├── Blob Storage
       │    └── Managed Lustre
       ├── Subnet: AI Services
       │    └── AI Foundry
       └── Subnet: Management
            ├── Key Vault
            └── Log Analytics
```

### 色分け規則

| レイヤー | fillColor | strokeColor | 用途 |
|---------|-----------|-------------|------|
| Resource Group | #F5F5F5 | #666666 | 最外コンテナ |
| VNet | #E8F5E9 | #4CAF50 | ネットワーク境界 |
| Subnet: Compute | #E3F2FD | #2196F3 | コンピューティング |
| Subnet: Storage | #FFF3E0 | #FF9800 | ストレージ |
| Subnet: AI | #F3E5F5 | #9C27B0 | AI サービス |
| Subnet: Management | #ECEFF1 | #607D8B | 管理・監視 |

### エッジ（矢印）の使い分け

| 矢印タイプ | style | 用途 |
|-----------|-------|------|
| 実線矢印 | `edgeStyle=orthogonalEdgeStyle` | データフロー |
| 破線矢印 | `edgeStyle=orthogonalEdgeStyle;dashed=1` | 管理・監視 |
| 太線矢印 | `edgeStyle=orthogonalEdgeStyle;strokeWidth=2` | 主要データパス |

## search-shapes 検索キーワード集（Azure）

| Azure サービス | 検索キーワード |
|--------------|--------------|
| Virtual Machines | `Azure Virtual Machine` |
| Blob Storage | `Azure Blob Storage` |
| Key Vault | `Azure Key Vault` |
| Virtual Network | `Azure Virtual Network` |
| Machine Learning | `Azure Machine Learning` |
| AI Foundry | `Azure AI` |
| Log Analytics | `Azure Monitor` |
| Application Insights | `Azure Application Insights` |
| Cosmos DB | `Azure Cosmos DB` |
| AI Search | `Azure Cognitive Search` |
| Container Registry | `Azure Container Registry` |
| Managed Lustre | `Azure Managed Lustre` or `Azure Storage` |
| Batch | `Azure Batch` |
| NSG | `Azure Network Security Group` |

> ファジー検索対応: 部分一致で検索可能。`search-shapes` の `queries` パラメータに配列で一括渡しが効率的。

## 図面構築の注意事項

- `add-cells` は配列を受け付ける — 全セルを**1回の呼び出し**で追加する
- `temp_id` で同バッチ内のセル間参照（エッジの source/target）が可能
- `shape_name` パラメータで Azure アイコンを直接指定可能（`search-shapes` 不要）
- グループ/コンテナは `create-groups` で作成し、`add-cells-to-group` でセルを配置
- `export-diagram` で最終的な draw.io XML を取得してファイルに保存する
- `import-diagram` で既存の draw.io XML を読み込んで編集再開が可能
