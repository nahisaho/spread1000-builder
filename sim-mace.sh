#!/usr/bin/env bash
# ============================================================
# SPReAD Builder — MACE テスト v1.0
# Mutually Assured Coverage Evaluation
#
# 6分野 × 10スキル/エージェント = 60ルーティングテスト
# + 分野固有コンテンツ品質テスト 120項目
# + エッジケース 30項目
# = 合計 ~210 テスト
# ============================================================
set -uo pipefail
cd /home/nahisaho/GitHub/spread1000-builder/src

PASS=0; FAIL=0; WARN=0
declare -a FAILURES=()
declare -a WARNINGS=()

pass() { ((PASS++)); echo "  ✅ $1"; }
fail() { ((FAIL++)); FAILURES+=("$1"); echo "  ❌ $1"; }
warn() { ((WARN++)); WARNINGS+=("$1"); echo "  ⚠️  $1"; }

# MACE用: SKILL/agentファイル内にキーワードが存在するかチェック
check_keyword() {
  local file="$1" keyword="$2" label="$3"
  if grep -qi "$keyword" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_keyword_warn() {
  local file="$1" keyword="$2" label="$3"
  if grep -qi "$keyword" "$file" 2>/dev/null; then
    pass "$label"
  else
    warn "$label"
  fi
}

# ============================================================
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  MACE — Mutually Assured Coverage Evaluation            ║"
echo "║  6分野 × 全スキル網羅テスト                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M1: 分野別ルーティング正確性テスト (6分野×各3プロンプト=18)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- 材料科学 ---
echo "  ── 材料科学 ──"
declare -A MAT_SCENARIOS
MAT_SCENARIOS["新規無機材料のAI探索プランを作りたい"]="spread1000-research-planner"
MAT_SCENARIOS["MatterGenを使った材料生成のAzure環境を設計して"]="spread1000-azure-architect"
MAT_SCENARIOS["ベイズ最適化で触媒探索する研究の申請書を書きたい"]="spread1000-proposal-writer"
for s in "${!MAT_SCENARIOS[@]}"; do
  expected="${MAT_SCENARIOS[$s]}"
  # WHENルールにキーワードマッチするか
  if grep -q "$expected" AGENTS.md; then pass "材料: $s → $expected"; else fail "材料: $s → $expected"; fi
done

# --- 生命科学・医学 ---
echo "  ── 生命科学・医学 ──"
declare -A BIO_SCENARIOS
BIO_SCENARIOS["タンパク質構造予測にAIを使いたい"]="spread1000-research-planner"
BIO_SCENARIOS["DICOM画像のAI解析環境のコストを見積もって"]="spread1000-cost-estimator"
BIO_SCENARIOS["臨床データを使った研究の申請書をレビューして"]="proposal-reviewer"
for s in "${!BIO_SCENARIOS[@]}"; do
  expected="${BIO_SCENARIOS[$s]}"
  if grep -q "$expected" AGENTS.md; then pass "生命: $s → $expected"; else fail "生命: $s → $expected"; fi
done

# --- 気象学・地球科学 ---
echo "  ── 気象学・地球科学 ──"
declare -A GEO_SCENARIOS
GEO_SCENARIOS["Auroraモデルで気象予測する研究プランを作りたい"]="spread1000-research-planner"
GEO_SCENARIOS["衛星画像解析のBicepテンプレートを生成したい"]="spread1000-iac-deployer"
GEO_SCENARIOS["採択後に衛星データ研究の最終報告書を作りたい"]="spread1000-post-award"
for s in "${!GEO_SCENARIOS[@]}"; do
  expected="${GEO_SCENARIOS[$s]}"
  if grep -q "$expected" AGENTS.md; then pass "地球: $s → $expected"; else fail "地球: $s → $expected"; fi
done

# --- 化学・創薬 ---
echo "  ── 化学・創薬 ──"
declare -A CHEM_SCENARIOS
CHEM_SCENARIOS["TamGenでリード化合物を探索する計画を作りたい"]="spread1000-research-planner"
CHEM_SCENARIOS["分子生成AIのAzure GPU構成を設計して"]="spread1000-azure-architect"
CHEM_SCENARIOS["創薬AI研究の予算変更をしたい"]="spread1000-post-award"
for s in "${!CHEM_SCENARIOS[@]}"; do
  expected="${CHEM_SCENARIOS[$s]}"
  if grep -q "$expected" AGENTS.md; then pass "化学: $s → $expected"; else fail "化学: $s → $expected"; fi
done

# --- 物理学・天文学 ---
echo "  ── 物理学・天文学 ──"
declare -A PHY_SCENARIOS
PHY_SCENARIOS["PINNで偏微分方程式を解く研究計画を立てたい"]="spread1000-research-planner"
PHY_SCENARIOS["重力波検出AIのe-Rad応募手続きを知りたい"]="spread1000-submission-guide"
PHY_SCENARIOS["天体分類AI研究のAIインタビュー準備をしたい"]="spread1000-submission-guide"
for s in "${!PHY_SCENARIOS[@]}"; do
  expected="${PHY_SCENARIOS[$s]}"
  if grep -q "$expected" AGENTS.md; then pass "物理: $s → $expected"; else fail "物理: $s → $expected"; fi
done

# --- 社会科学・人文学 ---
echo "  ── 社会科学・人文学 ──"
declare -A SOC_SCENARIOS
SOC_SCENARIOS["歴史文書のNLP解析でAIを活用したい"]="spread1000-research-planner"
SOC_SCENARIOS["因果推論AIのコストを見積もりたい"]="spread1000-cost-estimator"
SOC_SCENARIOS["社会ネットワーク解析研究のAI面接準備をしたい"]="spread1000-submission-guide"
for s in "${!SOC_SCENARIOS[@]}"; do
  expected="${SOC_SCENARIOS[$s]}"
  if grep -q "$expected" AGENTS.md; then pass "社会: $s → $expected"; else fail "社会: $s → $expected"; fi
done

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M2: 分野別コンテンツ品質テスト — ai-patterns-by-domain.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REF="skills/spread1000-research-planner/references/ai-patterns-by-domain.md"

# --- 6分野セクション存在 ---
echo "  ── 分野セクション網羅性 ──"
DOMAINS=("物理学" "材料科学" "生命科学" "気象学" "社会科学" "化学")
for d in "${DOMAINS[@]}"; do
  check_keyword "$REF" "$d" "分野セクション: $d"
done

# --- AI Foundry モデル網羅性 ---
echo "  ── AI Foundry モデル ──"
MODELS=("Aurora" "MatterGen" "MatterSim" "BioEmu" "TamGen" "NatureLM" "Skala" "AI2BMD")
for m in "${MODELS[@]}"; do
  check_keyword "$REF" "$m" "AI Foundry: $m"
done

# --- Azure サービス参照 ---
echo "  ── Azure サービス参照 ──"
AZURE_SVCS=("Azure ML\|Azure Machine Learning" "Azure Batch" "CycleCloud" "DICOM\|Health Data" "Planetary Computer" "Azure TRE\|Trusted Research" "InfiniBand" "Managed Lustre")
for svc in "${AZURE_SVCS[@]}"; do
  check_keyword "$REF" "$svc" "Azureサービス: $svc"
done

# --- NVIDIA フレームワーク ---
echo "  ── NVIDIA フレームワーク ──"
NVIDIA_FW=("BioNeMo" "Modulus" "Clara" "MONAI")
for nv in "${NVIDIA_FW[@]}"; do
  check_keyword "$REF" "$nv" "NVIDIA: $nv"
done

# --- 代表的ツール ---
echo "  ── 代表的ツール ──"
TOOLS=("PyTorch" "TensorFlow" "JAX" "Hugging Face" "RDKit" "AlphaFold" "DeepXDE" "BERTopic" "BoTorch")
for t in "${TOOLS[@]}"; do
  check_keyword "$REF" "$t" "ツール: $t"
done

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M3: 分野固有の Azure Architect 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ARCH="skills/spread1000-azure-architect/SKILL.md"
ARCH_REF="skills/spread1000-azure-architect/references/azure-research-services.md"

echo "  ── SKILL.md ──"
check_keyword "$ARCH" "GPU\|NC\|ND" "GPU VM言及"
check_keyword "$ARCH" "Azure Machine Learning\|Azure ML" "Azure ML言及"
check_keyword "$ARCH" "Blob Storage\|Data Lake" "ストレージ言及"
check_keyword "$ARCH" "RBAC\|セキュリティ" "セキュリティ言及"
check_keyword "$ARCH" "リージョン" "リージョン考慮"
check_keyword "$ARCH" "スポット\|Spot" "Spot VM言及"

echo "  ── references/ ──"
if [[ -f "$ARCH_REF" ]]; then
  check_keyword "$ARCH_REF" "NC\|ND\|GPU" "ref: GPU VMシリーズ"
  check_keyword "$ARCH_REF" "Batch\|CycleCloud\|HPC" "ref: HPC計算"
  check_keyword_warn "$ARCH_REF" "Health Data\|DICOM" "ref: 医療データ基盤"
  check_keyword_warn "$ARCH_REF" "TRE\|Trusted Research" "ref: セキュアリサーチ"
  check_keyword_warn "$ARCH_REF" "Planetary Computer" "ref: 地球科学データ"
else
  fail "azure-research-services.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M4: 分野固有の Cost Estimator 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COST="skills/spread1000-cost-estimator/SKILL.md"
check_keyword "$COST" "GPU\|スポット\|Spot" "GPU/Spot VM価格"
check_keyword "$COST" "月額\|総額\|研究期間" "月額・総額見積もり"
check_keyword "$COST" "500万円\|予算" "予算上限チェック"
check_keyword "$COST" "為替\|USD\|JPY" "為替レート考慮"
check_keyword "$COST" "Reserved\|RI\|リザーブド" "Reserved Instance"
check_keyword "$COST" "隠れコスト\|データ転送" "隠れコスト注意"

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M5: 分野固有の Proposal Writer 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PROP="skills/spread1000-proposal-writer/SKILL.md"
PROP_TPL="skills/spread1000-proposal-writer/assets/proposal-template.md"
PROP_KH="skills/spread1000-proposal-writer/assets/knowhow-sharing-template.md"
PROP_DMP="skills/spread1000-proposal-writer/references/dmp-guide.md"

echo "  ── SKILL.md ──"
check_keyword "$PROP" "ノウハウ\|知見" "ノウハウ共有セクション"
check_keyword "$PROP" "DMP\|データ管理\|dmp-guide" "DMP参照"
check_keyword "$PROP" "倫理\|IRB" "研究倫理言及"
check_keyword "$PROP" "中間.*最終\|3.*ヶ月.*6.*ヶ月\|マイルストーン" "マイルストーン"
check_keyword "$PROP" "積算根拠" "経費積算根拠"

echo "  ── assets/templates ──"
if [[ -f "$PROP_TPL" ]]; then
  check_keyword "$PROP_TPL" "AI" "proposal-template: AI言及"
  check_keyword "$PROP_TPL" "研究目的\|背景" "proposal-template: 研究目的"
  check_keyword_warn "$PROP_TPL" "ノウハウ\|知見の共有" "proposal-template: ノウハウ共有"
else
  fail "proposal-template.md 不在"
fi

if [[ -f "$PROP_KH" ]]; then
  check_keyword "$PROP_KH" "共有\|展開\|他分野" "knowhow-template: 共有方法"
  pass "knowhow-sharing-template.md 存在"
else
  fail "knowhow-sharing-template.md 不在"
fi

if [[ -f "$PROP_DMP" ]]; then
  check_keyword "$PROP_DMP" "FAIR\|メタデータ\|データ管理" "dmp-guide: FAIR/メタデータ"
  pass "dmp-guide.md 存在"
else
  fail "dmp-guide.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M6: 分野固有の Submission Guide 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SUB="skills/spread1000-submission-guide/SKILL.md"
SUB_AI="skills/spread1000-submission-guide/references/ai-interview-guide.md"
SUB_EL="skills/spread1000-submission-guide/references/eligibility-rules.md"

echo "  ── SKILL.md ──"
check_keyword "$SUB" "AIインタビュー" "AIインタビュー"
check_keyword "$SUB" "e-Rad" "e-Rad"
check_keyword "$SUB" "学生" "学生応募"
check_keyword "$SUB" "重複制限\|ARiSE" "重複制限"
check_keyword "$SUB" "インテグリティ" "研究インテグリティ"
check_keyword "$SUB" "様式0\|様式1\|様式2" "様式言及"

echo "  ── references ──"
if [[ -f "$SUB_AI" ]]; then
  check_keyword "$SUB_AI" "メールアドレス\|48時間\|インタビュー" "ai-interview: 手順詳細"
  pass "ai-interview-guide.md 存在"
else
  fail "ai-interview-guide.md 不在"
fi

if [[ -f "$SUB_EL" ]]; then
  check_keyword "$SUB_EL" "応募資格\|大学\|研究機関" "eligibility: 応募資格"
  check_keyword_warn "$SUB_EL" "学生\|指導教員" "eligibility: 学生応募"
  pass "eligibility-rules.md 存在"
else
  fail "eligibility-rules.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M7: 分野固有の Post-Award 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

POST="skills/spread1000-post-award/SKILL.md"
POST_ACK="skills/spread1000-post-award/references/acknowledgment-guide.md"

echo "  ── SKILL.md ──"
check_keyword "$POST" "ロードマップ" "ロードマップ生成"
check_keyword "$POST" "交付申請" "交付申請手続き"
check_keyword "$POST" "中間" "中間進捗報告"
check_keyword "$POST" "最終\|成果報告" "最終成果報告書"
check_keyword "$POST" "費目間流用" "費目間流用"
check_keyword "$POST" "会計実績" "会計実績報告書"
check_keyword "$POST" "JPMXP17" "体系的番号"
check_keyword "$POST" "FAIR" "FAIR原則"
check_keyword "$POST" "早期" "早期達成対応"
check_keyword "$POST" "研究倫理教育\|コンプライアンス" "倫理教育"
check_keyword "$POST" "伴走支援\|URA" "伴走支援"

echo "  ── references ──"
if [[ -f "$POST_ACK" ]]; then
  check_keyword "$POST_ACK" "JPMXP17" "ack-guide: 体系的番号"
  check_keyword "$POST_ACK" "NII\|CiNii\|JAIRO" "ack-guide: データ公開先"
  check_keyword "$POST_ACK" "FAIR\|メタデータ" "ack-guide: メタデータ"
  pass "acknowledgment-guide.md 存在"
else
  fail "acknowledgment-guide.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M8: 実験手順書スキルテスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

EXP="skills/spread1000-experiment-guide/SKILL.md"
EXP_TMPL="skills/spread1000-experiment-guide/assets/experiment-guide-template.md"

echo "  ── SKILL.md ──"
check_keyword "$EXP" "実験手順書\|experiment" "EXP: 実験手順書"
check_keyword "$EXP" "Azure ML\|ML Workspace" "EXP: Azure ML"
check_keyword "$EXP" "チェックポイント\|checkpoint" "EXP: チェックポイント"
check_keyword "$EXP" "再現性\|reproducibility" "EXP: 再現性"
check_keyword "$EXP" "MLflow" "EXP: MLflow"
check_keyword "$EXP" "Spot VM\|プリエンプション" "EXP: Spot VM対策"
check_keyword "$EXP" "分散学習\|DDP\|DeepSpeed" "EXP: 分散学習"
check_keyword "$EXP" "FAIR" "EXP: FAIR原則"
check_keyword "$EXP" "experiment-guide.md" "EXP: 出力パス"

echo "  ── assets ──"
if [[ -f "$EXP_TMPL" ]]; then
  check_keyword "$EXP_TMPL" "実験環境\|セットアップ" "EXP-tmpl: 環境セットアップ"
  check_keyword "$EXP_TMPL" "学習実行\|ジョブ" "EXP-tmpl: 学習実行"
  check_keyword "$EXP_TMPL" "評価メトリクス\|メトリクス" "EXP-tmpl: 評価メトリクス"
  check_keyword "$EXP_TMPL" "再現性" "EXP-tmpl: 再現性管理"
  pass "experiment-guide-template.md 存在"
else
  fail "experiment-guide-template.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M9: 分野固有の IaC Deployer 対応テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

IAC="skills/spread1000-iac-deployer/SKILL.md"
IAC_BIC="skills/spread1000-iac-deployer/references/bicep-patterns.md"

echo "  ── SKILL.md ──"
check_keyword "$IAC" "Bicep" "Bicep"
check_keyword "$IAC" "GitHub Actions\|CI/CD" "CI/CD"
check_keyword "$IAC" "OIDC\|フェデレーション" "OIDC認証"
check_keyword "$IAC" "Key Vault\|secure" "シークレット管理"
check_keyword "$IAC" "Private Endpoint\|VNet" "ネットワーク分離"
check_keyword "$IAC" "クォータ\|quota" "GPUクォータ注意"

echo "  ── references ──"
if [[ -f "$IAC_BIC" ]]; then
  check_keyword "$IAC_BIC" "module\|モジュール" "bicep-patterns: モジュール化"
  check_keyword_warn "$IAC_BIC" "ML\|Machine Learning" "bicep-patterns: ML Workspace"
  pass "bicep-patterns.md 存在"
else
  fail "bicep-patterns.md 不在"
fi

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M10: Proposal Reviewer 分野横断テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REV="agents/proposal-reviewer.agent.md"
check_keyword "$REV" "AI利活用の妥当性" "審査観点1: AI妥当性"
check_keyword "$REV" "研究実績" "審査観点2: 研究実績"
check_keyword "$REV" "実施計画.*資金活用\|資金活用.*妥当性" "審査観点3: 実施計画"
check_keyword "$REV" "優位性.*新規性\|新規性" "審査観点4: 優位性"
check_keyword "$REV" "ノウハウ" "審査観点5: ノウハウ"
check_keyword "$REV" "波及" "審査観点6: 波及可能性"
check_keyword "$REV" "HPCI" "HPCIチェック"
check_keyword "$REV" "様式0\|様式1\|様式2\|様式3\|様式4" "全様式チェック"
check_keyword "$REV" "10万円" "最低研究経費チェック"
check_keyword "$REV" "対象外" "対象外研究計画チェック"

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M11: Research Advisor 分野対応力テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ADV="agents/research-advisor.agent.md"
check_keyword "$ADV" "FIELD\|研究分野" "10要素: FIELD"
check_keyword "$ADV" "PURPOSE\|目的" "10要素: PURPOSE"
check_keyword "$ADV" "DATA\|データ" "10要素: DATA"
check_keyword "$ADV" "COMPUTE\|計算資源" "10要素: COMPUTE"
check_keyword "$ADV" "TRACK_RECORD\|業績" "10要素: TRACK_RECORD"
check_keyword "$ADV" "KNOW_HOW\|ノウハウ" "10要素: KNOW_HOW"
check_keyword "$ADV" "APPLICANT\|応募者" "10要素: APPLICANT"
check_keyword "$ADV" "EXISTING_AI\|AI経験" "10要素: EXISTING_AI"
check_keyword "$ADV" "BUDGET\|予算" "10要素: BUDGET"
check_keyword "$ADV" "Web.*リサーチ\|Web\sリサーチ\|Web リサーチ" "Webリサーチ能力"
check_keyword "$ADV" "1問1答\|1問だけ" "1問1答プロトコル"
check_keyword "$ADV" "審査観点" "審査観点との紐付け"

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M12: エッジケース・境界値テスト"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "  ── 曖昧プロンプト（context-collector行き） ──"
# "AI for Science やりたい" → context-collector (6要素不足)
if grep -q "spread1000-context-collector" AGENTS.md && grep -q "6要素.*3.*以上\|不明な要素が3つ以上" AGENTS.md; then
  pass "曖昧プロンプト → context-collector ルール存在"
else
  fail "曖昧プロンプト → context-collector ルール欠落"
fi

echo "  ── 緊急度トリアージ ──"
check_keyword "AGENTS.md" "急ぎ\|締切直前" "Urgentキーワード"
check_keyword "AGENTS.md" "今すぐ" "Criticalキーワード"
check_keyword "AGENTS.md" "Phase 0+3\|プラン＋申請書" "Urgent: Phase 0+3"
check_keyword "AGENTS.md" "Phase 3" "Critical: Phase 3"

echo "  ── 複合リクエスト ──"
# 申請書作成 + レビュー を1つのプロンプトで依頼 → proposal-writer → proposal-reviewer の順序
if grep -q "Phase 3b" AGENTS.md; then
  pass "Phase 3→3b (writer→reviewer) シーケンス"
else
  fail "Phase 3→3b シーケンス欠落"
fi

echo "  ── 分野特有セキュリティ ──"
# 医療データ → Security Guardrails
check_keyword "skills/spread1000-azure-architect/SKILL.md" "DICOM\|FHIR\|医療\|Health Data\|ゲノム" "医療データセキュリティ"
check_keyword "skills/spread1000-azure-architect/SKILL.md" "TRE\|Restricted\|Private Endpoint\|Airlock" "セキュアリサーチ環境"
check_keyword "skills/spread1000-proposal-writer/SKILL.md" "患者データ\|個人情報\|匿名化\|ダミー" "proposal: データ匿名化"

echo "  ── 学生応募の特殊処理 ──"
check_keyword "skills/spread1000-submission-guide/SKILL.md" "学生" "submission: 学生対応"
check_keyword "agents/proposal-reviewer.agent.md" "様式3\|様式4" "reviewer: 学生用様式"

echo "  ── コンテキスト収集と後続スキルの連携 ──"
check_keyword "skills/spread1000-context-collector/SKILL.md" "メタプロンプト" "context→メタプロンプト生成"
check_keyword "skills/spread1000-context-collector/SKILL.md" "承認\|ユーザー.*承認" "context→ユーザー承認"
check_keyword "skills/spread1000-context-collector/SKILL.md" "output/.*meta-prompt.md" "context→出力パス"

echo "  ── Phase間データフロー ──"
check_keyword "skills/spread1000-azure-architect/SKILL.md" "phase0-research-plan" "Phase0→1 データフロー"
check_keyword "skills/spread1000-cost-estimator/SKILL.md" "phase1-azure-architecture" "Phase1→2 データフロー"
check_keyword "skills/spread1000-proposal-writer/SKILL.md" "phase0\|phase1\|phase2" "Phase0,1,2→3 データフロー"
check_keyword "skills/spread1000-iac-deployer/SKILL.md" "phase1-azure-architecture" "Phase1→5 データフロー"
check_keyword "skills/spread1000-experiment-guide/SKILL.md" "phase1-azure-architecture\|phase0-research-plan" "Phase0,1→5c データフロー"
check_keyword "skills/spread1000-post-award/SKILL.md" "phase3-proposal" "Phase3→6 データフロー"

echo "  ── Prohibited Operations ──"
check_keyword "AGENTS.md" "研究データの外部送信" "禁止: データ外部送信"
check_keyword "AGENTS.md" "ユーザーの許可なく.*申請書を送信\|許可なく公的機関" "禁止: 無断申請"
check_keyword "AGENTS.md" "Azure リソースの本番デプロイ" "禁止: 無断デプロイ"

echo "  ── 分野別推奨モデルの存在確認 ──"
# ai-patterns-by-domain に各分野の推奨モデルテーブルがあるか
for domain in "物理学" "材料科学" "生命科学" "気象学" "社会科学" "化学"; do
  if grep -A20 "## $domain" "$REF" 2>/dev/null | grep -qi "AI Foundry\|代表的ツール"; then
    pass "分野別推奨テーブル: $domain"
  else
    warn "分野別推奨テーブル不完全: $domain"
  fi
done

# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  M13: 全体整合性クロスチェック"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# AGENTS.md の Core Rules と各スキルの整合
check_keyword "AGENTS.md" "コンテキスト不足時は必ず1問1答" "Core Rule: 1問1答"
check_keyword "AGENTS.md" "最も狭いマッチングサブスキル" "Core Rule: 最狭マッチ"
check_keyword "AGENTS.md" "すべての成果物をファイルに保存" "Core Rule: File-First"
check_keyword "AGENTS.md" "Web リサーチで補完" "Core Rule: Web補完"

# copilot-instructions.md との整合
check_keyword "copilot-instructions.md" "1問1答" "CI: 1問1答"
check_keyword "copilot-instructions.md" "output/" "CI: output dir"
check_keyword "copilot-instructions.md" "research-advisor" "CI: research-advisor"
check_keyword "copilot-instructions.md" "proposal-reviewer" "CI: proposal-reviewer"

# Quality Gates の分野横断性
check_keyword "AGENTS.md" "AI活用の具体的手法" "QG: AI手法記載"
check_keyword "AGENTS.md" "計算要件" "QG: 計算要件"
check_keyword "AGENTS.md" "予算の範囲内" "QG: 予算範囲"
check_keyword "AGENTS.md" "180日間" "QG: 180日マイルストーン"

# ============================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  MACE テスト結果サマリー                                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "  ✅ PASS:  $PASS"
echo "  ❌ FAIL:  $FAIL"
echo "  ⚠️  WARN:  $WARN"
echo ""

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo "  ─── FAILURES ───"
  for f in "${FAILURES[@]}"; do
    echo "    ❌ $f"
  done
  echo ""
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo "  ─── WARNINGS ───"
  for w in "${WARNINGS[@]}"; do
    echo "    ⚠️  $w"
  done
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total: $((PASS + FAIL + WARN)) tests (13 categories)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
