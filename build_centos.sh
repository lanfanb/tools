#!/bin/bash

for d in centos
do
	echo "====> $d"
	podman build --security-opt seccomp=unconfined --rm --no-cache -v /data:/data -v /root:/root \
		-t docker.io/lanfanb/siqbase:tools.$d -f Dockerfile.$d .
	podman rmi docker.io/lanfanb/siqbase:tools.$d
done

