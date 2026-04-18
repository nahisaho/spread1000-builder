# draw.io XML 生成ガイド

draw.io MCP Server で使用する XML の生成規則。
本ファイルは [jgraph/drawio-mcp](https://github.com/jgraph/drawio-mcp) の `shared/xml-reference.md` に基づく。

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
| Azure アイコン | 60 × 52（search_shapes 結果に従う） |

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

## search_shapes 検索キーワード集（Azure）

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

## XML の注意事項

- `value` に HTML を含む場合は style に `html=1` を追加
- HTML タグは XML エスケープ: `<` → `&lt;`, `>` → `&gt;`, `&` → `&amp;`
- エッジにウェイポイント（`<Array as="points">`）は追加しない
- `exitX/exitY/entryX/entryY` は原則使わない
- コンテナ内のノードは `parent` でコンテナ ID を指定
