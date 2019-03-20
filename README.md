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

## Running the tests

Create a VM or use a physical machine, setup the boot order to boot with PXE, you should see a menu.

## Contributing

If you have improvments or ideas, you can create pull request.

## Authors

* **Studio Webux S.E.N.C** - *SW* - [studiowebux](https://studiowebux.com)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details