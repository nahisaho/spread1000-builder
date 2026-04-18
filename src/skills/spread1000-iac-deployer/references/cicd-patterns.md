# CI/CD パイプラインパターンリファレンス

GitHub Actions による Azure デプロイ CI/CD パイプラインのパターン集。

## 認証方式

### 推奨: OpenID Connect (OIDC) フェデレーション

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**非推奨**: `AZURE_CREDENTIALS` シークレットによるサービスプリンシパル認証

## デプロイワークフロー

```yaml
name: Deploy Azure Infrastructure

on:
  push:
    branches: [main]
    paths: ['infra/**']
  pull_request:
    branches: [main]
    paths: ['infra/**']
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Bicep Lint
        run: az bicep build --file infra/main.bicep
      - name: What-If
        run: |
          az deployment group what-if \
            --resource-group ${{ vars.RESOURCE_GROUP }} \
            --template-file infra/main.bicep \
            --parameters infra/parameters/${{ inputs.environment || 'dev' }}.bicepparam

  deploy:
    needs: validate
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment || 'dev' }}
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Deploy
        run: |
          az deployment group create \
            --resource-group ${{ vars.RESOURCE_GROUP }} \
            --template-file infra/main.bicep \
            --parameters infra/parameters/${{ inputs.environment || 'dev' }}.bicepparam
```

## 検証ワークフロー

```yaml
name: Validate Bicep

on:
  pull_request:
    paths: ['infra/**']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Bicep Lint
        run: az bicep build --file infra/main.bicep
      - name: Bicep Validate
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - run: |
          az deployment group validate \
            --resource-group ${{ vars.RESOURCE_GROUP }} \
            --template-file infra/main.bicep \
            --parameters infra/parameters/dev.bicepparam
```

## 必要な GitHub Secrets

| シークレット名 | 説明 |
|-------------|------|
| AZURE_CLIENT_ID | サービスプリンシパルのクライアント ID |
| AZURE_TENANT_ID | Azure AD テナント ID |
| AZURE_SUBSCRIPTION_ID | Azure サブスクリプション ID |

## 必要な GitHub Variables

| 変数名 | 説明 |
|--------|------|
| RESOURCE_GROUP | デプロイ先のリソースグループ名 |
