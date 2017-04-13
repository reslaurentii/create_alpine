# Alpine docker 32bits image created from scratch

Root file system was taken from https://www.alpinelinux.org/downloads/

The Root file system was signed by "Natanael Copa<ncopa@alpinelinux.org>"
(His public key and his digest is available on https://www.alpinelinux.org/downloads/)

to create image

```
./create_alpine32bit.sh
```
- imageAddress.txt: list of file to download. (rootfs, gpg sign and sha256sum hash)
- log: all standard and error output (It is overwritten every time script is launched)
- Dockerfile: is created every time script is launched
