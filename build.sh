#!/bin/bash
#
TC_DIR="$(pwd)/tc/clang-r487747c"
DEFCONFIG="ocean_defconfig"

export PATH="$TC_DIR/bin:$PATH"

if ! [ -d "$TC_DIR" ]; then
  echo "AOSP clang not found! Cloning to $TC_DIR..."
  if ! git clone --depth=1 -b 17 https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone "$TC_DIR"; then
    echo "Cloning failed! Aborting..."
    exit 1
  fi
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
  rm -rf out
fi

# KSU
rm -rf KernelSU && curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 Image.gz

kernel="out/arch/arm64/boot/Image.gz"
