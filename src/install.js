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

// Skip if development install or project root not found
if (!PROJECT_ROOT || path.resolve(PROJECT_ROOT) === path.resolve(PKG_DIR)) {
  process.exit(0);
}

const GH_DIR = path.join(PROJECT_ROOT, ".github");

// ── Helpers ──────────────────────────────────────────
function mkdirp(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function copyRecursive(src, dest) {
  const stat = fs.statSync(src);
  if (stat.isDirectory()) {
    mkdirp(dest);
    for (const entry of fs.readdirSync(src)) {
      copyRecursive(path.join(src, entry), path.join(dest, entry));
    }
  } else {
    fs.copyFileSync(src, dest);
  }
}

function safeCopyFile(src, dest, label) {
  if (!fs.existsSync(src)) return;
  if (fs.existsSync(dest)) {
    console.log(`  skip  ${label} (already exists)`);
    return;
  }
  mkdirp(path.dirname(dest));
  fs.copyFileSync(src, dest);
  console.log(`  +     ${label}`);
}

// ── Main ─────────────────────────────────────────────
console.log(`\n${PACKAGE_NAME}: deploying to .github/ ...\n`);
mkdirp(GH_DIR);

// 1. Skills → .github/skills/
const skillsSrc = path.join(PKG_DIR, "skills");
if (fs.existsSync(skillsSrc)) {
  const skillsDest = path.join(GH_DIR, "skills");
  const dirs = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter(d => d.isDirectory());
  for (const d of dirs) {
    copyRecursive(path.join(skillsSrc, d.name), path.join(skillsDest, d.name));
    console.log(`  +     skills/${d.name}`);
  }
}

// 2. Agents → .github/agents/
const agentsSrc = path.join(PKG_DIR, "agents");
if (fs.existsSync(agentsSrc)) {
  const agentsDest = path.join(GH_DIR, "agents");
  mkdirp(agentsDest);
  const files = fs.readdirSync(agentsSrc).filter(f => f.endsWith(".md"));
  for (const f of files) {
    fs.copyFileSync(path.join(agentsSrc, f), path.join(agentsDest, f));
    console.log(`  +     agents/${f}`);
  }
}

// 3. AGENTS.md → .github/AGENTS.md (skip if exists)
safeCopyFile(
  path.join(PKG_DIR, "AGENTS.md"),
  path.join(GH_DIR, "AGENTS.md"),
  "AGENTS.md"
);

// 4. copilot-instructions.md → .github/copilot-instructions.md (skip if exists)
safeCopyFile(
  path.join(PKG_DIR, "copilot-instructions.md"),
  path.join(GH_DIR, "copilot-instructions.md"),
  "copilot-instructions.md"
);

console.log(`\n${PACKAGE_NAME}: done\n`);
