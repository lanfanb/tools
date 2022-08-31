#!/bin/bash

os=$1

mkdir /tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')
export CCACHE_DIR=/data/ccache
if [[ "$os" == "openeuler" ]]
then
	export CMAKE=cmake
elif [[ "$os" == "centos" ]]
then
	export CMAKE=cmake3
fi

# klayout
cd /data/src/klayout
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
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
$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/lemon-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/lemon-$tag.tar.xz -C /tools lemon-$tag
INSTALL_LEMON=/tools/lemon-$tag

# spdlog
cd /data/src/spdlog
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/spdlog-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/spdlog-$tag.tar.xz -C /tools spdlog-$tag
INSTALL_SPDLOG=/tools/spdlog-$tag

# eigen
cd /data/src/eigen
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/eigen-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/eigen-$tag.tar.xz -C /tools eigen-$tag
INSTALL_EIGEN=/tools/eigen-$tag

# OpenROAD
cd /data/src/OpenROAD
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
if [[ "$os" == "openeuler" ]]
then
	$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/OpenROAD-$tag -DCMAKE_BUILD_TYPE=RELEASE \
		-Dspdlog_ROOT=$INSTALL_SPDLOG -DLEMON_ROOT=$INSTALL_LEMON -DEigen3_ROOT=$INSTALL_EIGEN \
		-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
elif [[ "$os" == "centos" ]]
then
	$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/OpenROAD-$d -DCMAKE_BUILD_TYPE=RELEASE \
		-Dspdlog_ROOT=$INSTALL_SPDLOG -DLEMON_ROOT=$INSTALL_LEMON -DEigen3_ROOT=$INSTALL_EIGEN \
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
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/magic-$tag --with-x
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/magic-$tag.tar.xz -C /tools magic-$tag

# netgen
cd /data/src/netgen
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/netgen-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/netgen-$tag.tar.xz -C /tools netgen-$tag

# padring
cd /data/src/padring
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
$CMAKE .. -G Ninja -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
ninja && mkdir -p /tools/padring-$tag/bin && install padring /tools/padring-$tag/bin
cd .. && rm -rf build
tar -cJf /data/release/$os/padring-$tag.tar.xz -C /tools padring-$tag

# qrouter
cd /data/src/qrouter
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/qrouter-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/qrouter-$tag.tar.xz -C /tools qrouter-$tag

# graywolf
cd /data/src/graywolf
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf build && mkdir build && cd build
$CMAKE .. -DCMAKE_INSTALL_PREFIX=/tools/graywolf-$tag -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build
tar -cJf /data/release/$os/graywolf-$tag.tar.xz -C /tools graywolf-$tag

# git
cd /data/src/git
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [[ "$os" == "centos" ]]
then
	make clean
	CC="ccache gcc" CXX="ccache g++" make prefix=/tools/git-$tag all
	CC="ccache gcc" CXX="ccache g++" make prefix=/tools/git-$tag install
	make clean
	tar -cJf /data/release/$os/git-$tag.tar.xz -C /tools git-$tag
	export PATH=/tools/git-$tag/bin:$PATH
fi

# bison
cd /data/src/bison
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
cd /data/src/bison-3.8.2
tag=3.8.2
if [[ "$os" == "centos" ]]
then
	CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/bison-$tag
	make clean && make -j2 && make install && make clean
	tar -cJf /data/release/$os/bison-$tag.tar.xz -C /tools bison-$tag
	export PATH=/tools/bison-$tag/bin:$PATH
fi

# yosys
cd /data/src/yosys
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
tag=${tag//yosys-/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
make clean
CC="ccache gcc" CXX="ccache g++" make config-gcc
CC="ccache gcc" CXX="ccache g++" make PREFIX=/tools/yosys-$tag -j2
make PREFIX=/tools/yosys-$tag install
make clean
tar -cJf /data/release/$os/yosys-$tag.tar.xz -C /tools yosys-$tag

# cvc
cd /data/src/cvc
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
autoreconf -vif
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/tools/cvc-$tag
make clean && make -j2 && make install && make clean
tar -cJf /data/release/$os/cvc-$tag.tar.xz -C /tools cvc-$tag

# qflow
#export OLDPATH=$PATH ; \
#export PATH=$PATH:/tools/yosys-0.20/bin ; \
#export PATH=$PATH:/tools/graywolf-$d/bin ; \
#export PATH=$PATH:/tools/qrouter-1.4.85/bin ; \
#export PATH=$PATH:/tools/magic-8.3.315/bin ; \
#export PATH=$PATH:/tools/netgen-1.5.227/bin ; \
#cd /data/src/qflow ; \
#./configure --prefix=/tools/qflow-1.4.98 ; \
#make clean && make -j2 && make install ; \
#export PATH=$OLDPATH ; \
#cd /data/src/OpenLane ; \
#mkdir -p /tools/OpenLane-$d/install ; \
#python3 -m venv --clear /tools/OpenLane-$d/install/venv ; \
#source /tools/OpenLane-$d/install/venv/bin/activate ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple --upgrade pip volare ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/precompile_time.txt ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/compile_time.txt ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/run_time.txt ; \
#deactivate ; \
#rsync -az scripts /tools/OpenLane-$d/ ; \
#rsync -az flow.tcl /tools/OpenLane-$d/ ; \
#rsync -az configuration /tools/OpenLane-$d/ ; \
#echo 'set OL_INSTALL_DIR [file dirname [file normalize [info script]]]' > /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(OPENLANE_LOCAL_INSTALL) 1'                             >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(OL_INSTALL_DIR) "$OL_INSTALL_DIR"'                     >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(PATH) "$OL_INSTALL_DIR/venv/bin:$OL_INSTALL_DIR/bin:$::env(PATH)"' >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(VIRTUAL_ENV) "$OL_INSTALL_DIR/venv"'                   >> /tools/OpenLane-$d/install/env.tcl ; \
#cd /data/src/gtkwave/gtkwave3-gtk3 ; \
#./autogen.sh && ./configure --prefix=/tools/gtkwave-$d --enable-gtk3 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/iverilog ; \
#sh autoconf.sh && ./configure --prefix=/tools/iverilog-$d ; \
#make clean && make -j2 && make install ; \
#cd /data/src/verilator ; \
#autoconf && ./configure --prefix /tools/verilator-$d ; \
#make clean && make -j2 && make install ; \
#cd /data/src/riscv-gnu-toolchain/spike && rm -rf build && mkdir build && cd build ; \
#../configure --prefix=/tools/spike-$d ; \
#make -j2 && make install ; \
#cd / ; \
#tar -cJf /data/release/openeuler/qflow-1.4.98.tar.xz    -C /tools qflow-1.4.98    ; \
#tar -cJf /data/release/openeuler/OpenLane-$d.tar.xz     -C /tools OpenLane-$d     ; \
#tar -cJf /data/release/openeuler/gtkwave-$d.tar.xz      -C /tools gtkwave-$d      ; \
#tar -cJf /data/release/openeuler/iverilog-$d.tar.xz     -C /tools iverilog-$d     ; \
#tar -cJf /data/release/openeuler/verilator-$d.tar.xz    -C /tools verilator-$d    ; \
#tar -cJf /data/release/openeuler/spike-$d.tar.xz        -C /tools spike-$d        ; \

#export PATH=$OLDPATH ; \
#export OLDPATH=$PATH ; \
#export PATH=$PATH:/tools/yosys-0.20/bin ; \
#export PATH=$PATH:/tools/graywolf-$d/bin ; \
#export PATH=$PATH:/tools/qrouter-1.4.85/bin ; \
#export PATH=$PATH:/tools/magic-8.3.315/bin ; \
#export PATH=$PATH:/tools/netgen-1.5.227/bin ; \
#cd /data/src/qflow ; \
#./configure --prefix=/tools/qflow-1.4.98 ; \
#make clean && make -j2 && make install ; \
#export PATH=$OLDPATH ; \
#cd /data/src/OpenLane ; \
#mkdir -p /tools/OpenLane-$d/install ; \
#python3 -m venv --clear /tools/OpenLane-$d/install/venv ; \
#source /tools/OpenLane-$d/install/venv/bin/activate ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple --upgrade pip volare ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/precompile_time.txt ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/compile_time.txt ; \
#pip3 install --trusted-host mirrors.tencentyun.com -i http://mirrors.tencentyun.com/pypi/simple -r dependencies/python/run_time.txt ; \
#deactivate ; \
#rsync -az scripts /tools/OpenLane-$d/ ; \
#rsync -az flow.tcl /tools/OpenLane-$d/ ; \
#rsync -az configuration /tools/OpenLane-$d/ ; \
#echo 'set OL_INSTALL_DIR [file dirname [file normalize [info script]]]' > /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(OPENLANE_LOCAL_INSTALL) 1'                             >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(OL_INSTALL_DIR) "$OL_INSTALL_DIR"'                     >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(PATH) "$OL_INSTALL_DIR/venv/bin:$OL_INSTALL_DIR/bin:$::env(PATH)"' >> /tools/OpenLane-$d/install/env.tcl ; \
#echo 'set ::env(VIRTUAL_ENV) "$OL_INSTALL_DIR/venv"'                   >> /tools/OpenLane-$d/install/env.tcl ; \
#cd /data/src/gtkwave/gtkwave3-gtk3 ; \
#./autogen.sh && ./configure --prefix=/tools/gtkwave-$d --enable-gtk3 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/iverilog ; \
#sh autoconf.sh && ./configure --prefix=/tools/iverilog-$d ; \
#make clean && make -j2 && make install ; \
#cd /data/src/verilator ; \
#autoconf && ./configure --prefix /tools/verilator-$d ; \
#make clean && make -j2 && make install ; \
#cd /data/src/zlib-1.2.12 ; \
#CFLAGS=-fPIC ./configure --prefix=/tools/zlib-1.2.12 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/qemu && rm -rf build && mkdir build && cd build ; \
#../configure --prefix=/tools/qemu-riscv64-7.0.0 --target-list=riscv64-softmmu,riscv64-linux-user ; \
#make -j2 && make install ; \
#cd /data/src/riscv-gnu-toolchain/spike && rm -rf build && mkdir build && cd build ; \
#../configure --prefix=/tools/spike-$d ; \
#make -j2 && make install ; \
#cd / ; \
#tar -cJf /data/release/centos/qflow-1.4.98.tar.xz    -C /tools qflow-1.4.98    ; \
#tar -cJf /data/release/centos/OpenLane-$d.tar.xz     -C /tools OpenLane-$d     ; \
#tar -cJf /data/release/centos/gtkwave-$d.tar.xz      -C /tools gtkwave-$d      ; \
#tar -cJf /data/release/centos/iverilog-$d.tar.xz     -C /tools iverilog-$d     ; \
#tar -cJf /data/release/centos/verilator-$d.tar.xz    -C /tools verilator-$d    ; \
#tar -cJf /data/release/centos/zlib-1.2.12.tar.xz     -C /tools zlib-1.2.12     ; \
#tar -cJf /data/release/centos/qemu-riscv64-7.0.0.tar.xz -C /tools qemu-riscv64-7.0.0 ; \
#tar -cJf /data/release/centos/spike-$d.tar.xz        -C /tools spike-$d        ; \

rm -rf /tools

