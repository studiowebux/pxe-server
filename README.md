# Webuxlab - PXE Server

This project create a PXE Server for Legacy machine in a docker container.

## Getting Started

This documentation will provide you a working PXE server.

### Prerequisites

- Docker
- Centos or Ubuntu is recommended
- An external DHCP server

```
yum install docker-ce -y
```

### Installing

to build the image,

```
docker build . -t pxe-server:latest
```

you should get an image named pxe-server:latest

You can start the image with this command:
```
docker run -it --name pxe \
-p 21:21 \
-p 67:67/udp \
-p 68:68/udp \
-p 67:67 \
-p 68:68 \
-p 69:69/udp \
-p 4011:4011/udp \
-p 20:20 \
-p 33333-33343:33333-33343 \
-v $PWD/netboot/:/tftpboot/netboot \
-v $PWD/pxelinux.cfg/:/tftpboot/pxelinux.cfg/ \
-v $PWD/pub/:/var/ftp/pub/:ro \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /tmp/$(mktemp -d):/run \
--privileged \
pxe-server:latest
```

## Folder structure
### /tftpboot/netboot
this folder contains the vmlinuz and the initrd

### /tftpboot/pxelinux.cfg
this folder contains the menu entry for the PXE

### /var/ftp/pub
this folder contains the kickstarts and the Images (For now)
the images will be redirected to a dedicated NFS soon.

### Others
/sys/fs/cgroup & /run are defined because systemctl is required and these folders are required.

## Usage Example

On the host,

Download the Centos ISO
```
wget http://mirror2.evolution-host.com/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso
```

Mount the Iso to extract its content
```
sudo mount -o loop CentOS-7-x86_64-Minimal-1810.iso /mnt/
```

Copy the files required to boot
```
sudo cp /mnt/isolinux/{initrd.img,vmlinuz} netboot/
```

Copy the ISO content
```
sudo cp -av * /home/tgingras/pub/images/centos/76/
```

Edit the Menu file
```
nano pxelinux.cfg/default
```

Add this:
```
default menu.c32
prompt 0
timeout 30
MENU TITLE webuxlab

LABEL centos76
MENU LABEL CentOS 7.6
	KERNEL /netboot/centos/76/vmlinuz
	APPEND initrd=/netboot/centos/76/initrd.img inst.repo=ftp://192.168.10.5/pub/images/centos/76 ks=ftp://192.168.10.5/pub/kickstarts/centos/76/ks.cfg
```

Generate an encrypted password
```
openssl passwd -1 myPassword
```

Create a kickstart
```
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL

# Firewall configuration
firewall --disabled

# Install OS instead of upgrade
install

# Use FTP installation media
url --url="ftp://192.168.10.5/pub/images/centos/76"

# Root password
rootpw --iscrypted <encrypted password>

# System authorization information
auth useshadow passalgo=sha512

firstboot disable

# System keyboard
keyboard us

# System language
lang en_US

# SELinux configuration
selinux disabled

# Installation logging level
logging level=info

# System timezone
timezone America/Toronto

# System bootloader configuration
bootloader location=mbr
clearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype xfs --size=300
part pv.01 --size=1 --grow
volgroup root_vg01 pv.01
logvol / --fstype xfs --name=lv_01 --vgname=root_vg01 --size=1 --grow

%packages
@^minimal
@core

%end
%addon com_redhat_kdump --enable --reserve-mb='auto'
%end
```

the folder structure can be defined like you want but you need to update the reference accordingly.

## Running the tests

Create a VM or use a physical machine, setup the boot order to boot with PXE, you should see a menu.

## Contributing

If you have improvements or ideas, you can create pull request.

## Authors

* **Studio Webux S.E.N.C** - *SW* - [studiowebux](https://studiowebux.com)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details