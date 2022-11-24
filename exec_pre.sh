#!/bin/bash

os=$1

mkdir -p /tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')
export CCACHE_DIR=/data/ccache
if [[ "$os" == "openeuler" ]]
then
	export CMAKE=cmake
elif [[ "$os" == "centos" ]]
then
	export CMAKE=cmake3
	source /opt/rh/devtoolset-11/enable
fi

# python
cd /data/src/python
rm -rf build && mkdir build && cd build
CC="ccache gcc" CXX="ccache g++" ../configure --prefix=/tools/python39 --enable-shared --enable-optimizations
make -j2
make install
cd ..
rm -rf build
tar -cJf /data/release/$os/python39.tar.xz -C /tools python39

# cmake
cd /data/src/cmake
rm -rf build && mkdir build && cd build
../bootstrap --prefix=/tools/cmake-3.25.0 --enable-ccache
make -j2
make install
cd ..
rm -rf build
tar -cJf /data/release/$os/cmake-3.25.0.tar.xz -C /tools cmake-3.25.0

# cleanup
rm -rf /tools

