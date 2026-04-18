---
name: spread1000-iac-deployer
description: |
  Azure 構成設計書に基づいて Bicep テンプレートと GitHub Actions CI/CD パイプラインを
  生成する。研究基盤のインフラをコードとして管理し、再現可能なデプロイを実現する。
  Use when Bicepテンプレートを生成したい、CI/CDを構築したい、IaCを整備したい場合。
---

# IaC Deployer

Azure 構成設計書から Bicep テンプレートと CI/CD パイプラインを生成し、研究基盤のインフラをコード化する。

## Use This Skill When

- Azure 構成設計が完了しインフラをコード化する段階
- Bicep テンプレートを生成して Azure リソースをデプロイしたい
- GitHub Actions で CI/CD パイプラインを構築したい

## Required Inputs

- `output/phase1-azure-architecture.md`（Azure 構成設計書）
- Azure サブスクリプション ID（デプロイ時）
- デプロイ先リージョン

## Workflow

1. **構成設計書の解析**: デプロイ対象のリソース一覧を抽出する
2. **Bicep テンプレート生成**:
   - Read `references/bicep-patterns.md` when generating templates
   - `main.bicep`: エントリーポイント
   - `modules/`: リソースタイプ別のモジュール
   - `parameters/`: 環境別パラメータファイル
3. **CI/CD パイプライン生成**:
   - Read `references/cicd-patterns.md` when generating pipelines
   - `.github/workflows/deploy.yml`: デプロイワークフロー
   - `.github/workflows/validate.yml`: Bicep 検証ワークフロー
4. **成果物出力**: `output/phase4-iac/` ディレクトリに保存
   - Reuse `assets/bicep-main-template.bicep` as starting point
5. **検証**: Bicep lint、what-if 実行の手順を提示

## Deliverables

- `output/phase4-iac/main.bicep`: メイン Bicep テンプレート
- `output/phase4-iac/modules/`: リソース別 Bicep モジュール
- `output/phase4-iac/parameters/`: 環境別パラメータ
- `output/phase4-iac/.github/workflows/deploy.yml`: デプロイパイプライン
- `output/phase4-iac/.github/workflows/validate.yml`: 検証パイプライン

## Quality Gates

- [ ] Bicep テンプレートが lint エラーなくパスする
- [ ] 全リソースがモジュール化されている（1モジュール = 1リソースタイプ）
- [ ] パラメータファイルで環境ごとの差異を吸収している
- [ ] CI/CD パイプラインに what-if ステップが含まれている
- [ ] シークレット（接続文字列・キー）がハードコードされていない
- [ ] タグ付けポリシー（Project、Owner、Environment）が適用されている

## Gotchas

- Bicep のモジュール参照パスはデプロイ実行ディレクトリからの相対パスになる。ディレクトリ構造を意識すること
- Azure Machine Learning ワークスペースは依存リソース（Storage、Key Vault、Application Insights、Container Registry）が多い。デプロイ順序に注意すること
- GitHub Actions のワークフローで Azure にデプロイする場合、OpenID Connect (OIDC) によるフェデレーション資格情報を推奨。シークレットベースの認証は避けること
- GPU VM（NC/ND シリーズ）のクォータ制限に注意。デプロイ前にクォータ確認ステップを組み込むこと

## Security Guardrails

- Bicep テンプレートにシークレットやトークンを絶対に埋め込まない。Key Vault 参照または `@secure()` デコレータを使用すること
- GitHub Actions の Azure 認証は OIDC フェデレーション必須。`AZURE_CREDENTIALS` シークレットは生成しないこと
- リソースデプロイは最小権限の原則。マネージド ID + RBAC ロール割り当てをデフォルトとする
- ネットワーク分離: VNet + Private Endpoint をデフォルトで設計。パブリックエンドポイントは明示的な根拠がない限り使用しないこと

## Validation Loop

1. Bicep テンプレートを生成する
2. Check:
   - `az bicep build` でコンパイルエラーがないか
   - `az deployment group what-if` で期待通りのリソースが作成されるか
   - CI/CD パイプラインの YAML 構文が正しいか
3. If any check fails:
   - エラーを修正し再コンパイル
   - 依存関係の順序を見直す
   - 再検証する
4. 全ゲートをパスした後のみ成果物を最終化する
