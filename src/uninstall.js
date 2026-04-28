#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { PACKAGE_NAME, findProjectRoot } = require("./deploy");

const PKG_DIR = __dirname;

const PROJECT_ROOT = findProjectRoot(PKG_DIR);
if (!PROJECT_ROOT || path.resolve(PROJECT_ROOT) === path.resolve(PKG_DIR)) {
  process.exit(0);
}

const GH_DIR = path.join(PROJECT_ROOT, ".github");
const CLAUDE_DIR = path.join(PROJECT_ROOT, ".claude");

// ── Helpers ──────────────────────────────────────────
function rmrf(p) {
  if (!fs.existsSync(p)) return false;
  fs.rmSync(p, { recursive: true, force: true });
  return true;
}

// ── Main ─────────────────────────────────────────────
console.log(`\n${PACKAGE_NAME}: removing deployed files ...\n`);

// 1. Remove skills
const skillsSrc = path.join(PKG_DIR, "skills");
if (fs.existsSync(skillsSrc)) {
  const dirs = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter(d => d.isDirectory());
  for (const d of dirs) {
    if (rmrf(path.join(GH_DIR, "skills", d.name))) {
      console.log(`  -     .github/skills/${d.name}`);
    }
    if (rmrf(path.join(CLAUDE_DIR, "skills", d.name))) {
      console.log(`  -     .claude/skills/${d.name}`);
    }
  }
}

// 2. Remove agents
const agentsSrc = path.join(PKG_DIR, "agents");
if (fs.existsSync(agentsSrc)) {
  const files = fs.readdirSync(agentsSrc).filter(f => f.endsWith(".md"));
  for (const f of files) {
    const githubTarget = path.join(GH_DIR, "agents", f);
    if (fs.existsSync(githubTarget)) {
      fs.unlinkSync(githubTarget);
      console.log(`  -     .github/agents/${f}`);
    }

    const claudeTarget = path.join(CLAUDE_DIR, "agents", f.replace(/\.agent\.md$/, ".md"));
    if (fs.existsSync(claudeTarget)) {
      fs.unlinkSync(claudeTarget);
      console.log(`  -     .claude/agents/${path.basename(claudeTarget)}`);
    }
  }
}

// AGENTS.md / copilot-instructions.md / CLAUDE.md are preserved (user may have edited them)
console.log("\n  note: .github/AGENTS.md, .github/copilot-instructions.md, and CLAUDE.md are preserved");
console.log(`${PACKAGE_NAME}: done\n`);
