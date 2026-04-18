#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const PACKAGE_NAME = "@nahisaho/spread1000-builder";
const PKG_DIR = __dirname;

// ── Detect project root ─────────────────────────────
function findProjectRoot() {
  if (process.env.INIT_CWD) return process.env.INIT_CWD;
  let dir = path.resolve(PKG_DIR, "..");
  while (dir !== path.dirname(dir)) {
    const pkg = path.join(dir, "package.json");
    if (fs.existsSync(pkg)) {
      try {
        const data = JSON.parse(fs.readFileSync(pkg, "utf8"));
        if (data.name !== PACKAGE_NAME) return dir;
      } catch { /* ignore */ }
    }
    dir = path.dirname(dir);
  }
  return null;
}

const PROJECT_ROOT = findProjectRoot();
if (!PROJECT_ROOT || path.resolve(PROJECT_ROOT) === path.resolve(PKG_DIR)) {
  process.exit(0);
}

const GH_DIR = path.join(PROJECT_ROOT, ".github");

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
      console.log(`  -     skills/${d.name}`);
    }
  }
}

// 2. Remove agents
const agentsSrc = path.join(PKG_DIR, "agents");
if (fs.existsSync(agentsSrc)) {
  const files = fs.readdirSync(agentsSrc).filter(f => f.endsWith(".md"));
  for (const f of files) {
    const target = path.join(GH_DIR, "agents", f);
    if (fs.existsSync(target)) {
      fs.unlinkSync(target);
      console.log(`  -     agents/${f}`);
    }
  }
}

// AGENTS.md / copilot-instructions.md are preserved (user may have edited them)
console.log(`\n  note: .github/AGENTS.md and copilot-instructions.md are preserved`);
console.log(`${PACKAGE_NAME}: done\n`);
