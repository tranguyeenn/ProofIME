#!/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly PROJECT="$PROJECT_ROOT/ProofIME.xcodeproj"
readonly SCHEME="ProofIMEInputMethod"
readonly CONFIGURATION="${CONFIGURATION:-Debug}"
readonly PRODUCT_NAME="ProofIMEInputMethod.inputmethod"
readonly USER_INSTALL_DIR="$HOME/Library/Input Methods"
readonly SYSTEM_INSTALL_DIR="/Library/Input Methods"
readonly USER_BUNDLE="$USER_INSTALL_DIR/$PRODUCT_NAME"
readonly SYSTEM_BUNDLE="$SYSTEM_INSTALL_DIR/$PRODUCT_NAME"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "error: required command not found: $1" >&2
        exit 1
    fi
}

plist_value() {
    /usr/bin/plutil -extract "$2" raw -o - "$1"
}

verify_plist() {
    local plist="$1"

    /usr/bin/plutil -lint "$plist" >/dev/null

    local key
    for key in \
        ComponentInputModeDict.tsInputModeListKey \
        ComponentInputModeDict.tsVisibleInputModeOrderedArrayKey \
        TISInputSourceID \
        TISInputSourceLanguages \
        TISInputSourceType \
        TISInputSourceCategory \
        InputMethodConnectionName \
        InputMethodServerControllerClass \
        CFBundlePackageType \
        NSPrincipalClass; do
        if ! /usr/bin/plutil -type "$key" "$plist" >/dev/null 2>&1; then
            echo "error: missing required plist key '$key' in $plist" >&2
            exit 1
        fi
    done

    [[ "$(plist_value "$plist" TISInputSourceCategory)" == "TISCategoryKeyboardInputSource" ]] || {
        echo "error: TISInputSourceCategory has an unexpected value in $plist" >&2
        exit 1
    }
    [[ "$(plist_value "$plist" CFBundlePackageType)" == "APPL" ]] || {
        echo "error: CFBundlePackageType must be APPL in $plist" >&2
        exit 1
    }
    [[ "$(plist_value "$plist" NSPrincipalClass)" == "NSApplication" ]] || {
        echo "error: NSPrincipalClass must be NSApplication in $plist" >&2
        exit 1
    }
}

require_command xcodebuild

echo "Building $SCHEME ($CONFIGURATION)..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    build

echo "Locating the built product from Xcode build settings..."
BUILD_SETTINGS="$(xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -showBuildSettings)"

TARGET_BUILD_DIR="$(awk -F ' = ' '/^[[:space:]]*TARGET_BUILD_DIR = / { print $2; exit }' <<<"$BUILD_SETTINGS")"
FULL_PRODUCT_NAME="$(awk -F ' = ' '/^[[:space:]]*FULL_PRODUCT_NAME = / { print $2; exit }' <<<"$BUILD_SETTINGS")"

if [[ -z "$TARGET_BUILD_DIR" || -z "$FULL_PRODUCT_NAME" ]]; then
    echo "error: could not determine the product path from Xcode build settings" >&2
    exit 1
fi

BUILT_BUNDLE="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
BUILT_PLIST="$BUILT_BUNDLE/Contents/Info.plist"

if [[ "$FULL_PRODUCT_NAME" != "$PRODUCT_NAME" ]]; then
    echo "error: Xcode reported unexpected product name: $FULL_PRODUCT_NAME" >&2
    exit 1
fi
if [[ ! -d "$BUILT_BUNDLE" || ! -f "$BUILT_PLIST" ]]; then
    echo "error: built input method bundle not found at $BUILT_BUNDLE" >&2
    exit 1
fi

verify_plist "$BUILT_PLIST"
echo "Built bundle: $BUILT_BUNDLE"

mkdir -p "$USER_INSTALL_DIR"
if ! rm -rf "$USER_BUNDLE"; then
    echo "Removing a privileged existing user installation..."
    sudo rm -rf "$USER_BUNDLE"
fi
/usr/bin/ditto "$BUILT_BUNDLE" "$USER_BUNDLE"
/usr/bin/xattr -cr "$USER_BUNDLE"

echo "Installing system-wide (sudo may prompt for your password)..."
sudo mkdir -p "$SYSTEM_INSTALL_DIR"
sudo rm -rf "$SYSTEM_BUNDLE"
sudo /usr/bin/ditto "$BUILT_BUNDLE" "$SYSTEM_BUNDLE"
sudo /usr/bin/xattr -cr "$SYSTEM_BUNDLE"

verify_plist "$USER_BUNDLE/Contents/Info.plist"
sudo /usr/bin/plutil -lint "$SYSTEM_BUNDLE/Contents/Info.plist" >/dev/null

echo
echo "User Input Methods:"
ls -la "$USER_INSTALL_DIR"

echo
echo "System Input Methods:"
sudo ls -la "$SYSTEM_INSTALL_DIR"

echo
echo "Installed ProofIMEInputMethod Info.plist:"
/usr/bin/plutil -p "$USER_BUNDLE/Contents/Info.plist"
