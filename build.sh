#!/bin/bash

for d in openeuler centos
do
	echo "====> $d"
	podman build --security-opt seccomp=unconfined --rm --no-cache -v /data:/data -v /root:/root \
		--logfile=$d.log -t docker.io/lanfanb/siqbase:tools.$d -f Dockerfile.$d .
	podman rmi docker.io/lanfanb/siqbase:tools.$d
done

