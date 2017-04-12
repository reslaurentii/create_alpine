#!/bin/bash

echo "import public key"
gpg2 --keyserver pgp.mit.edu --recv 0482D84022F52DF1C4E7CD43293ACD0907D9495A 2>log

if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"
	echo "prima"
	exit 1
fi
echo "get image from alpinelinux.org"
wget -nc -a log -i imageAddress.txt
echo "verify image"
gpg2 --verify alpine*asc 2>>log
if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"
	exit 1
fi
sha256sum alpine*sha256* 2>>log
if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"
	exit 1
fi

name=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 1)
version=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 3)
arch=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 4 | cut -d . -f 1)

mv alpine-minirootfs-*x86.tar.gz alpine-minirootfs.tar.gz 2>>log


echo "#######################################################" > Dockerfile
echo "# Alpine Linux with 32 bit (i386) architecture" >> Dockerfile
echo "#######################################################" >> Dockerfile
echo "FROM scratch" >> Dockerfile
echo "LABEL maintainer=\"Lorenzo Lobba <lorenzo@lobba.it>\" \\" >> Dockerfile
echo "        source_rootfs=\"https://www.alpinelinux.org/downloads/\" \\" >> Dockerfile
echo "        alpine_version=""\""$name"-"$version"-"$arch"\"" >> Dockerfile
echo "ADD alpine-minirootfs.tar.gz /">> Dockerfile

docker build -t alpine_builder . | tee -a 2>&1 log

if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"
	exit 1
fi
echo "remove downloads"
rm alpine-minirootfs*
exit 0
