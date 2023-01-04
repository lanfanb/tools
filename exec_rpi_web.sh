#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# WebKit
cd /data/WebKit
tag=$d
#sudo swapon /data/file8GB.swap
export http_proxy=http://127.0.0.1:1081
export https_proxy=http://127.0.0.1:1081
export WEBKIT_JHBUILD=1
export PKG_CONFIG_PATH=/data/tools/libcroco/lib/pkgconfig
export PATH=$PATH:/usr/lib/aarch64-linux-gnu/gdk-pixbuf-2.0
Tools/Scripts/update-webkitgtk-libs
#Tools/Scripts/build-webkit --gtk
#Tools/Scripts/run-minibrowser --gtk
#sudo swapoff /data/file8GB.swap

