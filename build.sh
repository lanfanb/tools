#!/bin/bash

os=$1

if [[ "$os" == "all" ]]
then
	os_list="openeuler centos debian ubuntu"
else
	os_list=$os
fi

for d in $os_list
do
	echo "====> $d"
	podman build --security-opt seccomp=unconfined --rm --no-cache -v /data:/data -v /root:/root \
		--logfile=$d.log -t docker.io/lanfanb/siqbase:tools.$d -f Dockerfile.$d .
	podman rmi docker.io/lanfanb/siqbase:tools.$d
done

