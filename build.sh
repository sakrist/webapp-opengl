#!/bin/bash

BUILD_TYPE=release
# if debug
if [ ! -z "$DEBUG" ]; then
  BUILD_TYPE=debug
fi

export TOOLCHAIN_NAME=swift-6.1-RELEASE.xctoolchain
export SWIFT_TOOLCHAIN=/Library/Developer/Toolchains/$TOOLCHAIN_NAME

# find toolchain in /Library/Developer/Toolchains or ~/Library/Developer/Toolchains
if [ ! -d "$SWIFT_TOOLCHAIN" ]; then
  if [ ! -d "$HOME/Library/Developer/Toolchains/$TOOLCHAIN_NAME" ]; then
    echo "❌ Toolchain not found"
    exit 1
  else
    SWIFT_TOOLCHAIN="$HOME/Library/Developer/Toolchains/$TOOLCHAIN_NAME"
  fi
fi



format_size_kb() {
  local size_bytes=$1
  printf "%.2f" $(bc <<< "scale=2; $size_bytes/1024")
}

prepare_bundle() {
  if [ ! -d Bundle ]; then
    mkdir Bundle
  fi

  if [ ! -f Bundle/runtime.js ]; then
    cp .build/checkouts/JavaScriptKit/Sources/JavaScriptKit/Runtime/index.mjs Bundle/runtime.js  
  fi

  if [ -f Bundle/app.wasm ]; then
    rm Bundle/app.wasm
  fi

  if [ ! command -v wasm-opt &> /dev/null ] || [ "$BUILD_TYPE" = "debug" ]; then
    cp .build/debug/App.wasm Bundle/app.wasm
  else
    wasm-opt -O3 .build/release/App.wasm -o Bundle/app.wasm
    original_size=$(stat -f %z .build/release/App.wasm)
    optimized_size=$(stat -f %z Bundle/app.wasm)
    
    echo "🔧 WASM size: Original: $(format_size_kb $original_size)KB, Optimized: $(format_size_kb $optimized_size)KB"
  fi
}

build_wasi() {
  SWIFTWASM_SDK=6.1-RELEASE-wasm32-unknown-wasi

  $SWIFT_TOOLCHAIN/usr/bin/swift build -c $BUILD_TYPE --product App \
  --swift-sdk $SWIFTWASM_SDK \
  --static-swift-stdlib -Xswiftc -Xclang-linker -Xswiftc -mexec-model=reactor \
    -Xlinker --export=__main_argc_argv

  if [ $? -eq 0 ]; then
    prepare_bundle
  else
    echo "❌ Build failed"
    exit 1
  fi
}

build_embedded_emsdk() {

  if [ ! -n $EMSDK ]; then
    echo "❌ Emsdk not installed"
    exit 1
  fi

  export EMSDK_SYSROOT=$EMSDK/upstream/emscripten/cache/sysroot
  export JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM=true 

  $SWIFT_TOOLCHAIN/usr/bin/swift build -c $BUILD_TYPE --product App \
    --triple wasm32-unknown-none-wasm \
    -Xswiftc -I -Xswiftc ${EMSDK_SYSROOT}/include \
    -Xlinker -L -Xlinker ${EMSDK_SYSROOT}/lib/wasm32-emscripten \
    --sdk ${EMSDK_SYSROOT} 

  if [ $? -eq 0 ]; then
    prepare_bundle
  else
    echo "❌ Build failed"
    exit 1
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
    if [ -z $EMSDK ]; then
      cd "$EMSDK_DIR"
      source "$EMSDK_DIR/emsdk_env.sh" > /dev/null 2>&1
      cd ..
      echo "✅ EMSDK activated"
    else
      echo "✅ EMSDK already installed"
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

clean() {
  if [ -d ".build" ]; then
    echo "🧹 Cleaning .build directory..."
    rm -rf .build
  else
    echo "✅ Nothing to clean"
  fi
}

case "${1:-all}" in
  "emsdk")
    install_emsdk
    build_embedded_emsdk
    ;;
  "wasi")
    build_wasi
    ;;
  "serve")
    serve
    ;;
  "clean")
    clean
    ;;
  *)
    echo "Usage: $0 [emsdk|wasi|serve|clean]"
    echo "  emsdk: Install emsdk and build with emscripten and prepare bundle"
    echo "  wasi:  Build with wasi and prepare bundle"
    echo "  serve: Serve the bundle"
    echo "  clean: Remove the .build directory"
    exit 1
    ;;
esac
