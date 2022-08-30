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
make -j2 && make install ; \
cd .. && rm -rf build
tar -cJf /data/release/$os/OpenROAD-$tag.tar.xz -C /tools OpenROAD-$tag

# magic
cd /data/src/magic ; \
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
./configure --prefix=/tools/magic-$tag --with-x ; \
make clean && make -j2 && make install && make clean ; \
tar -cJf /data/release/$os/magic-$tag.tar.xz -C /tools magic-$tag

#cd /data/src/netgen ; \
#./configure --prefix=/tools/netgen-1.5.227 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/padring && rm -rf build && mkdir build && cd build ; \
#cmake -G Ninja .. ; \
#ninja && mkdir -p /tools/padring-$d/bin && install padring /tools/padring-$d/bin ; \
#cd /data/src/qrouter ; \
#./configure --prefix=/tools/qrouter-1.4.85 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/graywolf && rm -rf build && mkdir build && cd build ; \
#cmake .. -DCMAKE_INSTALL_PREFIX=/tools/graywolf-$d ; \
#make -j2 && make install ; \
#cd /data/src/yosys ; \
#make clean && make config-gcc && make PREFIX=/tools/yosys-0.20 -j2 && make PREFIX=/tools/yosys-0.20 install ; \
#cd /data/src/cvc && autoreconf -vif ; \
#./configure --prefix=/tools/cvc-1.1.3 ; \
#make clean && make -j2 && make install ; \
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
#tar -cJf /data/release/openeuler/netgen-1.5.227.tar.xz  -C /tools netgen-1.5.227  ; \
#tar -cJf /data/release/openeuler/padring-$d.tar.xz      -C /tools padring-$d      ; \
#tar -cJf /data/release/openeuler/qrouter-1.4.85.tar.xz  -C /tools qrouter-1.4.85  ; \
#tar -cJf /data/release/openeuler/graywolf-$d.tar.xz     -C /tools graywolf-$d     ; \
#tar -cJf /data/release/openeuler/yosys-0.20.tar.xz      -C /tools yosys-0.20      ; \
#tar -cJf /data/release/openeuler/cvc-1.1.3.tar.xz       -C /tools cvc-1.1.3       ; \
#tar -cJf /data/release/openeuler/qflow-1.4.98.tar.xz    -C /tools qflow-1.4.98    ; \
#tar -cJf /data/release/openeuler/OpenLane-$d.tar.xz     -C /tools OpenLane-$d     ; \
#tar -cJf /data/release/openeuler/gtkwave-$d.tar.xz      -C /tools gtkwave-$d      ; \
#tar -cJf /data/release/openeuler/iverilog-$d.tar.xz     -C /tools iverilog-$d     ; \
#tar -cJf /data/release/openeuler/verilator-$d.tar.xz    -C /tools verilator-$d    ; \
#tar -cJf /data/release/openeuler/spike-$d.tar.xz        -C /tools spike-$d        ; \

#cd /data/src/netgen ; \
#./configure --prefix=/tools/netgen-1.5.227 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/padring && rm -rf build && mkdir build && cd build ; \
#cmake3 -G Ninja .. ; \
#ninja && mkdir -p /tools/padring-$d/bin && install padring /tools/padring-$d/bin ; \
#cd /data/src/qrouter ; \
#./configure --prefix=/tools/qrouter-1.4.85 ; \
#make clean && make -j2 && make install ; \
#cd /data/src/graywolf && rm -rf build && mkdir build && cd build ; \
#cmake3 .. -DCMAKE_INSTALL_PREFIX=/tools/graywolf-$d ; \
#make -j2 && make install ; \
#cd /data/src/git ; \
#make clean ; \
#make prefix=/tools/git-2.37.1 all ; \
#make prefix=/tools/git-2.37.1 install ; \
#cd /data/src/bison && ./bootstrap ; \
#cd /data/src/bison-3.8.2 ; \
#./configure --prefix=/tools/bison-3.8.2 ; \
#make clean && make -j2 && make install ; \
#export OLDPATH=$PATH ; \
#export PATH=/tools/git-2.37.1/bin:$PATH ; \
#cd /data/src/yosys ; \
#make clean && make config-gcc && make PREFIX=/tools/yosys-0.20 && make PREFIX=/tools/yosys-0.20 install ; \
#export PATH=$OLDPATH ; \
#export PATH=/tools/bison-3.8.2/bin:$PATH ; \
#cd /data/src/cvc && autoreconf -vif ; \
#./configure --prefix=/tools/cvc-1.1.3 ; \
#make clean && make -j2 && make install ; \
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
#tar -cJf /data/release/centos/netgen-1.5.227.tar.xz  -C /tools netgen-1.5.227  ; \
#tar -cJf /data/release/centos/padring-$d.tar.xz      -C /tools padring-$d      ; \
#tar -cJf /data/release/centos/qrouter-1.4.85.tar.xz  -C /tools qrouter-1.4.85  ; \
#tar -cJf /data/release/centos/graywolf-$d.tar.xz     -C /tools graywolf-$d     ; \
#tar -cJf /data/release/centos/git-2.37.1.tar.xz      -C /tools git-2.37.1      ; \
#tar -cJf /data/release/centos/bison-3.8.2.tar.xz     -C /tools bison-3.8.2     ; \
#tar -cJf /data/release/centos/yosys-0.20.tar.xz      -C /tools yosys-0.20      ; \
#tar -cJf /data/release/centos/cvc-1.1.3.tar.xz       -C /tools cvc-1.1.3       ; \
#tar -cJf /data/release/centos/qflow-1.4.98.tar.xz    -C /tools qflow-1.4.98    ; \
#tar -cJf /data/release/centos/OpenLane-$d.tar.xz     -C /tools OpenLane-$d     ; \
#tar -cJf /data/release/centos/gtkwave-$d.tar.xz      -C /tools gtkwave-$d      ; \
#tar -cJf /data/release/centos/iverilog-$d.tar.xz     -C /tools iverilog-$d     ; \
#tar -cJf /data/release/centos/verilator-$d.tar.xz    -C /tools verilator-$d    ; \
#tar -cJf /data/release/centos/zlib-1.2.12.tar.xz     -C /tools zlib-1.2.12     ; \
#tar -cJf /data/release/centos/qemu-riscv64-7.0.0.tar.xz -C /tools qemu-riscv64-7.0.0 ; \
#tar -cJf /data/release/centos/spike-$d.tar.xz        -C /tools spike-$d        ; \

rm -rf /tools

