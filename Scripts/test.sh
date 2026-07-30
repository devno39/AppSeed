#!/bin/bash
# Runs the AppSeedTests suite on a booted-or-bootable simulator.
#   Scripts/test.sh                 first available iPhone simulator
#   Scripts/test.sh "iPhone 16 Pro" a specific one
#
# The suite is pure logic — no network, no Supabase, no UI.

set -e
cd "$(dirname "$0")/.."

DEVICE="${1:-}"
if [ -z "$DEVICE" ]; then
    DEVICE=$(xcrun simctl list devices available | grep -oE "iPhone [0-9]+( Pro| Plus| Pro Max)?" | head -1)
fi

if [ -z "$DEVICE" ]; then
    echo "No iPhone simulator available — open Xcode once to install one."
    exit 1
fi

echo "Testing on $DEVICE"
xcodebuild test \
    -project AppSeed.xcodeproj \
    -scheme AppSeed-develop \
    -configuration Develop \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    | grep -E "error:|Executed|TEST SUCCEEDED|TEST FAILED"
