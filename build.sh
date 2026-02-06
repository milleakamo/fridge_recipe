#!/bin/bash
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Installing..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:`pwd`/flutter/bin"
fi
flutter doctor
flutter build web --release --canvas-kit
cp -r build/web/* public/
