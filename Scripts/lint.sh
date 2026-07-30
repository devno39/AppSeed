#!/bin/bash
# Runs SwiftLint against .swiftlint.yml at the repo root.
#   Scripts/lint.sh          lint only
#   Scripts/lint.sh --fix    apply the auto-fixable rules first, then lint
#
# The repo is kept at zero violations, so anything reported here is new.
# Install: brew install swiftlint

set -e
cd "$(dirname "$0")/.."

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "swiftlint not installed — brew install swiftlint"
    exit 1
fi

if [ "$1" == "--fix" ]; then
    swiftlint --fix --quiet
fi

swiftlint lint --quiet
echo "SwiftLint: clean"
