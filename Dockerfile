FROM lanfanb/client7:2022.06.21.XiaZhi
RUN cd ; \
GOVERSION=1.18.3 ; \
GIVERSION=2.34.3 ; \
SIVERSION=3.10.0 ; \
cd && wget -q https://go.dev/dl/go${GOVERSION}.linux-amd64.tar.gz ; \
tar -xzf go${GOVERSION}.linux-amd64.tar.gz && chown root:root go -R && mv go /opt ; \
export PATH=/opt/go/bin:$PATH ; \
cd && git clone --depth 1 --branch v${GIVERSION} https://github.com/git/git.git ; \
cd git && make -j2 prefix=/opt/git all install ; \
export PATH=/opt/git/bin:$PATH ; \
cd && git clone --depth 1 --branch v${SIVERSION} https://github.com/sylabs/singularity.git ; \
cd singularity && git submodule update --init --recursive --depth 1 ; \
./mconfig --without-suid --prefix=/opt/singularity && make -j2 -C builddir && make -j2 -C builddir install ; \
cd /opt && tar -cJvf /singularity.tar.xz singularity ; \
cd && rm -rf * && rm -rf /opt/*
CMD ["/usr/sbin/init"]
