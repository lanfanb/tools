#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# git
cd /data/src/git
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^*/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
CC="ccache gcc" CXX="ccache g++" make prefix=/data/tools/git-$tag all
CC="ccache gcc" CXX="ccache g++" make prefix=/data/tools/git-$tag install

