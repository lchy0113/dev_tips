#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source ~/.profile

# Declare local variables
PRODUCT_BASE="${bamboo.productBase}"
PRODUCT_NAME="${bamboo.productName}"
PRODUCT_MODEL="${bamboo.productModel}"
WORK_DIR="${bamboo.agentWorkingDirectory}"
PLAN_DIR="${bamboo.build.working.directory}"
BUILD_DIR="${WORK_DIR}/${PRODUCT_BASE}"
BUILD_KEY="${bamboo.buildKey}"
PLAN_NAME="${bamboo.shortPlanName}"

# Declare repo variables
REPO_URL="${bamboo.repoUrl}"
BRANCH="${bamboo.repoBranch}"
MANIFEST="${bamboo.repoManifest}"
REFERENCE="/git/${PRODUCT_BASE}"
SYNC_JOBS=8

# Build jobs (Bamboo substitution-safe)
BUILD_JOBS_RAW='${system.BAMBOO_BUILD_JOBS}'
if [[ "${BUILD_JOBS_RAW}" == '${system.BAMBOO_BUILD_JOBS}' || -z "${BUILD_JOBS_RAW}" ]]; then
  BUILD_JOBS=""
else
  BUILD_JOBS="${BUILD_JOBS_RAW}"
fi
if [[ -z "${BUILD_JOBS}" || "${BUILD_JOBS}" == "-1" ]]; then
  n="$(nproc)"
  BUILD_JOBS=$(( n > 2 ? n-2 : 1 ))
fi
if [[ "${BUILD_JOBS}" -lt 1 ]]; then
  BUILD_JOBS=1
fi

# Basic sanity checks
for v in WORK_DIR PRODUCT_BASE PRODUCT_NAME PRODUCT_MODEL PLAN_DIR BUILD_DIR REPO_URL BRANCH MANIFEST; do
  if [[ -z "${!v}" ]]; then
    echo "[ERROR] '${v}' is empty."
    exit 1
  fi
done

mkdir -p "${BUILD_DIR}"

# Make symbolic link of plan name
cd "${WORK_DIR}"
ln -sf -T "${BUILD_KEY}" "${PLAN_NAME}"

# Make symbolic links for artifact paths
ln -sf -T "${BUILD_DIR}/out" "${PLAN_DIR}/out"
ln -sf -T "${BUILD_DIR}/.repo" "${PLAN_DIR}/.repo"

cd "${BUILD_DIR}"

# Clean uncommitted changes (aggressive by design)
if [[ -d ".repo/manifests" ]]; then
  ( cd ".repo/manifests" && git checkout -- . && git clean -fffd )
fi
if [[ -d ".repo" ]]; then
  repo forall -c "git checkout -- .; git clean -fffd"
fi

# repo init/sync
repo init -u "${REPO_URL}" -b "${BRANCH}" -m "${MANIFEST}" --reference="${REFERENCE}"
repo sync -j"${SYNC_JOBS}" --force-sync

# Save manifest snapshot and diffs.
mkdir -p "out"
repo manifest -o "out/repo_manifest_snapshot.xml" -r --suppress-upstream-revision --suppress-dest-branch
if [[ -e ".repo/manifests/tags/latest.xml" ]]; then
  repo diffmanifests ".repo/manifests/tags/latest.xml" > "out/repo_manifest_changes.txt"
fi

# Set environment variables
export USER="bamboo"
export DAILY_DIR="/home/bamboo/daily/${PRODUCT_MODEL}"
export BUILD_TIME
BUILD_TIME="$(date +%s)"
export NOVA_ANDROID_SDK_ROOT="/home/bamboo/tools/android-sdk"

# Disable nounset for envsetup + lunch
set +u
source build/envsetup.sh
lunch "${PRODUCT_NAME}-userdebug"
set -u

# Build only custom targets and exit if assigned
CUSTOM_TARGETS="${CUSTOM_TARGETS:-}"
if [[ -n "${CUSTOM_TARGETS}" ]]; then
  # shellcheck disable=SC2086
  make -j"${BUILD_JOBS}" ${CUSTOM_TARGETS}
  exit $?
fi

# Build all targets (+ OTA package)
rm -f "${ANDROID_PRODUCT_OUT}"/*-ota-*.zip || true

if [[ "${PRODUCT_BASE}" == "fourgen" ]]; then
  make -j"${BUILD_JOBS}" BUILD_DATETIME="${BUILD_TIME}"
  make -j"${BUILD_JOBS}" otapackage BUILD_DATETIME="${BUILD_TIME}"
elif [[ "${PRODUCT_BASE}" == "newjeans" ]]; then
  make -j"${BUILD_JOBS}" rockdev BUILD_DATETIME="${BUILD_TIME}"
  make -j"${BUILD_JOBS}" otapackage BUILD_DATETIME="${BUILD_TIME}"
  make -j"${BUILD_JOBS}" pack
else
  make -j"${BUILD_JOBS}" BUILD_DATETIME="${BUILD_TIME}"
  make -j"${BUILD_JOBS}" otapackage BUILD_DATETIME="${BUILD_TIME}"
fi

# Copy OTA package for sharing through ssh connection.
mkdir -p "${DAILY_DIR}"

if compgen -G "${ANDROID_PRODUCT_OUT}"/*-ota-*.zip > /dev/null; then
  latest_ota_zip="$(ls -1t "${ANDROID_PRODUCT_OUT}"/*-ota-*.zip | head -n 1)"
else
  echo "[ERROR] OTA zip not found in ANDROID_PRODUCT_OUT='${ANDROID_PRODUCT_OUT}'"
  exit 1
fi

cp -f "${latest_ota_zip}" "${DAILY_DIR}/update.zip"
echo "[INFO] OTA copied: ${latest_ota_zip} -> ${DAILY_DIR}/update.zip"

# Make a link that is pointing the output path of product.
ln -sf -T "${ANDROID_PRODUCT_OUT}" "${ANDROID_PRODUCT_OUT}/../last"
if [[ "${PRODUCT_BASE}" == "newjeans" ]]; then
  ln -sf -T "${BUILD_DIR}/rockdev/Image-${PRODUCT_NAME}" "${ANDROID_PRODUCT_OUT}/../rockdev"
fi

# Compress all partition images
if [[ "${PRODUCT_BASE}" == "newjeans" ]]; then
  ( cd "rockdev/Image-${PRODUCT_NAME}" && tar zcf "${OUT}/partition_images.tar.gz" ./*.bin ./*.txt ./*.img )
else
  ( cd "${OUT}" && tar zcf "partition_images.tar.gz" ./*.img ./*.dtb ./*.rom )
fi
