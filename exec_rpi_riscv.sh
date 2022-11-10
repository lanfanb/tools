#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# riscv-gnu-toolchain
cd /data/src/riscv-gnu-toolchain
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
../configure --prefix=/data/tools/riscv-$tag --enable-multilib
make
make linux

