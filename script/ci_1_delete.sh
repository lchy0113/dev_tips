#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

PRODUCT_BASE="${bamboo.productBase}"
WORK_DIR="${bamboo.agentWorkingDirectory}"
BUILD_DIR="${WORK_DIR}/${PRODUCT_BASE}"
OUT_DIR="${BUILD_DIR}/out"

# Safety checks
if [[ -z "${WORK_DIR}" || -z "${PRODUCT_BASE}" ]]; then
  echo "[ERROR] WORK_DIR or PRODUCT_BASE is empty."
  exit 1
fi

if [[ "${BUILD_DIR}" == "/" || "${OUT_DIR}" == "/" || "${OUT_DIR}" == "" ]]; then
  echo "[ERROR] Dangerous path detected: BUILD_DIR='${BUILD_DIR}', OUT_DIR='${OUT_DIR}'"
  exit 1
fi

# Ensure BUILD_DIR exists
mkdir -p "${BUILD_DIR}"

# Delete out directory
if [[ -d "${OUT_DIR}" ]]; then
  echo "[INFO] Removing '${OUT_DIR}'"
  rm -rf "${OUT_DIR}"
else
  echo "[INFO] '${OUT_DIR}' does not exist. Skip."
fi

# productBase : newjeans
# productModel : SWP530-4H
# productName : swp5304h
# repoBranch : release/swp5304h
# repoManifest : release.xml
# repoUrl : ssh://git@git.kdiwin.com:7999/hn5g/project-manifests