# Alpine docker 32bits image created from scratch

Root file system was taken from https://www.alpinelinux.org/downloads/

The Root file system was signed by "Natanael Copa<ncopa@alpinelinux.org>"
(His public key and his digest is available on https://www.alpinelinux.org/downloads/)

to create Dockerfile and image

```
./create_alpinebit.sh [-a x86|x86_64] | 
```
The default is x86_64,i.e. intel 64bit


- log: all standard and error output (It is overwritten every time script is launched)
- Dockerfile: is created every time script is launched
