#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# or-tools
cd /data/src/or-tools
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/or-tools-$tag
cmake -S. -Bbuild -DBUILD_DEPS:BOOL=ON \
	-DCMAKE_INSTALL_PREFIX=/data/tools/or-tools-$tag -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
cmake --build build
cmake --build build --target install
export INSTALL_ORTOOLS=/data/tools/or-tools-$tag

# OpenROAD
cd /data/src/OpenROAD
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/OpenROAD-$tag
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/data/tools/OpenROAD-$tag -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_PREFIX_PATH=$INSTALL_ORTOOLS/lib/cmake \
	-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make
make install

# OpenLane
cd /data/src/OpenLane
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/OpenLane-$tag
mkdir -p /data/tools/OpenLane-$tag/install
python3 -m venv --clear /data/tools/OpenLane-$tag/install/venv
source /data/tools/OpenLane-$tag/install/venv/bin/activate
pip3 install --trusted-host mirrors.cloud.tencent.com -i http://mirrors.cloud.tencent.com/pypi/simple --upgrade pip volare
pip3 install --trusted-host mirrors.cloud.tencent.com -i http://mirrors.cloud.tencent.com/pypi/simple -r dependencies/python/precompile_time.txt
pip3 install --trusted-host mirrors.cloud.tencent.com -i http://mirrors.cloud.tencent.com/pypi/simple -r dependencies/python/compile_time.txt
pip3 install --trusted-host mirrors.cloud.tencent.com -i http://mirrors.cloud.tencent.com/pypi/simple -r dependencies/python/run_time.txt
deactivate
rsync -az flow.tcl /data/tools/OpenLane-$tag/
rsync -az scripts /data/tools/OpenLane-$tag/
rsync -az configuration /data/tools/OpenLane-$tag/
echo 'set OL_INSTALL_DIR [file dirname [file normalize [info script]]]' > /data/tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(OPENLANE_LOCAL_INSTALL) 1'                             >> /data/tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(OL_INSTALL_DIR) "$OL_INSTALL_DIR"'                     >> /data/tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(PATH) "$OL_INSTALL_DIR/venv/bin:$OL_INSTALL_DIR/bin:$::env(PATH)"' >> /data/tools/OpenLane-$tag/install/env.tcl
echo 'set ::env(VIRTUAL_ENV) "$OL_INSTALL_DIR/venv"'                   >> /data/tools/OpenLane-$tag/install/env.tcl

# yosys
cd /data/src/yosys
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
tag=${tag//yosys-/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
make config-gcc
make PREFIX=/data/tools/yosys-$tag
make PREFIX=/data/tools/yosys-$tag install

# ngspice
cd /data/src/ngspice
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//\^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/ngspice-$tag
./autogen.sh --adms
mkdir -p build && cd build
../configure --prefix=/data/tools/ngspice-$tag --with-x --enable-xspice \
	--enable-cider --with-readline=yes --enable-openmp --enable-adms \
	--disable-debug
#CFLAGS="-m64 -O2" LDFLAGS="-m64 -s"
make
make install

