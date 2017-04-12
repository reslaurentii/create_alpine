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
wget -nc -a log -i fileslist.txt 
echo "verify image"
gpg2 --verify alpine*asc 2>>log

if [ ! $? -eq 0 ]  
then
	echo "Something went wrong!. View log file"
	exit 1
fi
name=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 1)
version=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 3)
arch=$(ls alpine-minirootfs-3.5.2-x86.tar.gz | cut -d - -f 4 | cut -d . -f 1)

mv alpine-minirootfs-*x86.tar.gz alpine-minirootfs.tar.gz 2>>log
echo "LABEL alpine_version=""\""$name"-"$version"-"$arch"\"" >> Dockerfile


docker build -t alpine_builder . | tee -a 2> log

if [ ! $? -eq 0 ]  
then
	echo "Something went wrong!. View log file"
	exit 1
fi
echo "Clean all" 
rm alpine-miniroo*
git checkout -- Dockerfile
exit 0
