#!/bin/bash

echo "😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄"
echo "===============================Start======================================"
echo "😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄"

IPHONE_SDKVERSION=$(echo $(xcodebuild -showsdks) | grep -o 'iphonesimulator[0-9]\+.[0-9]\+' | grep -o '[0-9]\+.[0-9]\+')

XCODE_ROOT=$(xcode-select -print-path)
XCODE_SIMULATOR=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer
XCODE_DEVICE=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer

XCODE_SIMULATOR_SDK=$XCODE_SIMULATOR/SDKs/iPhoneSimulator$IPHONE_SDKVERSION.sdk
XCODE_DEVICE_SDK=$XCODE_DEVICE/SDKs/iPhoneOS$IPHONE_SDKVERSION.sdk
XCODE_TOOLCHAIN_USR_BIN=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/
XCODE_USR_BIN=$XCODE_ROOT/usr/bin/

ORIGINAL_PATH=$PATH

SRC_DIR=$(pwd)
BUILD_ARCHS="armv7s armv7 arm64 i386 x86_64"

echo "$SRC_DIR"
echo "$IPHONE_SDKVERSION"
echo "$XCODE_ROOT"
echo "$XCODE_SIMULATOR"
echo "$XCODE_DEVICE"
echo "$XCODE_SIMULATOR_SDK"
echo "$XCODE_DEVICE_SDK"
echo "$XCODE_TOOLCHAIN_USR_BIN"
echo "$XCODE_USR_BIN"
echo "$BUILD_ARCHS"

exportConfig() {
    IOS_ARCH=$1
    if [ "$IOS_ARCH" == "i386" ] || [ "$IOS_ARCH" == "x86_64" ]; then
        IOS_SYSROOT=$XCODE_SIMULATOR_SDK
    else
        IOS_SYSROOT=$XCODE_DEVICE_SDK
    fi
    CFLAGS="-arch $IOS_ARCH -fPIC -g -Os -pipe --sysroot=$IOS_SYSROOT"
    if [ "$IOS_ARCH" == "armv7s" ] || [ "$IOS_ARCH" == "armv7" ]; then
        CFLAGS="$CFLAGS -mios-version-min=6.0"
    else
        CFLAGS="$CFLAGS -fembed-bitcode -mios-version-min=7.0"
    fi
    CXXFLAGS=$CFLAGS
    CPPFLAGS=$CFLAGS
    CC_FOR_BUILD=/usr/bin/clang
    export CC=clang
    export CXX=clang++
    export CFLAGS
    export CXXFLAGS
    export IOS_SYSROOT
    export CC_FOR_BUILD
    export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
    echo "IOS_ARC: $IOS_ARCH"
    echo "CC: $CC"
    echo "CXX: $CXX"
    echo "LDFLAGS: $LDFLAGS"
    echo "CC_FOR_BUILD: $CC_FOR_BUILD"
    echo "CFLAGS: $CFLAGS"
    echo "CXXFLAGS: $CXXFLAGS"
    echo "IOS_SYSROOT: $IOS_SYSROOT"
    echo "PATH: $PATH"
}

compileSrcForArch() {
    buildArch=$1
    temp_dir="${buildArch}_build"
    full_path="${SRC_DIR}/${temp_dir}"

    ./autogen.sh
    ./configure --prefix "${full_path}" --disable-shared --host="none-apple-darwin" --enable-static --disable-assembly --enable-module-recovery
    make clean
    make check
    make install
    mv "${full_path}"/lib/libsecp256k1.a "${full_path}"
}

buildUniversalLib() {
    xcrun -sdk iphoneos lipo \
        -create \
        -arch armv7 "${SRC_DIR}/armv7_build/libsecp256k1.a" \
        -arch armv7s "${SRC_DIR}/armv7s_build/libsecp256k1.a" \
        -arch i386 "${SRC_DIR}/i386_build/libsecp256k1.a" \
        -arch x86_64 "${SRC_DIR}/x86_64_build/libsecp256k1.a" \
        -arch arm64 "${SRC_DIR}/arm64_build/libsecp256k1.a" \
        -o "${SRC_DIR}/Sources/libsecp256k1.a" ||
        abort "lipo failed"
}

rm -rf Submodules/*
rm -rf Sources
rm -rf .gitmodules
mkdir -p Sources
touch .gitmodules

cat >.gitmodules <<EOF
[submodule "Submodules/bitcoin-core-secp256k1"]
	path = Submodules/bitcoin-core-secp256k1
	url = https://github.com/bitcoin-core/secp256k1.git
EOF

for buildArch in $BUILD_ARCHS; do
    temp_dir="${buildArch}_build"
    full_path="${SRC_DIR}/${temp_dir}"
    rm -rf "$full_path"
done

git submodule update

cd Submodules/bitcoin-core-secp256k1 || exit

for buildArch in $BUILD_ARCHS; do
    exportConfig "$buildArch"
    compileSrcForArch "$buildArch"
done

buildUniversalLib

cp -r "${SRC_DIR}"/arm64_build/include/*.h "${SRC_DIR}"/Sources

echo "😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄"
