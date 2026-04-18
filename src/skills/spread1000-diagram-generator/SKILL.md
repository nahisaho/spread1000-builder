---
name: spread1000-diagram-generator
description: |
  draw.io MCP Server を使用して、Azure 研究基盤のシステム構成図・データフロー図・
  ネットワーク図を draw.io 形式で生成する。Azure 公式アイコンを search_shapes で取得し、
  Phase 1（azure-architect）の設計書から視覚的なアーキテクチャ図を自動作成する。
  Use when システム構成図を作りたい、アーキテクチャ図を draw.io で作成したい、
  Azure 構成の図面を生成したい、データフロー図が欲しい場合。
---

# Diagram Generator

draw.io MCP Server（`@drawio/mcp`）を活用して、Azure 研究基盤のプロフェッショナルなシステム構成図を生成する。

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

3つの方法のいずれかで draw.io MCP を利用可能にする:

#### 方法 1: MCP App Server（推奨・インストール不要）

リモート MCP サーバーとして `https://mcp.draw.io/mcp` を追加する。
図はチャット内にインラインで表示される。

#### 方法 2: MCP Tool Server（ローカル）

```bash
npx @drawio/mcp
```

VS Code の `.vscode/mcp.json` に追加:

```json
{
  "servers": {
    "drawio": {
      "command": "npx",
      "args": ["@drawio/mcp"]
    }
  }
}
```

#### 方法 3: Skill + CLI（draw.io Desktop 必要）

draw.io Desktop がインストールされている環境で `.drawio` ファイルを直接生成。
PNG/SVG/PDF へのエクスポートも可能。

## MCP Tools

| ツール | 用途 |
|--------|------|
| `search_shapes` | Azure/AWS/GCP/Kubernetes 等の公式アイコン 10,000+ 件を検索し、正確な style 文字列を取得 |
| `create_diagram` | draw.io XML からインタラクティブな図を生成 |

## Workflow

### Step 1: 構成設計書の解析

`output/phase1-azure-architecture.md` から以下を抽出する:

- 全 Azure リソースとその種類（VM, Storage, VNet, Key Vault 等）
- リソース間の接続・依存関係
- ネットワーク構成（VNet, Subnet, NSG, Private Endpoint）
- データフロー（入力 → 処理 → 出力）

### Step 2: Azure アイコンの取得

`search_shapes` ツールで Azure 公式アイコンの style 文字列を取得する。

```
# 検索例
search_shapes("Azure Virtual Machine")
search_shapes("Azure Blob Storage")
search_shapes("Azure Key Vault")
search_shapes("Azure Machine Learning")
search_shapes("Azure Virtual Network")
search_shapes("Azure AI")
```

> ⚠️ Azure 構成図では**必ず `search_shapes` を使用**して公式アイコンを取得すること。
> 汎用の矩形で代替しない。

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

### Step 4: draw.io XML の生成

- Read `references/drawio-xml-guide.md` when generating XML
- 日本語のラベルを使用する（ユーザーの言語に合わせる）
- Azure アイコンは `search_shapes` で取得した正確な style を使用
- リジッドグリッドに従う: x = col × 180 + 40, y = row × 120 + 40
- コンテナ（VNet, Subnet, Resource Group）はネスト構造で表現

### Step 5: 図面の出力

`create_diagram` ツールで図を生成し、XML を `output/` に保存する。

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
- [ ] Azure 公式アイコンが `search_shapes` で取得され使用されている
- [ ] リソース間の接続関係が正確に描画されている
- [ ] VNet / Subnet のネットワーク分離が正しく表現されている
- [ ] 図のラベルが日本語で記述されている
- [ ] draw.io XML が well-formed（構文エラーなし）
- [ ] 図面ファイルが `output/diagrams/` に保存されている

## Diagram Templates

### Azure 研究基盤 — 基本構成テンプレート

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    
    <!-- Resource Group コンテナ -->
    <mxCell id="rg" value="rg-research-prod" 
      style="rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;fillColor=#F5F5F5;strokeColor=#666666;fontSize=14;fontStyle=1;verticalAlign=top;spacingTop=10;" 
      vertex="1" parent="1">
      <mxGeometry x="20" y="20" width="900" height="600" as="geometry"/>
    </mxCell>
    
    <!-- VNet コンテナ -->
    <mxCell id="vnet" value="VNet (10.0.0.0/16)" 
      style="rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;fillColor=#E8F5E9;strokeColor=#4CAF50;strokeWidth=2;dashed=1;verticalAlign=top;spacingTop=10;" 
      vertex="1" parent="rg">
      <mxGeometry x="20" y="50" width="860" height="500" as="geometry"/>
    </mxCell>
    
    <!-- ノードは search_shapes で取得した style に置換 -->
  </root>
</mxGraphModel>
```

## Gotchas

- `search_shapes` は 10,000+ の形状を検索可能。Azure アイコンは `"Azure Virtual Machine"` のようにサービス名で検索する
- draw.io XML の `value` 属性に HTML タグを含める場合は `html=1` を style に追加し、`<` → `&lt;` 等のエスケープが必要
- エッジ（矢印）に `<Array as="points">` ウェイポイントは追加しない — draw.io のルーターが自動処理する
- `exitX/exitY/entryX/entryY` の接続点オーバーライドは原則使わない
- コンテナ内のノードは `parent` 属性でコンテナ ID を指定する
- draw.io Desktop がない環境では https://app.diagrams.net で `.drawio` ファイルを開ける

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
