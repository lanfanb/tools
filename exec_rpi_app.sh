#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# bubblewrap
cd /data/src/bubblewrap
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/bwrap-$tag
CC="ccache gcc" CXX="ccache g++" ./autogen.sh --prefix=/data/tools/bwrap-$tag \
	--disable-man
make
make install

# flatpak
cd /data/src/flatpak
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
rm -rf /data/tools/flatpak-$tag
CC="ccache gcc" CXX="ccache g++" ./autogen.sh --prefix=/data/tools/flatpak-$tag \
	--disable-selinux-module --disable-documentation
make
make install

