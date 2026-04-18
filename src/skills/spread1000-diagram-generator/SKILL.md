---
name: spread1000-diagram-generator
description: |
  draw.io MCP Server（simonkurtz-MSFT）を使用して、Azure 研究基盤のシステム構成図・データフロー図・
  ネットワーク図を draw.io 形式で生成する。700+ の Azure 公式アイコンが内蔵されており、
  search-shapes でファジー検索して取得できる。
  Phase 1（azure-architect）の設計書から視覚的なアーキテクチャ図を自動作成する。
  Use when システム構成図を作りたい、アーキテクチャ図を draw.io で作成したい、
  Azure 構成の図面を生成したい、データフロー図が欲しい場合。
---

# Diagram Generator

[draw.io MCP Server（simonkurtz-MSFT）](https://github.com/simonkurtz-MSFT/drawio-mcp-server)を活用して、Azure 研究基盤のプロフェッショナルなシステム構成図を生成する。700+ の Azure 公式アイコン内蔵、ブラウザ不要。

## Use This Skill When

- Azure 構成設計書（Phase 1）からシステム構成図を作りたい
- 申請書に添付するアーキテクチャ図を draw.io 形式で作りたい
- データフロー図・ネットワーク構成図が必要
- Mermaid では表現しきれない詳細な図面が必要

## Required Inputs

- `output/phase1-azure-architecture.md`（Azure 構成設計書）
- 図の種類の指定（システム構成図 / データフロー図 / ネットワーク図 / セキュリティ図）

## Prerequisites

### draw.io MCP Server のセットアップ

[simonkurtz-MSFT/drawio-mcp-server](https://github.com/simonkurtz-MSFT/drawio-mcp-server) を以下のいずれかの方法でセットアップする:

#### 方法 1: Docker（推奨）

```bash
docker pull simonkurtzmsft/drawio-mcp-server:latest
docker run -d --name drawio-mcp-server -p 8080:8080 simonkurtzmsft/drawio-mcp-server:latest
```

VS Code の `.vscode/mcp.json` に追加:

```json
{
  "servers": {
    "drawio": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

#### 方法 2: ソースから実行（Deno v2.3+ 必要）

```bash
git clone https://github.com/simonkurtz-MSFT/drawio-mcp-server.git
cd drawio-mcp-server
deno run --allow-net --allow-read --allow-env src/index.ts
```

VS Code の `.vscode/mcp.json` に追加:

```json
{
  "servers": {
    "drawio": {
      "command": "deno",
      "args": [
        "run", "--allow-net", "--allow-read", "--allow-env",
        "/path/to/drawio-mcp-server/src/index.ts"
      ]
    }
  }
}
```

## MCP Tools

### シェイプ検索

| ツール | 用途 |
|--------|------|
| `search-shapes` | Azure 公式アイコン 700+ 件をファジー検索し、正確な style 文字列を取得 |
| `get-shape-categories` | シェイプカテゴリ一覧（General, Flowchart, Azure カテゴリ）を取得 |
| `get-shapes-in-category` | カテゴリ内の全シェイプを取得 |
| `get-style-presets` | Azure/フローチャート等の組み込みスタイルプリセットを取得 |

### 図の操作

| ツール | 用途 |
|--------|------|
| `add-cells` | 頂点・エッジを一括追加。`shape_name` でアイコン解決、`temp_id` でバッチ内参照が可能 |
| `edit-cells` | セルのプロパティ（位置・サイズ・テキスト・スタイル）を更新 |
| `edit-edges` | エッジのプロパティ（テキスト・接続先・スタイル）を更新 |
| `delete-cell-by-id` | セルを ID で削除（頂点の場合は接続エッジも自動削除） |
| `create-groups` | グループ/コンテナ（VNet, Subnet, Resource Group 等）を作成 |
| `add-cells-to-group` | セルをグループに追加 |
| `remove-cell-from-group` | セルをグループから除外 |

### 図の出力・管理

| ツール | 用途 |
|--------|------|
| `export-diagram` | draw.io XML としてエクスポート |
| `import-diagram` | draw.io XML をインポート（現在の図を置換） |
| `clear-diagram` | 全セルをクリアしリセット |
| `list-paged-model` | 全セルのページネーション表示 |
| `get-diagram-stats` | セル数・境界・レイヤー分布の統計 |

### レイヤー・ページ管理

| ツール | 用途 |
|--------|------|
| `create-layer` / `list-layers` | レイヤーの作成・一覧 |
| `create-page` / `list-pages` | マルチページ管理 |

> ⚠️ **パフォーマンス Tips**: `add-cells` は配列を受け付ける。全セルを**1回の呼び出し**で追加すること。ツールを繰り返し呼ぶのは非効率。

## Workflow

### Step 1: 構成設計書の解析

`output/phase1-azure-architecture.md` から以下を抽出する:

- 全 Azure リソースとその種類（VM, Storage, VNet, Key Vault 等）
- リソース間の接続・依存関係
- ネットワーク構成（VNet, Subnet, NSG, Private Endpoint）
- データフロー（入力 → 処理 → 出力）

### Step 2: Azure アイコンの取得

`search-shapes` ツールで Azure 公式アイコンの style 文字列を取得する。

```
# 検索例（ファジー検索対応）
search-shapes(queries: ["Azure Virtual Machine", "Azure Blob Storage", "Azure Key Vault", "Azure Machine Learning", "Azure Virtual Network", "Azure AI"])
```

> ⚠️ Azure 構成図では**必ず `search-shapes` を使用**して公式アイコンを取得すること。
> 汎用の矩形で代替しない。`add-cells` の `shape_name` パラメータでもアイコン解決が可能。

### Step 3: 図面タイプの選定と生成

研究基盤で必要となる図面タイプ:

#### 3a. システム構成図（メイン）

全 Azure リソースとその関係を俯瞰する図。申請書 §4「研究基盤計画」に添付する。

構成要素:
- リソースグループ（コンテナ）
- VNet / Subnet（ネストコンテナ）
- コンピューティング（GPU VM, HPC VM, Azure ML）
- ストレージ（Blob, Managed Lustre）
- セキュリティ（Key Vault, NSG）
- AI サービス（AI Foundry, OpenAI）
- モニタリング（Log Analytics, App Insights）

#### 3b. データフロー図

研究データの流れを示す図。申請書 §3「研究計画・方法論」に添付する。

```
データ取得 → 前処理 → 学習 → 推論 → 結果保存 → 可視化
```

#### 3c. ネットワーク・セキュリティ図

VNet 内のネットワーク分離とアクセス制御を示す図。

#### 3d. CI/CD パイプライン図

Phase 5（iac-deployer）の Bicep デプロイフローを示す図。

### Step 4: 図面の構築

以下の手順で図を構築する:

1. **グループ/コンテナの作成**: `create-groups` で Resource Group → VNet → Subnet のネスト構造を作成
2. **セルの一括追加**: `add-cells` で全リソースノードとエッジを1回の呼び出しで追加
   - `shape_name` パラメータで Azure アイコンを直接指定可能
   - `temp_id` で同バッチ内のセル間参照が可能
3. **グループへの配置**: `add-cells-to-group` でセルを適切なコンテナに配置
4. **調整**: 必要に応じて `edit-cells` / `edit-edges` で位置・スタイルを調整

- Read `references/drawio-xml-guide.md` when building diagrams
- リジッドグリッドに従う: x = col × 180 + 40, y = row × 120 + 40
- コンテナ（VNet, Subnet, Resource Group）はネスト構造で表現

### Step 5: 図面の出力

`export-diagram` ツールで draw.io XML を取得し、`output/diagrams/` にファイルとして保存する。

## Deliverables

| ファイル | 内容 |
|----------|------|
| `output/diagrams/system-architecture.drawio` | システム構成図（メイン） |
| `output/diagrams/data-flow.drawio` | データフロー図 |
| `output/diagrams/network-security.drawio` | ネットワーク・セキュリティ図 |
| `output/diagrams/cicd-pipeline.drawio` | CI/CD パイプライン図 |

> 図面は draw.io Desktop または https://app.diagrams.net で開いて編集可能。

## Quality Gates

- [ ] 全 Azure リソースが構成設計書（Phase 1）と一致している
- [ ] Azure 公式アイコンが `search-shapes` で取得され使用されている
- [ ] リソース間の接続関係が正確に描画されている
- [ ] VNet / Subnet のネットワーク分離が正しく表現されている
- [ ] 図のラベルが日本語で記述されている
- [ ] draw.io XML が well-formed（構文エラーなし）
- [ ] 図面ファイルが `output/diagrams/` に保存されている

## Diagram Templates

### Azure 研究基盤 — 構築手順テンプレート

#### 1. グループ/コンテナの作成

```json
// create-groups
{
  "groups": [
    {
      "temp_id": "rg",
      "text": "rg-research-prod",
      "x": 20, "y": 20, "width": 900, "height": 600,
      "style": "rounded=1;fillColor=#F5F5F5;strokeColor=#666666;fontSize=14;fontStyle=1;"
    },
    {
      "temp_id": "vnet",
      "text": "VNet (10.0.0.0/16)",
      "x": 40, "y": 70, "width": 860, "height": 500,
      "parent_id": "rg",
      "style": "rounded=1;fillColor=#E8F5E9;strokeColor=#4CAF50;strokeWidth=2;dashed=1;"
    }
  ]
}
```

#### 2. セルの一括追加

```json
// add-cells
{
  "cells": [
    {
      "type": "vertex",
      "temp_id": "gpu-vm",
      "x": 100, "y": 140,
      "width": 60, "height": 60,
      "text": "GPU VM\nNC24ads A100",
      "shape_name": "Azure Virtual Machine"
    },
    {
      "type": "vertex",
      "temp_id": "blob",
      "x": 280, "y": 140,
      "width": 60, "height": 60,
      "text": "Blob Storage",
      "shape_name": "Azure Blob Storage"
    },
    {
      "type": "edge",
      "source_id": "gpu-vm",
      "target_id": "blob",
      "text": "データ読み書き"
    }
  ]
}
```

#### 3. グループへの配置

```json
// add-cells-to-group
{
  "group_id": "vnet",
  "cell_ids": ["gpu-vm", "blob"]
}
```

## Gotchas

- `search-shapes` は 700+ の Azure アイコンをファジー検索可能。`"Azure Virtual Machine"` のようにサービス名で検索する
- `add-cells` は配列を受け付ける — 全セルを1回の呼び出しで追加し、ツールを繰り返し呼ばない
- draw.io XML の `value` 属性に HTML タグを含める場合は `html=1` を style に追加し、`<` → `&lt;` 等のエスケープが必要
- コンテナ内のノードは `add-cells-to-group` でグループに追加する
- draw.io Desktop がない環境では https://app.diagrams.net で `.drawio` ファイルを開ける
- PNG/SVG/PDF 変換が必要な場合は jgraph の `skill-cli` を使用: https://github.com/jgraph/drawio-mcp/blob/main/skill-cli/README.md

## Security Guardrails

- 図面に実際の IP アドレス・サブスクリプション ID・シークレットを含めない。プレースホルダーを使用する
- 機密性の高い研究データのパスは汎化して表記する

## Validation Loop

1. draw.io XML を生成する
2. Check:
   - XML が well-formed（パース可能）か
   - 全リソースが Phase 1 構成設計書に含まれるか
   - Azure アイコンが正しく使用されているか
   - コンテナのネスト構造が正しいか
3. If any check fails:
   - XML を修正し再生成
   - `search_shapes` で正しい shape を再取得
   - 再検証する
4. 全ゲートをパスした後のみ成果物を最終化する
