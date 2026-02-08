#!/bin/bash
# Build script for Downloads Manager
# Creates a proper macOS .app bundle

set -e

APP_NAME="DownloadsManager"
DISPLAY_NAME="Downloads Manager"
BUILD_DIR=".build"
APP_BUNDLE="$BUILD_DIR/$DISPLAY_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
SOURCES_DIR="Sources/DownloadsManager"

# Collect all Swift source files
SWIFT_FILES=$(find "$SOURCES_DIR" -name "*.swift" | sort)

echo "=== Building $DISPLAY_NAME ==="
echo ""

# Clean previous build
rm -rf "$APP_BUNDLE"

# Create .app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$CONTENTS_DIR/Resources"

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/Info.plist"

# Compile
echo "Compiling..."
swiftc \
    -o "$MACOS_DIR/$APP_NAME" \
    -parse-as-library \
    -target arm64-apple-macosx14.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    $SWIFT_FILES

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo ""
echo "Build successful!"
echo "App bundle: $APP_BUNDLE"
echo ""
echo "Run with: open \"$APP_BUNDLE\""
