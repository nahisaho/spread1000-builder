#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const DRAWIO_REPO = "https://github.com/simonkurtz-MSFT/drawio-mcp-server.git";
const DRAWIO_DOCKER_IMAGE = "simonkurtzmsft/drawio-mcp-server:latest";

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
spread1000-generator — draw.io MCP Server setup for SPReAD Builder

Usage:
  npx @nahisaho/spread1000-builder init [method]

Methods:
  docker   (default) Pull Docker image and configure VS Code MCP
  deno     Clone repo and configure VS Code MCP with Deno stdio transport

Examples:
  npx @nahisaho/spread1000-builder init           # Docker (recommended)
  npx @nahisaho/spread1000-builder init docker     # Docker
  npx @nahisaho/spread1000-builder init deno       # Deno (source)
`);
}

// ── init ─────────────────────────────────────────────
function init(method) {
  console.log("\n🔧 spread1000-generator init\n");

  if (method === "docker") {
    initDocker();
  } else if (method === "deno") {
    initDeno();
  } else {
    console.error(`Unknown method: ${method}. Use 'docker' or 'deno'.`);
    process.exit(1);
  }
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
    drawio: {
      url: "http://localhost:8080/mcp"
    }
  };
  writeMcpConfig(mcpConfig);

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
    drawio: {
      command: "deno",
      args: [
        "run",
        "--allow-net",
        "--allow-read",
        "--allow-env",
        indexPath
      ]
    }
  };
  writeMcpConfig(mcpConfig);

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

function writeMcpConfig(serverConfig) {
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

  // Add/update drawio server entry
  config.servers.drawio = serverConfig;

  // Write
  fs.mkdirSync(vscodeDir, { recursive: true });
  fs.writeFileSync(mcpPath, JSON.stringify(config, null, 2) + "\n");
  console.log("📝 Updated .vscode/mcp.json with drawio MCP server.");
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
