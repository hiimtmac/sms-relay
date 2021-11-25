#!/bin/sh

set -eu

executable="Relay"

docker run \
    --rm \
    --volume "$(pwd)/:/src" \
    --workdir "/src/" \
    swift:5.5-amazonlinux2 \
    swift build --product "$executable" -c release -Xswiftc -static-stdlib

target=".build/lambda/$executable"
rm -rf "$target"
mkdir -p "$target"
cp ".build/release/$executable" "$target/"
cd "$target"
ln -s "$executable" "bootstrap"
zip --symlinks lambda.zip *
cp lambda.zip ../../../
