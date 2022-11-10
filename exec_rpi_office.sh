#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# LibreOffice
cd /data/office/LibreOffice
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
mkdir -p build && cd build
../autogen.sh --with-parallelism=1 --with-help --with-lang="en-US zh-CN"
make
rm -rf /data/tools/LibreOffice-CollaboraOnline-$tag
mkdir -p /data/tools/LibreOffice-CollaboraOnline-$tag
rsync -azL include /data/tools/LibreOffice-CollaboraOnline-$tag/
rsync -azL instdir /data/tools/LibreOffice-CollaboraOnline-$tag/
LO_PATH=/data/tools/LibreOffice-CollaboraOnline-$tag

# CollaboraOnline
cd /data/office/CollaboraOnline
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
./autogen.sh
CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/ --enable-silent-rules \
	--with-lokit-path=$LO_PATH/include --with-lo-path=$LO_PATH/instdir \
	--enable-cypress --with-dictionaries="en_US zh_CN" --with-user-id=pi
sed -i "s/npm install/npm install --build-from-source/" Makefile
export http_proxy=socks5://127.0.0.1:1080
export https_proxy=socks5://127.0.0.1:1080
make
rm -rf /data/tools/CollaboraOnline-$tag
DESTDIR=/data/tools/CollaboraOnline-$tag make install
cd /data/tools/CollaboraOnline-$tag/bin
sudo /sbin/setcap cap_fowner,cap_chown,cap_mknod,cap_sys_chroot=ep coolforkit
sudo /sbin/setcap cap_sys_admin=ep coolmount

