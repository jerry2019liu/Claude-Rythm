#!/bin/bash
# -------------------------------------------------------
# Rhythm — Build & Package DMG
# Usage: bash build_dmg.sh
# Requires: macOS + Xcode command-line tools installed
# -------------------------------------------------------
set -euo pipefail

APP_NAME="Rhythm"
VERSION="1.0.0"
SCHEME="Rhythm"
PROJECT="Rhythm.xcodeproj"
CONFIG="Release"
BUILD_DIR=".build"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
STAGING_DIR="${BUILD_DIR}/dmg_staging"

# ---- 1. Build ----
echo "🔨  Building ${APP_NAME} (${CONFIG})..."

xcodebuild \
    -project "${PROJECT}" \
    -scheme  "${SCHEME}" \
    -configuration "${CONFIG}" \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    clean build \
    | xcpretty 2>/dev/null || true   # xcpretty is optional; falls back to raw output

# Locate the .app bundle
APP_PATH=$(find "${BUILD_DIR}/DerivedData" \
    -name "${APP_NAME}.app" -type d \
    ! -path "*/Index.noindex/*" \
    | head -1)

if [[ -z "${APP_PATH}" ]]; then
    echo "❌  Build failed — ${APP_NAME}.app not found in ${BUILD_DIR}/DerivedData"
    exit 1
fi

echo "✅  Build succeeded: ${APP_PATH}"

# ---- 2. Stage DMG contents ----
echo "📂  Staging DMG contents..."

rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

cp -R "${APP_PATH}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

# ---- 3. Create DMG ----
echo "💿  Creating ${DMG_NAME}..."

# Remove previous DMG if exists
rm -f "${BUILD_DIR}/${DMG_NAME}"

hdiutil create \
    -volname  "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "${BUILD_DIR}/${DMG_NAME}"

# ---- 4. Done ----
DMG_SIZE=$(du -sh "${BUILD_DIR}/${DMG_NAME}" | cut -f1)
echo ""
echo "🎉  Done!"
echo "    DMG : ${BUILD_DIR}/${DMG_NAME}  (${DMG_SIZE})"
echo ""
echo "    To open: open ${BUILD_DIR}/${DMG_NAME}"
