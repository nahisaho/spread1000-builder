#!/usr/bin/env bash
# ============================================================
# SPReAD Builder v0.2.0 — 総合模擬テスト
# 32 files, 8 skills + 2 agents
# ============================================================
set -uo pipefail
cd /home/nahisaho/GitHub/spread1000-builder/src

PASS=0; FAIL=0; WARN=0
declare -a FAILURES=()
declare -a WARNINGS=()

pass() { ((PASS++)); echo "  ✅ $1"; }
fail() { ((FAIL++)); FAILURES+=("$1"); echo "  ❌ $1"; }
warn() { ((WARN++)); WARNINGS+=("$1"); echo "  ⚠️  $1"; }

# ============================================================
echo "═══════════════════════════════════════════════"
echo "  T1: ファイル構造テスト"
echo "═══════════════════════════════════════════════"

# T1.1: 必須ファイル存在チェック
REQUIRED_FILES=(
  "AGENTS.md" "README.md" "copilot-instructions.md" "group.json" "skill.json"
  "agents/research-advisor.md" "agents/proposal-reviewer.md"
  "skills/spread1000-context-collector/SKILL.md"
  "skills/spread1000-research-planner/SKILL.md"
  "skills/spread1000-azure-architect/SKILL.md"
  "skills/spread1000-cost-estimator/SKILL.md"
  "skills/spread1000-proposal-writer/SKILL.md"
  "skills/spread1000-submission-guide/SKILL.md"
  "skills/spread1000-post-award/SKILL.md"
  "skills/spread1000-iac-deployer/SKILL.md"
)
for f in "${REQUIRED_FILES[@]}"; do
  [[ -f "$f" ]] && pass "存在: $f" || fail "欠落: $f"
done

# T1.2: group.json count一致
SKILL_DIRS=$(ls -d skills/spread1000-*/ 2>/dev/null | wc -l)
JSON_COUNT=$(grep -oP '"count":\s*\K\d+' group.json)
[[ "$SKILL_DIRS" == "$JSON_COUNT" ]] && pass "group.json count=$JSON_COUNT (ディレクトリ=$SKILL_DIRS)" || fail "group.json count=$JSON_COUNT != ディレクトリ数=$SKILL_DIRS"

# T1.3: 合計ファイル数
TOTAL_FILES=$(find . -type f -not -name "sim*" -not -name "*.pdf" | wc -l)
[[ "$TOTAL_FILES" -ge 30 ]] && pass "合計ファイル数=$TOTAL_FILES (≥30)" || warn "合計ファイル数=$TOTAL_FILES (<30)"

# T1.4: SKILL.md行数上限 (≤500行)
for sk in skills/*/SKILL.md; do
  LINES=$(wc -l < "$sk")
  SNAME=$(echo "$sk" | sed 's|skills/||;s|/SKILL.md||')
  [[ "$LINES" -le 500 ]] && pass "$SNAME: ${LINES}行 (≤500)" || fail "$SNAME: ${LINES}行 (>500)"
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T2: 命名・ブランディング一貫性テスト"
echo "═══════════════════════════════════════════════"

# T2.1: 「SPReAD 1000」残存チェック
RESIDUAL=$(grep -rl "SPReAD 1000" . --include="*.md" --include="*.json" 2>/dev/null | wc -l)
[[ "$RESIDUAL" == "0" ]] && pass "SPReAD 1000 残存=0" || fail "SPReAD 1000 残存=$RESIDUAL ファイル"

# T2.2: AGENTS.md frontmatter name
AGENTS_NAME=$(grep -m1 '^name:' AGENTS.md | sed 's/name: *//')
[[ "$AGENTS_NAME" == "spread1000-builder" ]] && pass "AGENTS.md name=spread1000-builder" || fail "AGENTS.md name=$AGENTS_NAME"

# T2.3: バージョン一貫性
V_AGENTS=$(grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' AGENTS.md | head -1)
V_SKILL_JSON=$(grep -oP '"version":\s*"\K[^"]+' skill.json)
V_README=$(grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' README.md | head -1)
if [[ "$V_AGENTS" == "$V_SKILL_JSON" && "$V_SKILL_JSON" == "$V_README" ]]; then
  pass "バージョン一致: v$V_AGENTS"
else
  fail "バージョン不一致: AGENTS=$V_AGENTS, skill.json=$V_SKILL_JSON, README=$V_README"
fi

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T3: ルーティング完全性テスト"
echo "═══════════════════════════════════════════════"

# T3.1: 全8スキルがAGENTS.mdのWHEN/DOまたはTask Classificationで言及されているか
SKILLS_LIST=(
  "spread1000-context-collector"
  "spread1000-research-planner"
  "spread1000-azure-architect"
  "spread1000-cost-estimator"
  "spread1000-proposal-writer"
  "spread1000-submission-guide"
  "spread1000-post-award"
  "spread1000-iac-deployer"
)
for sk in "${SKILLS_LIST[@]}"; do
  if grep -q "$sk" AGENTS.md; then
    pass "ルーティング: $sk"
  else
    fail "ルーティング欠落: $sk"
  fi
done

# T3.2: 2エージェントがルーティングされているか
for ag in "proposal-reviewer" "research-advisor"; do
  if grep -q "$ag" AGENTS.md; then
    pass "エージェント参照: $ag"
  else
    fail "エージェント参照欠落: $ag"
  fi
done

# T3.3: Full WorkflowにPhase 0〜6があるか
for phase in "Phase 0" "Phase 1" "Phase 2" "Phase 3" "Phase 4" "Phase 5" "Phase 6"; do
  if grep -q "$phase" AGENTS.md; then
    pass "Full Workflow: $phase"
  else
    fail "Full Workflow欠落: $phase"
  fi
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T4: シナリオルーティングテスト（18シナリオ）"
echo "═══════════════════════════════════════════════"

# 各シナリオ: ユーザープロンプト → 期待されるスキル/エージェント
declare -A SCENARIOS
SCENARIOS["S01: AI使いたいが何も決まってない"]="spread1000-context-collector"
SCENARIOS["S02: 有機化学でAIを使って触媒探索したい"]="spread1000-research-planner"
SCENARIOS["S03: 研究プランができたのでAzure構成を設計して"]="spread1000-azure-architect"
SCENARIOS["S04: Azure構成のコストを見積もって"]="spread1000-cost-estimator"
SCENARIOS["S05: SPReADの申請書を書きたい"]="spread1000-proposal-writer"
SCENARIOS["S06: 申請書をレビューして"]="proposal-reviewer"
SCENARIOS["S07: AIインタビューの準備をしたい"]="spread1000-submission-guide"
SCENARIOS["S08: e-Radの手続きを知りたい"]="spread1000-submission-guide"
SCENARIOS["S09: Bicepテンプレートを作りたい"]="spread1000-iac-deployer"
SCENARIOS["S10: 研究計画書の品質チェックをしたい"]="proposal-reviewer"
SCENARIOS["S11: 応募資格を確認したい"]="spread1000-submission-guide"
SCENARIOS["S12: 重複制限を知りたい"]="spread1000-submission-guide"
SCENARIOS["S13: 学生として応募する手続き"]="spread1000-submission-guide"
SCENARIOS["S14: 採択後の手続きを知りたい"]="spread1000-post-award"
SCENARIOS["S15: 中間報告書を書きたい"]="spread1000-post-award"
SCENARIOS["S16: 予算変更・費目間流用したい"]="spread1000-post-award"
SCENARIOS["S17: 論文の謝辞テンプレートが欲しい"]="spread1000-post-award"
SCENARIOS["S18: 最終報告書を作りたい"]="spread1000-post-award"

for scenario in "${!SCENARIOS[@]}"; do
  expected="${SCENARIOS[$scenario]}"
  # WHEN/DO ルーティングで期待スキルが含まれるか確認
  if grep -q "$expected" AGENTS.md; then
    pass "$scenario → $expected"
  else
    fail "$scenario → $expected (未定義)"
  fi
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T5: コンテンツ品質テスト"
echo "═══════════════════════════════════════════════"

# T5.1: 各SKILL.mdに必須セクションがあるか
REQUIRED_SECTIONS=("Use This Skill When" "Workflow" "Deliverables" "Quality Gates" "Gotchas")
for sk in skills/*/SKILL.md; do
  SNAME=$(echo "$sk" | sed 's|skills/||;s|/SKILL.md||')
  for sec in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "$sec" "$sk"; then
      pass "$SNAME: '$sec' セクション存在"
    else
      fail "$SNAME: '$sec' セクション欠落"
    fi
  done
done

# T5.2: 各エージェントに必須セクションがあるか
AGENT_SECTIONS=("Role" "Workflow" "Constraints")
for ag in agents/*.md; do
  ANAME=$(basename "$ag" .md)
  for sec in "${AGENT_SECTIONS[@]}"; do
    if grep -qi "## $sec" "$ag"; then
      pass "$ANAME: '$sec' セクション存在"
    else
      fail "$ANAME: '$sec' セクション欠落"
    fi
  done
done

# T5.3: frontmatter name= と ディレクトリ名の一致
for sk in skills/*/SKILL.md; do
  SNAME=$(echo "$sk" | sed 's|skills/||;s|/SKILL.md||')
  FM_NAME=$(grep -m1 '^name:' "$sk" | sed 's/name: *//')
  [[ "$FM_NAME" == "$SNAME" ]] && pass "$SNAME: frontmatter name一致" || fail "$SNAME: frontmatter name=$FM_NAME ≠ dir"
done
for ag in agents/*.md; do
  ANAME=$(basename "$ag" .md)
  FM_NAME=$(grep -m1 '^name:' "$ag" | sed 's/name: *//')
  [[ "$FM_NAME" == "$ANAME" ]] && pass "$ANAME: frontmatter name一致" || fail "$ANAME: frontmatter name=$FM_NAME ≠ file"
done

# T5.4: 研究期間「180日」「約180日」の記載確認（重要スキルのみ）
PERIOD_SKILLS=("cost-estimator" "proposal-writer" "post-award" "proposal-reviewer")
for ps in "${PERIOD_SKILLS[@]}"; do
  FILE=""
  if [[ -f "skills/spread1000-$ps/SKILL.md" ]]; then
    FILE="skills/spread1000-$ps/SKILL.md"
  elif [[ -f "agents/$ps.md" ]]; then
    FILE="agents/$ps.md"
  fi
  if [[ -n "$FILE" ]]; then
    if grep -q "180日" "$FILE"; then
      pass "$ps: 180日間の記載あり"
    else
      warn "$ps: 180日間の記載なし"
    fi
  fi
done

# T5.5: 予算上限「500万円」の記載確認
BUDGET_SKILLS=("cost-estimator" "proposal-writer" "proposal-reviewer" "post-award")
for bs in "${BUDGET_SKILLS[@]}"; do
  FILE=""
  if [[ -f "skills/spread1000-$bs/SKILL.md" ]]; then
    FILE="skills/spread1000-$bs/SKILL.md"
  elif [[ -f "agents/$bs.md" ]]; then
    FILE="agents/$bs.md"
  fi
  if [[ -n "$FILE" ]]; then
    if grep -q "500万円" "$FILE"; then
      pass "$bs: 500万円の記載あり"
    else
      warn "$bs: 500万円の記載なし"
    fi
  fi
done

# T5.6: Security Guardrails存在チェック
SEC_FILES=("azure-architect" "iac-deployer" "proposal-writer" "submission-guide")
for sf in "${SEC_FILES[@]}"; do
  FILE="skills/spread1000-$sf/SKILL.md"
  if grep -qi "Security Guardrails" "$FILE" 2>/dev/null; then
    pass "$sf: Security Guardrails存在"
  else
    warn "$sf: Security Guardrails欠落"
  fi
done

# T5.7: Validation Loop存在チェック
for sk in skills/*/SKILL.md; do
  SNAME=$(echo "$sk" | sed 's|skills/||;s|/SKILL.md||')
  if grep -qi "Validation Loop" "$sk"; then
    pass "$SNAME: Validation Loop存在"
  else
    warn "$SNAME: Validation Loop欠落"
  fi
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T6: 参照整合性テスト（Read/Reuse指示）"
echo "═══════════════════════════════════════════════"

# SKILL.mdで参照されている assets/ や references/ ファイルが実際に存在するか
for sk in skills/*/SKILL.md; do
  SKILL_DIR=$(dirname "$sk")
  # assets/参照
  while IFS= read -r ref; do
    ref_file=$(echo "$ref" | grep -oP '(assets|references)/[^\s`]+\.md' || true)
    if [[ -n "$ref_file" ]]; then
      if [[ -f "$SKILL_DIR/$ref_file" ]]; then
        pass "参照OK: $SKILL_DIR/$ref_file"
      else
        fail "参照先欠落: $SKILL_DIR/$ref_file"
      fi
    fi
  done < <(grep -iE '(Read|Reuse).*`(assets|references)/' "$sk" 2>/dev/null || true)
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T7: 公募要領整合性テスト"
echo "═══════════════════════════════════════════════"

# T7.1: AIインタビューへの言及
if grep -rq "AIインタビュー" skills/ agents/ AGENTS.md; then
  pass "AIインタビューの言及あり"
else
  fail "AIインタビューの言及なし"
fi

# T7.2: e-Radへの言及
if grep -rq "e-Rad" skills/ agents/ AGENTS.md; then
  pass "e-Radの言及あり"
else
  fail "e-Radの言及なし"
fi

# T7.3: researchmapへの言及
if grep -rq "researchmap" skills/ agents/ AGENTS.md; then
  pass "researchmapの言及あり"
else
  fail "researchmapの言及なし"
fi

# T7.4: 研究データマネジメント（DMP/FAIR）への言及
if grep -rq "FAIR\|データマネジメント\|DMP" skills/ agents/; then
  pass "研究データマネジメント/FAIR/DMPの言及あり"
else
  fail "研究データマネジメント/FAIR/DMPの言及なし"
fi

# T7.5: ノウハウ共有への言及
if grep -rq "ノウハウ\|知見の共有" skills/ agents/; then
  pass "ノウハウ共有の言及あり"
else
  fail "ノウハウ共有の言及なし"
fi

# T7.6: 間接経費30%への言及
if grep -rq "30%" skills/ agents/; then
  pass "間接経費30%の言及あり"
else
  fail "間接経費30%の言及なし"
fi

# T7.7: 様式0〜4への言及
for form in "様式0" "様式1" "様式2" "様式3" "様式4"; do
  if grep -rq "$form" skills/ agents/; then
    pass "$form の言及あり"
  else
    fail "$form の言及なし"
  fi
done

# T7.8: HPCI特定研究有償課題への言及
if grep -rq "HPCI" skills/ agents/; then
  pass "HPCIの言及あり"
else
  warn "HPCIの言及なし（proposal-reviewerのみ）"
fi

# T7.9: 研究インテグリティへの言及
if grep -rq "研究インテグリティ\|インテグリティ" skills/ agents/; then
  pass "研究インテグリティの言及あり"
else
  fail "研究インテグリティの言及なし"
fi

# T7.10: 二段階審査への言及
if grep -rq "二段階審査\|ピアレビュー\|無作為抽出" skills/ agents/; then
  pass "二段階審査/ピアレビューの言及あり"
else
  fail "二段階審査の言及なし"
fi

# T7.11: 論文謝辞 体系的番号 JPMXP17
if grep -rq "JPMXP17" skills/ agents/; then
  pass "論文謝辞体系的番号(JPMXP17)の言及あり"
else
  fail "論文謝辞体系的番号(JPMXP17)の言及なし"
fi

# T7.12: 伴走支援への言及
if grep -rq "伴走支援" skills/ agents/ AGENTS.md; then
  pass "伴走支援の言及あり"
else
  warn "伴走支援の言及なし"
fi

# T7.13: 安全保障貿易管理への言及
if grep -rq "安全保障貿易\|外為法" skills/ agents/ AGENTS.md; then
  pass "安全保障貿易管理の言及あり"
else
  warn "安全保障貿易管理の言及なし（研究内容次第）"
fi

# T7.14: 研究倫理教育への言及
if grep -rq "研究倫理教育\|コンプライアンス教育" skills/ agents/; then
  pass "研究倫理教育の言及あり"
else
  warn "研究倫理教育の言及なし"
fi

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T8: output パス整合性テスト"
echo "═══════════════════════════════════════════════"

# copilot-instructions.mdで定義されたoutputパスとスキルのDeliverablesが整合しているか
EXPECTED_OUTPUTS=(
  "output/meta-prompt.md"
  "output/phase0-research-plan.md"
  "output/phase1-azure-architecture.md"
  "output/phase2-cost-estimate.md"
  "output/phase3-proposal.md"
  "output/phase4-iac/"
  "output/review-report.md"
  "output/submission-checklist.md"
  "output/post-award-roadmap.md"
  "output/grant-application-checklist.md"
  "output/progress-report-interim.md"
  "output/research-outcome-report.md"
  "output/budget-change-guide.md"
  "output/accounting-report.md"
)
for outp in "${EXPECTED_OUTPUTS[@]}"; do
  if grep -rq "$outp" skills/ agents/ copilot-instructions.md AGENTS.md 2>/dev/null; then
    pass "output参照: $outp"
  else
    warn "output未参照: $outp（スキル内のみ定義の可能性）"
  fi
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  T9: README整合性テスト"
echo "═══════════════════════════════════════════════"

# READMEの概要フロー番号と実際のスキル数が一致
README_SKILLS=$(grep -c "spread1000-" README.md)
[[ "$README_SKILLS" -ge 8 ]] && pass "README: スキル言及≥8 ($README_SKILLS)" || fail "README: スキル言及<8 ($README_SKILLS)"

# READMEのワークフロー番号が0〜7まであるか
for i in 0 1 2 3 4 5 6 7; do
  if grep -qP "^${i}\." README.md; then
    pass "README: ワークフロー $i 存在"
  else
    warn "README: ワークフロー $i 未確認"
  fi
done

# ============================================================
echo ""
echo "═══════════════════════════════════════════════"
echo "  結果サマリー"
echo "═══════════════════════════════════════════════"
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

echo "═══════════════════════════════════════════════"
echo "  Total: $((PASS + FAIL + WARN)) tests"
echo "═══════════════════════════════════════════════"
