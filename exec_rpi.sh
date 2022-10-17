#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# OpenROAD
cd /data/src/OpenROAD
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/OpenROAD-$tag
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/data/tools/OpenROAD-$tag -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache
make -j2 && make install
cd .. && rm -rf build

# OpenLane
cd /data/src/OpenLane
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
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

# LibreOffice
cd /data/src/LibreOffice/core
mkdir -p build && cd build
../autogen.sh --with-parallelism=2
make

# CollaboraOnline
cd /data/src/CollaboraOnline/online
./autogen.sh
CC="ccache gcc" CXX="ccache g++" ./configure --enable-silent-rules \
	--with-lokit-path=/data/src/LibreOffice/core/build/include \
	--with-lo-path=/data/src/LibreOffice/core/build/instdir \
	--enable-cypress --with-user-id=pi
make

# riscv-gnu-toolchain
cd /data/src/riscv-gnu-toolchain
rm -rf build && mkdir build && cd build
../configure --prefix=/data/tools/riscv-2022.10.11 --enable-multilib
make
make linux

# ffmpeg
cd /data/src/ffmpeg
mkdir -p build && cd build
../configure --cc="ccache gcc" --cxx="ccache g++" --arch=arm64 --enable-gmp \
	--enable-gpl --enable-libopencore-amrnb --enable-libopencore-amrwb \
	--enable-libaom --enable-libass --enable-libfreetype --enable-libmp3lame \
	--enable-libdav1d --enable-libdrm --enable-libfdk-aac --target-os=linux \
	--enable-libopus --enable-librtmp --enable-libsnappy --enable-libsoxr \
	--enable-libssh --enable-libvorbis --enable-libvpx --enable-libwebp \
	--enable-libx264 --enable-libx265 --enable-libxml2 --enable-nonfree \
	--enable-version3 --enable-pthreads --enable-openssl \
	--enable-hardcoded-tables
#	--enable-libkvazaar
#	--enable-libzimg
make

# opencv
cd /data/src/opencv
mkdir -p build && cd build
cmake -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache \
	-DCMAKE_BUILD_TYPE=Release -DPYTHON3_EXECUTABLE=/usr/bin/python \
	-DOPENCV_EXTRA_MODULES_PATH=/data/src/opencv/opencv_contrib/modules \
	../opencv

