#!/bin/sh
# On release/X.Y.Z branches, derive MARKETING_VERSION from the branch name — a
# forgotten manual bump otherwise fails ASC's "Prepare Build" step.
case "$CI_BRANCH" in
    release/*)
        VERSION="${CI_BRANCH#release/}"
        sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = ${VERSION};/g" \
            "$CI_PRIMARY_REPOSITORY_PATH/AppSeed.xcodeproj/project.pbxproj"
        echo "MARKETING_VERSION set to ${VERSION} from branch name."
        ;;
    *)
        echo "Not a release branch (${CI_BRANCH:-unknown}); MARKETING_VERSION untouched."
        ;;
esac
