#!/bin/bash

os=$1

mkdir -p /tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')
export CCACHE_DIR=/data/ccache

tar -xJf /data/release/$os/python39.tar.xz -C /tools
tar -xJf /data/release/$os/cmake-3.25.0.tar.xz -C /tools
export PATH=/tools/python39/bin:/tools/cmake-3.25.0/bin:$PATH
export LD_LIBRARY_PATH=/tools/python39/lib

# klayout
cd /data/src/klayout
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build
QMAKE_CCACHE=1 ./build.sh -qt5 -release -build build -prefix /tools/klayout-$tag -j2
rm -rf build
tar -cJf /data/release/$os/klayout-$tag.tar.xz -C /tools klayout-$tag

if [[ "$os" == "centos" ]]
then
	source /opt/rh/devtoolset-11/enable
fi

# lemon
cd /data/src/lemon
tag=$d
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tools/lemon-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/lemon-$tag.tar.xz -C /tools lemon-$tag
INSTALL_LEMON=/tools/lemon-$tag

# spdlog
cd /data/src/spdlog
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tools/spdlog-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/spdlog-$tag.tar.xz -C /tools spdlog-$tag
INSTALL_SPDLOG=/tools/spdlog-$tag

# eigen
cd /data/src/eigen
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tools/eigen-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/eigen-$tag.tar.xz -C /tools eigen-$tag
INSTALL_EIGEN=/tools/eigen-$tag

# or-tools
cd /data/src/or-tools
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
cmake -S. -Bbuild_$os -DBUILD_DEPS:BOOL=ON \
	-DCMAKE_INSTALL_PREFIX=/tools/or-tools-$tag -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
cmake --build build_$os
cmake --build build_$os --target install
tar -cJf /data/release/$os/or-tools-$tag.tar.xz -C /tools or-tools-$tag
INSTALL_ORTOOLS=/tools/or-tools-$tag

# OpenROAD
cd /data/src/OpenROAD
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
if [[ "$os" == "openeuler" ]]
then
	cmake .. -DCMAKE_INSTALL_PREFIX=/tools/OpenROAD-$tag -DCMAKE_BUILD_TYPE=RELEASE \
		-Dspdlog_ROOT=$INSTALL_SPDLOG -DLEMON_ROOT=$INSTALL_LEMON -DEigen3_ROOT=$INSTALL_EIGEN \
		-DCMAKE_PREFIX_PATH=$INSTALL_ORTOOLS/lib/cmake \
		-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
elif [[ "$os" == "centos" ]]
then
	cmake .. -DCMAKE_INSTALL_PREFIX=/tools/OpenROAD-$d -DCMAKE_BUILD_TYPE=RELEASE \
		-Dspdlog_ROOT=$INSTALL_SPDLOG -DLEMON_ROOT=$INSTALL_LEMON -DEigen3_ROOT=$INSTALL_EIGEN \
		-DCMAKE_PREFIX_PATH="$INSTALL_ORTOOLS/lib64/cmake;$INSTALL_ORTOOLS/lib/cmake" \
		-DBOOST_INCLUDEDIR=/usr/include/boost169 -DBOOST_LIBRARYDIR=/usr/lib64/boost169 \
		-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
fi
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/OpenROAD-$tag.tar.xz -C /tools OpenROAD-$tag

# magic
cd /data/src/magic
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/magic-$tag --with-x
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/magic-$tag.tar.xz -C /tools magic-$tag
INSTALL_MAGIC=/tools/magic-$tag

# netgen
cd /data/src/netgen
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/netgen-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/netgen-$tag.tar.xz -C /tools netgen-$tag
INSTALL_NETGEN=/tools/netgen-$tag

# padring
cd /data/src/padring
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
cmake .. -G Ninja -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
ninja && mkdir -p /tools/padring-$tag/bin && install padring /tools/padring-$tag/bin
cd .. && rm -rf build
tar -cJf /data/release/$os/padring-$tag.tar.xz -C /tools padring-$tag

# qrouter
cd /data/src/qrouter
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/qrouter-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/qrouter-$tag.tar.xz -C /tools qrouter-$tag
INSTALL_QROUTER=/tools/qrouter-$tag

# graywolf
cd /data/src/graywolf
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tools/graywolf-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/graywolf-$tag.tar.xz -C /tools graywolf-$tag
INSTALL_GRAYWOLF=/tools/graywolf-$tag

# yosys
cd /data/src/yosys
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
tag=${tag//yosys-/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
make clean
make config-gcc
make PREFIX=/tools/yosys-$tag -j2
make PREFIX=/tools/yosys-$tag install
make clean
tar -cJf /data/release/$os/yosys-$tag.tar.xz -C /tools yosys-$tag
INSTALL_YOSYS=/tools/yosys-$tag

# cvc
cd /data/src/cvc
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
autoreconf -vif
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/cvc-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/cvc-$tag.tar.xz -C /tools cvc-$tag

# qflow
cd /data/src/qflow
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
export PATH=$PATH:$INSTALL_YOSYS/bin:$INSTALL_GRAYWOLF/bin:$INSTALL_QROUTER/bin
export PATH=$PATH:$INSTALL_MAGIC/bin:$INSTALL_NETGEN/bin
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/qflow-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/qflow-$tag.tar.xz -C /tools qflow-$tag

# OpenLane
cd /data/src/OpenLane
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
mkdir -p /tools/OpenLane-$tag/install
python3 -m venv --clear /tools/OpenLane-$tag/install/venv
source /tools/OpenLane-$tag/install/venv/bin/activate
pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple --upgrade pip volare
pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/precompile_time.txt
pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/compile_time.txt
pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/run_time.txt
deactivate
rsync -az scripts /tools/OpenLane-$tag/
rsync -az flow.tcl /tools/OpenLane-$tag/
rsync -az configuration /tools/OpenLane-$tag/
echo 'set OL_INSTALL_DIR [file dirname [file normalize [info script]]]' > /tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(OPENLANE_LOCAL_INSTALL) 1'                             >> /tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(OL_INSTALL_DIR) "$OL_INSTALL_DIR"'                     >> /tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(PATH) "$OL_INSTALL_DIR/venv/bin:$OL_INSTALL_DIR/bin:$::env(PATH)"' >> /tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(VIRTUAL_ENV) "$OL_INSTALL_DIR/venv"'                   >> /tools/OpenLane-$tag/install/env.tcl
tar -cJf /data/release/$os/OpenLane-$tag.tar.xz -C /tools OpenLane-$tag

# gtkwave
cd /data/src/gtkwave/gtkwave3-gtk3
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [[ "$tag" == "nightly" ]]; then tag=$d; fi
./autogen.sh && CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/gtkwave-$tag --enable-gtk3
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/gtkwave-$tag.tar.xz -C /tools gtkwave-$tag

# iverilog
cd /data/src/iverilog
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
sh autoconf.sh && CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/iverilog-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/iverilog-$tag.tar.xz -C /tools iverilog-$tag

# verilator
cd /data/src/verilator
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
autoconf && ./configure --prefix /tools/verilator-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/verilator-$tag.tar.xz -C /tools verilator-$tag

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

# cleanup
rm -rf /tools

