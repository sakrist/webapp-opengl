#!/bin/bash

export JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM=true 
/Library/Developer/Toolchains/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-02-21-a.xctoolchain/usr/bin/swift build -c release --product EmbeddedApp \
  --triple wasm32-unknown-none-wasm 

if [ ! -f Bundle/index.mjs ]; then
  cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.mjs Bundle/index.mjs  
fi
if [ ! -f Bundle/index.js ]; then
  cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.js Bundle/index.js
fi
cp .build/release/EmbeddedApp.wasm Bundle/app.wasm