build:
    cd ~/git/personal/cornrCornr/Cornr && xcodebuild -project Cornr.xcodeproj -scheme Cornr -configuration Debug build

run: build
    open ~/Library/Developer/Xcode/DerivedData/Cornr-*/Build/Products/Debug/Cornr.app

kill:
    pkill -f Cornr.app || true

restart: kill run
