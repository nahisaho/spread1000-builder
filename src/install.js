#!/usr/bin/env node
"use strict";

const path = require("path");
const { PACKAGE_NAME, deploySuite, findProjectRoot } = require("./deploy");

const PKG_DIR = __dirname;
const PROJECT_ROOT = findProjectRoot(PKG_DIR);

function install() {
  if (!PROJECT_ROOT || path.resolve(PROJECT_ROOT) === path.resolve(PKG_DIR)) {
    return false;
  }

  console.log(`\n${PACKAGE_NAME}: deploying to .github/ and .claude/ ...\n`);
  deploySuite(PKG_DIR, PROJECT_ROOT);
  console.log(`\n${PACKAGE_NAME}: done\n`);
  return true;
}

if (require.main === module) {
  install();
}

module.exports = {
  install
};
