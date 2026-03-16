root := justfile_directory()

build:
    cd "{{root}}/CornrCornr" && xcodebuild -project CornrCornr.xcodeproj -scheme CornrCornr -configuration Debug build

run: build
    open ~/Library/Developer/Xcode/DerivedData/CornrCornr-*/Build/Products/Debug/CornrCornr.app

kill:
    pkill -f CornrCornr.app || true

restart: kill run

release:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{root}}/CornrCornr"
    echo "==> Building Release..."
    xcodebuild -project CornrCornr.xcodeproj -scheme CornrCornr -configuration Release clean build
    APP_PATH=$(ls -d ~/Library/Developer/Xcode/DerivedData/CornrCornr-*/Build/Products/Release/CornrCornr.app)
    echo "==> Creating zip for notarization..."
    ditto -c -k --keepParent "$APP_PATH" /tmp/CornrCornr.zip
    echo "==> Submitting for notarization..."
    xcrun notarytool submit /tmp/CornrCornr.zip --keychain-profile "notarytool" --wait
    echo "==> Stapling notarization ticket..."
    xcrun stapler staple "$APP_PATH"
    echo "==> Creating final zip..."
    ditto -c -k --keepParent "$APP_PATH" "{{root}}/CornrCornr.zip"
    rm /tmp/CornrCornr.zip
    echo "==> Done! CornrCornr.zip is in the project root."
