#!/bin/sh
# dSYM upload template. Xcode Cloud does not upload dSYMs to Crashlytics on its
# own; this is Firebase's documented ci_post_xcodebuild hook for that gap.
#
# The upload lines are commented out until Firebase Crashlytics is actually wired
# into the app (Crashlytics run script + GoogleService-Info.plist present). Enable
# when Firebase Crashlytics is wired: uncomment the block and set the -gsp path to
# the app's GoogleService-Info.plist.
if [ -n "$CI_ARCHIVE_PATH" ]; then
    echo "Archive produced at $CI_ARCHIVE_PATH."
    # "$CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
    #     -gsp "$CI_PRIMARY_REPOSITORY_PATH/AppSeed/Resources/GoogleService-Info.plist" \
    #     -p ios "$CI_ARCHIVE_PATH/dSYMs"
else
    echo "No archive produced (action: $CI_XCODEBUILD_ACTION); skipping dSYM upload."
fi
