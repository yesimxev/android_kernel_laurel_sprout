#!/bin/bash

###
### Use toolchain https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/16012023/neutron-clang-16012023.tar.zst
### Extract to $HOME/android/toolchains/neutron-clang
###

# Define colors
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
DEFAULT="\e[0m"

# Define variables
CLANG_VER="clang-r498229b"
ROM_PATH="/mnt/QuickBoi/LineageOS/21"

# Check if CLANG_DIR exists, if not try alternative paths
if [ -d "$ROM_PATH/prebuilts/clang/host/linux-x86/$CLANG_VER" ]; then
    CLANG_DIR="$ROM_PATH/prebuilts/clang/host/linux-x86/$CLANG_VER"
elif [ -d "$HOME/android/toolchains/neutron-clang" ]; then
    CLANG_DIR="$HOME/android/toolchains/neutron-clang"
else
    echo -e "${RED}Could not find the specified clang directory.${DEFAULT}"
    exit 1
fi

echo -e "${YELLOW}Using clang directory: $CLANG_DIR${DEFAULT}"


KERNEL_DIR=$PWD
Anykernel_DIR=$KERNEL_DIR/AnyKernel3/
DATE=$(date +"[%d%m%Y]")
TIME=$(date +"%H.%M.%S")
KERNEL_NAME="yesimxev"
DEVICE="laurel_sprout"
FINAL_ZIP="$KERNEL_NAME"-"$DEVICE"-"$DATE"

BUILD_START=$(date +"%s")

# Export variables
export TARGET_KERNEL_CLANG_COMPILE=true
PATH="$CLANG_DIR/bin:${PATH}"

echo -e "${CYAN}***********************************************${DEFAULT}"
echo -e "${CYAN}        Compiling NetHunter Kernel             ${DEFAULT}"
echo -e "${CYAN}***********************************************${DEFAULT}"

# Finally build it
mkdir -p out
export ARCH=arm64
#let it continue building, don't always start from scratch
#make mrproper
if [[ -f arch/arm64/configs/nethunter_defconfig ]]; then make O=out ARCH=arm64 nethunter_defconfig; else
make O=out ARCH=arm64 vendor/laurel_sprout-perf_defconfig;fi
make O=out ARCH=arm64 menuconfig
cp out/.config arch/arm64/configs/nethunter_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$CLANG_DIR/bin/llvm- LLVM=1 LLVM_IAS=1 Image.gz-dtb dtbo.img || exit

# Build complete
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "${GREEN}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.${DEFAULT}"
