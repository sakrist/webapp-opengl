#!/bin/bash


export SWIFT_TOOLCHAIN=/Library/Developer/Toolchains/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-02-21-a.xctoolchain

export JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM=true 
$SWIFT_TOOLCHAIN/usr/bin/swift build -c release --product EmbeddedApp \
  --triple wasm32-unknown-none-wasm 

if [ ! -f Bundle/index.mjs ]; then
  cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.mjs Bundle/index.mjs  
fi
if [ ! -f Bundle/index.js ]; then
  cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.js Bundle/index.js
fi

if [ -f Bundle/app.wasm ]; then
  rm Bundle/app.wasm
fi

if ! command -v wasm-opt &> /dev/null; then
  cp .build/release/EmbeddedApp.wasm Bundle/app.wasm
else
  wasm-opt -O3 .build/release/EmbeddedApp.wasm -o Bundle/app.wasm
fi

# wasm-opt -O3 .build/release/EmbeddedApp.wasm -o Bundle/app.wasm

