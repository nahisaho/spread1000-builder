#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const { deploySuite } = require("../deploy");

const DRAWIO_REPO = "https://github.com/simonkurtz-MSFT/drawio-mcp-server.git";
const DRAWIO_DOCKER_IMAGE = "simonkurtzmsft/drawio-mcp-server:latest";
const PKG_DIR = path.resolve(__dirname, "..");

// ToolUniverse MCP — compact mode server (uvx tooluniverse)
// https://github.com/mims-harvard/ToolUniverse
const TOOLUNIVERSE_VSCODE_ENTRY = {
  type: "stdio",
  command: "uvx",
  args: ["tooluniverse"],
  env: { PYTHONIOENCODING: "utf-8" }
};
const TOOLUNIVERSE_CLAUDE_ENTRY = {
  command: "uvx",
  args: ["tooluniverse"],
  env: { PYTHONIOENCODING: "utf-8" }
};

// ── CLI ──────────────────────────────────────────────
const args = process.argv.slice(2);
const command = args[0];

if (!command || command === "--help" || command === "-h") {
  printUsage();
  process.exit(0);
}

if (command === "init") {
  const method = args[1] || "docker";
  init(method);
} else {
  console.error(`Unknown command: ${command}`);
  printUsage();
  process.exit(1);
}

function printUsage() {
  console.log(`
spread1000-generator — SPReAD Builder setup for GitHub Copilot and Claude Code

Usage:
  npx @nahisaho/spread1000-builder init [method]

Methods:
  docker   (default) Pull Docker image and configure VS Code MCP + ToolUniverse MCP
  deno     Clone repo and configure VS Code MCP with Deno stdio transport + ToolUniverse MCP

ToolUniverse MCP (always installed and configured):
  Installs uv automatically if not present.
  Installs tooluniverse via: uv tool install tooluniverse
  Provides 1,200+ scientific tools (PubMed, ArXiv, UniProt, ChEMBL, etc.)
  for AI for Science research in Phase 0.
  Configured for: VS Code/GitHub Copilot (.vscode/mcp.json)
                  Claude Code (.mcp.json)

Examples:
  npx @nahisaho/spread1000-builder init            # Deploy suite + Docker + ToolUniverse
  npx @nahisaho/spread1000-builder init docker     # Deploy suite + Docker + ToolUniverse
  npx @nahisaho/spread1000-builder init deno       # Deploy suite + Deno + ToolUniverse
`);
}

// ── init ─────────────────────────────────────────────
function init(method) {
  console.log("\n🔧 spread1000-generator init\n");

  deployProjectFiles();
  initToolUniverse();

  if (method === "docker") {
    initDocker();
  } else if (method === "deno") {
    initDeno();
  } else {
    console.error(`Unknown method: ${method}. Use 'docker' or 'deno'.`);
    process.exit(1);
  }
}

function deployProjectFiles() {
  const projectRoot = process.cwd();
  console.log(`📁 Deploying SPReAD Builder assets to ${projectRoot} ...`);
  deploySuite(PKG_DIR, projectRoot);
  console.log("✅ Project files deployed for GitHub Copilot and Claude Code.\n");
}

// ── ToolUniverse MCP ─────────────────────────────────
function initToolUniverse() {
  console.log("🔬 Installing ToolUniverse MCP (AI for Science tools) ...");

  // 1. Install uv if missing
  if (!commandExists("uv")) {
    installUv();
  } else {
    console.log("✅ uv is already installed.");
  }

  // 2. Resolve uv binary (may have been freshly installed, not yet on PATH)
  const uvPath = resolveUv();
  if (!uvPath) {
    console.error("❌ uv could not be found after installation attempt.");
    console.error("   Please install uv manually: https://docs.astral.sh/uv/getting-started/installation/");
    console.error("   Then re-run: npx @nahisaho/spread1000-builder init");
    process.exit(1);
  }

  // 3. Install tooluniverse via uv tool install
  console.log("📦 Installing tooluniverse ...");
  try {
    execSync(`"${uvPath}" tool install tooluniverse`, { stdio: "inherit" });
    console.log("✅ tooluniverse installed.");
  } catch {
    console.warn("⚠️  'uv tool install tooluniverse' failed.");
    console.warn("   tooluniverse will be downloaded on first MCP server start via uvx.");
  }

  // 4. Configure VS Code / GitHub Copilot (.vscode/mcp.json)
  writeMcpConfig("tooluniverse", TOOLUNIVERSE_VSCODE_ENTRY);

  // 5. Configure Claude Code (.mcp.json in project root)
  writeClaudeCodeMcpConfig("tooluniverse", TOOLUNIVERSE_CLAUDE_ENTRY);

  console.log("✅ ToolUniverse MCP configured!");
  console.log("   VS Code / GitHub Copilot: .vscode/mcp.json");
  console.log("   Claude Code:              .mcp.json");
  console.log("   Restart VS Code / Claude Code to activate.\n");
}

function installUv() {
  console.log("📦 Installing uv (Python package manager) ...");
  try {
    if (process.platform === "win32") {
      execSync(
        `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`,
        { stdio: "inherit" }
      );
    } else {
      execSync(
        "curl -LsSf https://astral.sh/uv/install.sh | sh",
        { stdio: "inherit" }
      );
    }
    console.log("✅ uv installed.");
  } catch {
    console.error("❌ Failed to install uv automatically.");
    console.error("   Please install manually: https://docs.astral.sh/uv/getting-started/installation/");
    process.exit(1);
  }
}

function resolveUv() {
  if (commandExists("uv")) return "uv";

  const os = require("os");
  const candidates = process.platform === "win32"
    ? [
        path.join(os.homedir(), ".local", "bin", "uv.exe"),
        path.join(os.homedir(), ".cargo", "bin", "uv.exe")
      ]
    : [
        path.join(os.homedir(), ".local", "bin", "uv"),
        path.join(os.homedir(), ".cargo", "bin", "uv")
      ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

// ── Docker ───────────────────────────────────────────
function initDocker() {
  // 1. Check Docker availability
  if (!commandExists("docker")) {
    console.error("❌ Docker is not installed or not in PATH.");
    console.error("   Install Docker: https://docs.docker.com/get-docker/");
    process.exit(1);
  }

  // 2. Pull image
  console.log(`📦 Pulling ${DRAWIO_DOCKER_IMAGE} ...`);
  try {
    execSync(`docker pull ${DRAWIO_DOCKER_IMAGE}`, { stdio: "inherit" });
  } catch {
    console.error("❌ Failed to pull Docker image.");
    process.exit(1);
  }

  // 3. Start container (if not already running)
  const running = isContainerRunning("drawio-mcp-server");
  if (running) {
    console.log("✅ Container 'drawio-mcp-server' is already running.");
  } else {
    console.log("🚀 Starting drawio-mcp-server container ...");
    // Remove stopped container if exists
    try {
      execSync("docker rm drawio-mcp-server 2>/dev/null", { stdio: "ignore" });
    } catch { /* ignore */ }
    try {
      execSync(
        `docker run -d --name drawio-mcp-server -p 8080:8080 ${DRAWIO_DOCKER_IMAGE}`,
        { stdio: "inherit" }
      );
    } catch {
      console.error("❌ Failed to start container.");
      process.exit(1);
    }
  }

  // 4. Health check
  console.log("🩺 Health check ...");
  let healthy = false;
  for (let i = 0; i < 10; i++) {
    try {
      execSync("curl -sf http://localhost:8080/health", { stdio: "ignore" });
      healthy = true;
      break;
    } catch {
      // Wait 1 second and retry
      execSync("sleep 1", { stdio: "ignore" });
    }
  }
  if (healthy) {
    console.log("✅ drawio-mcp-server is healthy.");
  } else {
    console.warn("⚠️  Health check failed. Server may still be starting up.");
  }

  // 5. Configure VS Code MCP
  const mcpConfig = {
    url: "http://localhost:8080/mcp"
  };
  writeMcpConfig("drawio", mcpConfig);

  console.log("\n✅ Docker setup complete!");
  console.log("   Container: drawio-mcp-server (port 8080)");
  console.log("   VS Code:   .vscode/mcp.json configured\n");
}

// ── Deno ─────────────────────────────────────────────
function initDeno() {
  // 1. Check Deno availability
  if (!commandExists("deno")) {
    console.error("❌ Deno is not installed or not in PATH.");
    console.error("   Install Deno: https://deno.com/");
    process.exit(1);
  }

  // 2. Determine install location
  const installDir = path.resolve(".drawio-mcp-server");

  if (fs.existsSync(installDir)) {
    console.log(`✅ drawio-mcp-server already cloned at ${installDir}`);
    console.log("   Pulling latest changes ...");
    try {
      execSync("git pull", { cwd: installDir, stdio: "inherit" });
    } catch {
      console.warn("⚠️  git pull failed. Using existing version.");
    }
  } else {
    console.log(`📦 Cloning drawio-mcp-server to ${installDir} ...`);
    try {
      execSync(`git clone ${DRAWIO_REPO} "${installDir}"`, { stdio: "inherit" });
    } catch {
      console.error("❌ Failed to clone repository.");
      process.exit(1);
    }
  }

  // 3. Add to .gitignore
  addToGitignore(".drawio-mcp-server/");

  // 4. Configure VS Code MCP (stdio transport)
  const indexPath = path.resolve(installDir, "src", "index.ts");
  const mcpConfig = {
    command: "deno",
    args: [
      "run",
      "--allow-net",
      "--allow-read",
      "--allow-env",
      indexPath
    ]
  };
  writeMcpConfig("drawio", mcpConfig);

  console.log("\n✅ Deno setup complete!");
  console.log(`   Source:   ${installDir}`);
  console.log("   VS Code: .vscode/mcp.json configured (stdio transport)\n");
}

// ── Helpers ──────────────────────────────────────────
function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function isContainerRunning(name) {
  try {
    const output = execSync(
      `docker inspect -f '{{.State.Running}}' ${name} 2>/dev/null`,
      { encoding: "utf8" }
    ).trim();
    return output === "true";
  } catch {
    return false;
  }
}

function writeMcpConfig(serverName, serverConfig) {
  const vscodeDir = path.resolve(".vscode");
  const mcpPath = path.join(vscodeDir, "mcp.json");

  let config = { servers: {} };

  // Read existing mcp.json if present
  if (fs.existsSync(mcpPath)) {
    try {
      config = JSON.parse(fs.readFileSync(mcpPath, "utf8"));
      if (!config.servers) config.servers = {};
    } catch {
      console.warn("⚠️  Could not parse existing .vscode/mcp.json. Creating new one.");
      config = { servers: {} };
    }
  }

  // Add/update server entry
  config.servers[serverName] = serverConfig;

  // Write
  fs.mkdirSync(vscodeDir, { recursive: true });
  fs.writeFileSync(mcpPath, JSON.stringify(config, null, 2) + "\n");
  console.log(`📝 Updated .vscode/mcp.json with '${serverName}' MCP server.`);
}

function writeClaudeCodeMcpConfig(serverName, serverConfig) {
  const mcpPath = path.resolve(".mcp.json");

  let config = { mcpServers: {} };

  // Read existing .mcp.json if present
  if (fs.existsSync(mcpPath)) {
    try {
      config = JSON.parse(fs.readFileSync(mcpPath, "utf8"));
      if (!config.mcpServers) config.mcpServers = {};
    } catch {
      console.warn("⚠️  Could not parse existing .mcp.json. Creating new one.");
      config = { mcpServers: {} };
    }
  }

  // Add/update server entry
  config.mcpServers[serverName] = serverConfig;

  // Write
  fs.writeFileSync(mcpPath, JSON.stringify(config, null, 2) + "\n");
  console.log(`📝 Updated .mcp.json with '${serverName}' MCP server (Claude Code).`);
}

function addToGitignore(entry) {
  const gitignorePath = path.resolve(".gitignore");
  if (fs.existsSync(gitignorePath)) {
    const content = fs.readFileSync(gitignorePath, "utf8");
    if (content.includes(entry)) return;
    fs.appendFileSync(gitignorePath, `\n# draw.io MCP Server (local)\n${entry}\n`);
  } else {
    fs.writeFileSync(gitignorePath, `# draw.io MCP Server (local)\n${entry}\n`);
  }
  console.log("📝 Added .drawio-mcp-server/ to .gitignore");
}
