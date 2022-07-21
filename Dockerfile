FROM lanfanb/client7:2022.07.21
RUN yum upgrade -y ; \
yum clean all
CMD ["/usr/sbin/init"]
