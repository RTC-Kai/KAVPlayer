#!/usr/bin/env bash
ROOT_DIR=$(dirname "$(readlink -f "$0")")
OUTPUT_DIR=$ROOT_DIR/out
BUILD_DIR=$ROOT_DIR/build
THIRD_PARTY_DIR=$ROOT_DIR/third_party
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)
HOST_TYPE="$OS_TYPE-$ARCH_TYPE"

echo "host=$HOST_TYPE"

# install base dependencies
if [ "$OS_TYPE" = "Darwin" ]; then  
    brew install gcc openssl@3 pkg-config unzip
else
    apt install gcc openssl@3 pkg-config unzip tar
fi

# build third party
mkdir -p $OUTPUT_DIR $BUILD_DIR $THIRD_PARTY_DIR

# 1 sdl2
sdl2_build(){
    mkdir -p $THIRD_PARTY_DIR/sdl2
    wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.7.zip -P $BUILD_DIR
    unzip $BUILD_DIR/release-2.30.7.zip -d $BUILD_DIR
    cmake -S $BUILD_DIR/SDL-release-2.30.7 -B $BUILD_DIR/SDL-release-2.30.7/build -DCMAKE_SYSTEM_NAME=$OS_TYPE -DCMAKE_OSX_ARCHITECTURES=$ARCH_TYPE 
    cmake --build $BUILD_DIR/SDL-release-2.30.7/build 
    
    cp -f $BUILD_DIR/SDL-release-2.30.7/build/libSDL2.a $THIRD_PARTY_DIR/sdl2/libsdl2.a
    cp -rf $BUILD_DIR/SDL-release-2.30.7/include $THIRD_PARTY_DIR/sdl2
}
if ! [ -f "$THIRD_PARTY_DIR/sdl2/libsdl2.a" ]; then  
    echo "sdl building"
    sdl2_build  
fi

# 2 json download
json_build(){
    wget https://github.com/nlohmann/json/archive/refs/tags/v3.11.3.zip -P $BUILD_DIR
    unzip $BUILD_DIR/v3.11.3.zip -d $BUILD_DIR
    
    mv -f $BUILD_DIR/json-3.11.3 $THIRD_PARTY_DIR/json
}
if ! [ -d "$THIRD_PARTY_DIR/json" ]; then  
    echo "json downloading"
    json_build  
fi

# 3 gtest build
gtest_build(){
    mkdir -p $THIRD_PARTY_DIR/gtest
    wget https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip -P $BUILD_DIR
    unzip $BUILD_DIR/v1.15.2.zip -d $BUILD_DIR

    cmake -S $BUILD_DIR/googletest-1.15.2 -B $BUILD_DIR/googletest-1.15.2/build -DCMAKE_SYSTEM_NAME=$OS_TYPE -DCMAKE_OSX_ARCHITECTURES=$ARCH_TYPE 
    cmake --build $BUILD_DIR/googletest-1.15.2/build 

    cp -f $BUILD_DIR/googletest-1.15.2/build/lib/libgtest.a $THIRD_PARTY_DIR/gtest/
    cp -f $BUILD_DIR/googletest-1.15.2/build/lib/libgmock.a $THIRD_PARTY_DIR/gtest/
    cp -rf $BUILD_DIR/googletest-1.15.2/googlemock/include/gmock $THIRD_PARTY_DIR/gtest/include
    cp -rf $BUILD_DIR/googletest-1.15.2/googletest/include/gtest $THIRD_PARTY_DIR/gtest/include
}
if ! [ -f "$THIRD_PARTY_DIR/gtest/libgtest.a" ]; then  
    echo "gtest building"
    gtest_build  
fi

rm -rf $BUILD_DIR

# build lvc
# cd $OUTPUT_DIR
# cmake .. -DCMAKE_BUILD_TYPE=Debug
