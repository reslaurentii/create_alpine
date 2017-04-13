#!/bin/bash
#
keyserver="pgp.mit.edu"
keyid="0482D84022F52DF1C4E7CD43293ACD0907D9495A"

function error {
	tput setaf 1
	echo "Opsss... something went wrong! View log file"  | tee -a log
	exit 1
	tput sgr0
}
echo "START "$(date -Ins)| tee log
echo "import public key from "$keyserver  | tee -a log
gpg2 --keyserver  $keyserver --recv $keyid 2>>log
[ ! $? -eq 0 ] && error

###############################################################################
# download roofs
echo "get image from alpinelinux.org" | tee -a log
wget -nc -a log -i rootfsLink.txt
echo "verify image with sha256 digest"  | tee -a log
sha256sum -c alpine*sha256* 2>>log
[ ! $? -eq 0 ] && error
echo "verify image with gpg2"  | tee -a log
gpg2 --verify alpine*asc 2>>log
[ ! $? -eq 0 ] && error


name=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 1)
version=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 3)
arch=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 4 | cut -d . -f 1)

mv alpine-minirootfs-*x86.tar.gz alpine-minirootfs.tar.gz 2>>log

###############################################################################
# Create Dockerfile
[[ -s Dockerfile ]] && rm Dockerfile
echo "Create Dockerfile"  | tee -a log
echo | tee -a log
tput setaf 5
tput setab 3
echo "#######################################################" | tee -a Dockerfile log
echo "# Alpine Linux with 32 bit (i386) architecture" | tee -a Dockerfile log
echo "#######################################################"| tee -a Dockerfile log
echo "FROM scratch"| tee -a Dockerfile -a log
echo "LABEL maintainer=\"Lorenzo Lobba <lorenzo@lobba.it>\" \\" | tee -a Dockerfile log
echo "        source_rootfs=\"https://www.alpinelinux.org/downloads/\" \\" | tee -a Dockerfile log
echo "        alpine_version=""\""$name"-"$version"-"$arch"\"" | tee -a Dockerfile log
echo "ADD alpine-minirootfs.tar.gz /"| tee -a Dockerfile log
echo "################### END FILE ###########################"| tee -a Dockerfile log
tput sgr0
echo | tee -a log
buildName=$name.$version.$arch
echo "Create "$buildName" image:"| tee -a log
tput setaf 4
docker build -t $buildName . | tee -a 2>&1 log
tput sgr0
[ ! $? -eq 0 ] && error

echo "remove downloads"  | tee -a log
rm alpine-minirootfs*
echo "END "$(date -Ins) | tee -a log
tput bel
exit 0
