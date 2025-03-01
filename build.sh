#!/bin/bash

format_size_kb() {
  local size_bytes=$1
  printf "%.2f" $(bc <<< "scale=2; $size_bytes/1024")
}

build() {
  export EMSDK_SYSROOT=$EMSDK/upstream/emscripten/cache/sysroot

  export SWIFT_TOOLCHAIN=/Library/Developer/Toolchains/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-02-21-a.xctoolchain

  export JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM=true 

  $SWIFT_TOOLCHAIN/usr/bin/swift build -c release --product EmbeddedApp \
    --triple wasm32-unknown-none-wasm \
    -Xswiftc -I -Xswiftc ${EMSDK_SYSROOT}/include \
    -Xlinker -L -Xlinker ${EMSDK_SYSROOT}/lib/wasm32-emscripten \
    --sdk ${EMSDK_SYSROOT} 

  if [ ! -d Bundle ]; then
    mkdir Bundle
  fi

  if [ ! -f Bundle/index.mjs ]; then
    cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.mjs Bundle/index.mjs  
  fi

  if [ -f Bundle/app.wasm ]; then
    rm Bundle/app.wasm
  fi

  if ! command -v wasm-opt &> /dev/null; then
    cp .build/release/EmbeddedApp.wasm Bundle/app.wasm
  else
    wasm-opt -O3 .build/release/EmbeddedApp.wasm -o Bundle/app.wasm
    original_size=$(stat -f %z .build/release/EmbeddedApp.wasm)
    optimized_size=$(stat -f %z Bundle/app.wasm)
    
    echo "🔧 WASM size: Original: $(format_size_kb $original_size)KB, Optimized: $(format_size_kb $optimized_size)KB"

  fi
}

install_emsdk() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  EMSDK_DIR="$SCRIPT_DIR/emsdk"

  if [ ! -d "$EMSDK_DIR" ]; then
      echo "Cloning emsdk repository..."
      git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"

      cd "$EMSDK_DIR"
      echo "Installing latest version of emsdk..."
      ./emsdk install latest
      echo "Activating latest version..."
      ./emsdk activate latest
      source "emsdk_env.sh"
      cd ..
  else
    if [ ! -n $EMSDK ]; then
      cd "$EMSDK_DIR"
      source "$EMSDK_DIR/emsdk_env.sh"
      cd ..
    else
      echo "✅ Emsdk already installed"
    fi
  fi
}

install_emsdk
build