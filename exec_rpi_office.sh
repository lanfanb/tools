#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# LibreOffice
cd /data/office/LibreOffice
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD^1))
tag=${tag//v/}
tag=${tag//^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [ -d "/data/tools/LibreOffice-CollaboraOnline-$tag" ]
then
	echo "/data/tools/LibreOffice-CollaboraOnline-$tag exists. Skipping."
else
	mkdir -p build && cd build
	../autogen.sh --with-parallelism=1 --with-help --with-lang="en-US zh-CN"
	make
	mkdir -p /data/tools/LibreOffice-CollaboraOnline-$tag
	rsync -azL include /data/tools/LibreOffice-CollaboraOnline-$tag/
	rsync -azL instdir /data/tools/LibreOffice-CollaboraOnline-$tag/
fi
LO_PATH=/data/tools/LibreOffice-CollaboraOnline-$tag

# CollaboraOnline
cd /data/office/CollaboraOnline
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
if [ -d "/data/tools/CollaboraOnline-$tag" ]
then
	echo "/data/tools/CollaboraOnline-$tag exists. Skipping."
else
	./autogen.sh
	CC="ccache gcc" CXX="ccache g++" ./configure --prefix=/data/tools/CollaboraOnline-$tag \
		--enable-silent-rules --enable-cypress --with-dictionaries="en_US zh_CN" \
		--with-lokit-path=$LO_PATH/include --with-lo-path=$LO_PATH/instdir \
		--with-user-id=pi
	sed -i "s/npm install/npm install --build-from-source/" Makefile
	export http_proxy=socks5://127.0.0.1:1080
	export https_proxy=socks5://127.0.0.1:1080
	make
	make install
	cd /data/tools/CollaboraOnline-$tag/bin
	sudo /sbin/setcap cap_fowner,cap_chown,cap_mknod,cap_sys_chroot=ep coolforkit
	sudo /sbin/setcap cap_sys_admin=ep coolmount
	./coolwsd-systemplate-setup ../systemplate $LO_PATH/instdir
	ln -sfv ../share/coolwsd/* .
fi

