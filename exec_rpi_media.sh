#!/bin/bash

mkdir -p /data/tools

export TZ="Asia/Shanghai"
export d=$(date +'%Y.%m.%d')

# ffmpeg
cd /data/src/ffmpeg
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
mkdir -p build && cd build
../configure --cc="ccache gcc" --cxx="ccache g++" --prefix=/data/tools/ffmpeg-$tag \
	--toolchain=hardened --enable-gpl --enable-version3 --enable-nonfree --enable-gnutls \
	--enable-ladspa --enable-libaom --enable-libass --enable-libbluray --enable-libbs2b \
	--enable-libcaca --enable-libcdio --enable-libcodec2 --enable-libdav1d --enable-libflite \
	--enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme \
	--enable-libgsm --enable-libjack --enable-libmp3lame --enable-libmysofa --enable-libopenjpeg \
	--enable-libopenmpt --enable-libopus --enable-libpulse --enable-librabbitmq --enable-librsvg \
	--enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr \
	--enable-libspeex --enable-libsrt --enable-libssh --enable-libtheora --enable-libtwolame \
	--enable-libvidstab --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx265 \
	--enable-libxml2 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-lv2 --enable-omx \
	--enable-openal --enable-opencl --enable-opengl --enable-sdl2 --enable-neon --arch=arm64 \
	--enable-pocketsphinx --enable-libdc1394 --enable-libdrm --enable-chromaprint --enable-frei0r \
	--enable-libx264 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gmp \
	--enable-libfdk-aac --enable-librtmp --enable-pthreads --enable-hardcoded-tables --target-os=linux
make
make install

exit

# opencv
cd /data/src/opencv
tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
tag=${tag//v/}
tag=${tag//^0/}
if [[ "$tag" == "undefined" ]]; then tag=$d; fi
mkdir -p build && cd build
cmake -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache \
	-DCMAKE_BUILD_TYPE=Release -DPYTHON3_EXECUTABLE=/usr/bin/python \
	-DOPENCV_EXTRA_MODULES_PATH=/data/src/opencv/opencv_contrib/modules \
	../opencv

