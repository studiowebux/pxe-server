# create the container to host the backend.
FROM centos:latest

WORKDIR /

# Install the prerequisites for the systemctl support
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install the prerequisites for the PXE server
RUN yum update -y
RUN yum install tftp tftp-server syslinux wget vsftpd xinetd -y
RUN sed -i -e 's|/var/lib/tftpboot|/tftpboot|' /etc/xinetd.d/tftp
RUN sed -i '/disable\>/s/\<yes\>/no/' /etc/xinetd.d/tftp
RUN mkdir -p /tftpboot
RUN chmod 777 /tftpboot
RUN cp -v /usr/share/syslinux/pxelinux.0 /tftpboot
RUN cp -v /usr/share/syslinux/menu.c32 /tftpboot
RUN cp -v /usr/share/syslinux/memdisk /tftpboot
RUN cp -v /usr/share/syslinux/mboot.c32 /tftpboot
RUN cp -v /usr/share/syslinux/chain.c32 /tftpboot
RUN mkdir /tftpboot/pxelinux.cfg
RUN mkdir -p /tftpboot/netboot/
RUN echo 'no_anon_password=YES' >> /etc/vsftpd/vsftpd.conf
RUN echo 'port_enable=YES' >> /etc/vsftpd/vsftpd.conf
RUN echo 'port_enable=YES' >> /etc/vsftpd/vsftpd.conf
RUN echo 'pasv_min_port=33333' >> /etc/vsftpd/vsftpd.conf
RUN echo 'pasv_max_port=33343' >> /etc/vsftpd/vsftpd.conf
RUN echo 'ftpd_banner=Welcome to Studio Webux FTP.' >> /etc/vsftpd/vsftpd.conf
RUN systemctl enable xinetd
RUN systemctl enable vsftpd

VOLUME [ "/tftpboot/netboot", "/tftpboot/pxelinux.cfg/", "/var/ftp/pub", "/sys/fs/cgroup" ]

EXPOSE 68/udp
EXPOSE 68/tcp
EXPOSE 67/udp
EXPOSE 67/tcp
EXPOSE 69/udp
EXPOSE 4011/udp
EXPOSE 21/tcp
EXPOSE 20/tcp
EXPOSE 33333-33343

CMD ["/usr/sbin/init"]