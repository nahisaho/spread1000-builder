"use strict";

const fs = require("fs");
const path = require("path");

const PACKAGE_NAME = "@nahisaho/spread1000-builder";

function findProjectRoot(pkgDir) {
  if (process.env.INIT_CWD) return process.env.INIT_CWD;

  let dir = path.resolve(pkgDir, "..");
  while (dir !== path.dirname(dir)) {
    const pkg = path.join(dir, "package.json");
    if (fs.existsSync(pkg)) {
      try {
        const data = JSON.parse(fs.readFileSync(pkg, "utf8"));
        if (data.name !== PACKAGE_NAME) return dir;
      } catch {
        // ignore malformed package.json while searching upward
      }
    }
    dir = path.dirname(dir);
  }

  return null;
}

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
    return;
  }

  mkdirp(path.dirname(dest));
  fs.copyFileSync(src, dest);
}

function safeCopyFile(src, dest, label, logger = console.log) {
  if (!fs.existsSync(src)) return;
  if (fs.existsSync(dest)) {
    logger(`  skip  ${label} (already exists)`);
    return;
  }

  mkdirp(path.dirname(dest));
  fs.copyFileSync(src, dest);
  logger(`  +     ${label}`);
}

function extractFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!match) {
    return { frontmatter: {}, body: content.trim() };
  }

  const rawFrontmatter = match[1];
  const body = match[2].trim();
  const frontmatter = {};
  let currentKey = null;

  for (const line of rawFrontmatter.split("\n")) {
    const keyValueMatch = line.match(/^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$/);
    if (keyValueMatch) {
      const [, key, value] = keyValueMatch;
      currentKey = key;
      if (value === "|") {
        frontmatter[key] = [];
      } else {
        frontmatter[key] = value.trim();
      }
      continue;
    }

    if (currentKey && Array.isArray(frontmatter[currentKey])) {
      frontmatter[currentKey].push(line.replace(/^\s{2}/, ""));
    }
  }

  for (const [key, value] of Object.entries(frontmatter)) {
    if (Array.isArray(value)) {
      frontmatter[key] = value.join("\n").trim();
    }
  }

  return { frontmatter, body };
}

function buildClaudeAgentContent(srcPath) {
  const content = fs.readFileSync(srcPath, "utf8");
  const { frontmatter, body } = extractFrontmatter(content);
  const lines = [
    "---",
    `name: ${frontmatter.name}`,
    "description: |",
    ...String(frontmatter.description || "")
      .split("\n")
      .map(line => `  ${line}`)
  ];

  if (frontmatter.name === "proposal-reviewer") {
    lines.push("tools: Read, Grep, Glob");
  }

  lines.push("---", "", body, "");
  return lines.join("\n");
}

function deploySuite(pkgDir, projectRoot, logger = console.log) {
  const githubDir = path.join(projectRoot, ".github");
  const claudeDir = path.join(projectRoot, ".claude");

  mkdirp(githubDir);
  mkdirp(claudeDir);

  const skillsSrc = path.join(pkgDir, "skills");
  if (fs.existsSync(skillsSrc)) {
    const skillDirs = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter(entry => entry.isDirectory());
    const githubSkillsDest = path.join(githubDir, "skills");
    const claudeSkillsDest = path.join(claudeDir, "skills");

    for (const skillDir of skillDirs) {
      copyRecursive(path.join(skillsSrc, skillDir.name), path.join(githubSkillsDest, skillDir.name));
      logger(`  +     .github/skills/${skillDir.name}`);
      copyRecursive(path.join(skillsSrc, skillDir.name), path.join(claudeSkillsDest, skillDir.name));
      logger(`  +     .claude/skills/${skillDir.name}`);
    }
  }

  const agentsSrc = path.join(pkgDir, "agents");
  if (fs.existsSync(agentsSrc)) {
    const githubAgentsDest = path.join(githubDir, "agents");
    const claudeAgentsDest = path.join(claudeDir, "agents");
    mkdirp(githubAgentsDest);
    mkdirp(claudeAgentsDest);

    const files = fs.readdirSync(agentsSrc).filter(file => file.endsWith(".md"));
    for (const file of files) {
      const src = path.join(agentsSrc, file);
      fs.copyFileSync(src, path.join(githubAgentsDest, file));
      logger(`  +     .github/agents/${file}`);

      const claudeFileName = file.replace(/\.agent\.md$/, ".md");
      fs.writeFileSync(path.join(claudeAgentsDest, claudeFileName), buildClaudeAgentContent(src));
      logger(`  +     .claude/agents/${claudeFileName}`);
    }
  }

  safeCopyFile(
    path.join(pkgDir, "AGENTS.md"),
    path.join(githubDir, "AGENTS.md"),
    ".github/AGENTS.md",
    logger
  );

  safeCopyFile(
    path.join(pkgDir, "copilot-instructions.md"),
    path.join(githubDir, "copilot-instructions.md"),
    ".github/copilot-instructions.md",
    logger
  );

  safeCopyFile(
    path.join(pkgDir, "CLAUDE.md"),
    path.join(projectRoot, "CLAUDE.md"),
    "CLAUDE.md",
    logger
  );
}

module.exports = {
  PACKAGE_NAME,
  buildClaudeAgentContent,
  deploySuite,
  extractFrontmatter,
  findProjectRoot
};