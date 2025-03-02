#!/bin/bash

format_size_kb() {
  local size_bytes=$1
  printf "%.2f" $(bc <<< "scale=2; $size_bytes/1024")
}

prepare_bundle() {
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

build_wasi() {
  SWIFTWASM_SDK=6.0.3-RELEASE-wasm32-unknown-wasi
  export TOOLCHAIN_NAME=swift-wasm-6.0.3-RELEASE.xctoolchain
  export SWIFT_TOOLCHAIN=/Library/Developer/Toolchains/$TOOLCHAIN_NAME

  $SWIFT_TOOLCHAIN/usr/bin/swift build -c release --product EmbeddedApp \
  --swift-sdk $SWIFTWASM_SDK \
  --static-swift-stdlib -Xswiftc -Xclang-linker -Xswiftc -mexec-model=reactor \
    -Xlinker --export=__main_argc_argv
}

build_embedded_emsdk() {

  if [ ! -n $EMSDK ]; then
    echo "❌ Emsdk not installed"
    exit 1
  fi

  export TOOLCHAIN_NAME=swift-6.1-DEVELOPMENT-SNAPSHOT-2025-02-21-a.xctoolchain
  export EMSDK_SYSROOT=$EMSDK/upstream/emscripten/cache/sysroot
  export SWIFT_TOOLCHAIN=/Library/Developer/Toolchains/$TOOLCHAIN_NAME
  export JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM=true 

  $SWIFT_TOOLCHAIN/usr/bin/swift build -c release --product EmbeddedApp \
    --triple wasm32-unknown-none-wasm \
    -Xswiftc -I -Xswiftc ${EMSDK_SYSROOT}/include \
    -Xlinker -L -Xlinker ${EMSDK_SYSROOT}/lib/wasm32-emscripten \
    --sdk ${EMSDK_SYSROOT} 

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

serve() {
  if command -v npx &> /dev/null; then
    npx serve Bundle
  elif command -v python3 &> /dev/null; then
    (cd Bundle && python3 -m http.server 3000)
  else
    echo "❌ Neither npx serve nor python3 is available. Please install either Node.js or Python3."
    exit 1
  fi
}



case "${1:-all}" in
  "emsdk")
    install_emsdk
    build_embedded_emsdk
    prepare_bundle
    ;;
  "wasi")
    build_wasi
    prepare_bundle
    ;;
  "serve")
    serve
    ;;
  *)
    echo "Usage: $0 [emsdk|wasi|serve]"
    echo "  emsdk: Install emsdk and build with emscripten and prepare bundle"
    echo "  wasi:  Build with wasi and prepare bundle"
    echo "  serve: Serve the bundle"
    exit 1
    ;;
esac
