FROM docker.io/lanfanb/siqbase:openeuler.latest
RUN cd / ; \
git clone https://github.com/KLayout/klayout.git --branch v0.27.10 --depth 1 ; \
cd /klayout ; \
sed -i.bak '/-Wsign-promo/d' ./src/klayout.pri ; \
./build.sh -qt5 -release -build build -prefix /tools/klayout-0.27.10 -j2 ; \
tar -cJf /klayout-0.27.10.tar.xz -C /tools klayout-0.27.10 ; \
rm -rf /tools /klayout
CMD ["/usr/sbin/init"]
