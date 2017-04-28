# Alpine docker 32bits image created from scratch

Root file system was taken from https://www.alpinelinux.org/downloads/

The Root file system was signed by "Natanael Copa<ncopa@alpinelinux.org>"
(His public key and his digest is available on https://www.alpinelinux.org/downloads/)

to create Dockerfile and image

```
./create_alpinebit.sh [-a [x86|x86_64]] | [-f <file name>] | [-d] 
```
The default values are 
architecture: x86_64
file: Dockerfile

Script takes rootfs from repository, creates Dockerfile and creates Docker images.
With -d option script doesn't create Docker images.

Warning: If you don't use dockerfile default name, take clean manually working directory. 

