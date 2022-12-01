#!/bin/bash

os=$1

mkdir -p /tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')
export CCACHE_DIR=/data/ccache
if [[ "$os" == "centos" ]]
then
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
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
../bootstrap --prefix=/tools/cmake-$tag --enable-ccache
make -j2
make install
cd ..
rm -rf build
tar -cJf /data/release/$os/cmake-$tag.tar.xz -C /tools cmake-$tag

# zlib
cd /data/src/zlib
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [[ "$os" == "centos" ]]
then
	CC="ccache gcc" CXX="ccache g++" CFLAGS=-fPIC ./configure --prefix=/tools/zlib-$tag
	make clean && make -j2 && make install && make clean
	tar -cJf /data/release/$os/zlib-$tag.tar.xz -C /tools zlib-$tag
fi

# autoconf
cd /data/src/gnu/autoconf
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
cd /data/src/gnu/autoconf-2.71
tag=2.71
if [[ "$os" == "centos" ]]
then
	CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/autoconf-$tag
	make clean && make -j2 && make install && make clean
	tar -cJf /data/release/$os/autoconf-$tag.tar.xz -C /tools autoconf-$tag
	export PATH=/tools/autoconf-$tag/bin:$PATH
fi

# automake
cd /data/src/gnu/automake
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
cd /data/src/gnu/automake-1.16.5
tag=1.16.5
if [[ "$os" == "centos" ]]
then
	CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/automake-$tag
	make clean && make -j2 && make install && make clean
	tar -cJf /data/release/$os/automake-$tag.tar.xz -C /tools automake-$tag
	export PATH=/tools/automake-$tag/bin:$PATH
fi

# bison
cd /data/src/gnu/bison
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [[ "$os" == "centos" ]]
then
	./bootstrap
	CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/bison-$tag
	make clean && make -j2 && make install && make clean
	tar -cJf /data/release/$os/bison-$tag.tar.xz -C /tools bison-$tag
	export PATH=/tools/bison-$tag/bin:$PATH
fi

# cleanup
rm -rf /tools

