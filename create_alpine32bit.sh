#!/bin/bash

echo "import public key"  | tee -a log
gpg2 --keyserver pgp.mit.edu --recv 0482D84022F52DF1C4E7CD43293ACD0907D9495A 2>log

if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"  | tee -a log
	exit 1
fi
###############################################################################
# download roofs
echo "get image from alpinelinux.org" | tee -a log
wget -nc -a log -i rootfsLink.txt
echo "verify image with gpg2"  | tee -a log
gpg2 --verify alpine*asc 2>>log
if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"  | tee -a log
	exit 1
fi
sha256sum alpine*sha256* 2>>log
if [ ! $? -eq 0 ]
then
	echo "Something went wrong!. View log file"  | tee -a log
	exit 1
fi

name=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 1)
version=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 3)
arch=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 4 | cut -d . -f 1)

mv alpine-minirootfs-*x86.tar.gz alpine-minirootfs.tar.gz 2>>log

###############################################################################
# Create Dockerfile
echo "Create Dockerfile"  | tee -a log

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
	echo "Something went wrong!. View log file"  | tee -a log
	exit 1
fi
echo "remove downloads"  | tee -a log
rm alpine-minirootfs*
echo "END" | tee -a log
exit 0
