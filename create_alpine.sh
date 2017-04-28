#!/bin/bash
#

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
dockerfile="Dockerfile"
repofile="x86_64_alpine.lst"
stop="NO"
arch="x86_64"
logfile="log"

function show_help {
	echo -e "create_alpine [options]"
	echo -e "\t-a x86|x86_64\tchoose architecture (default x86_64)"
	echo -e "\t-f <file name>\tname of generated Dockerfile (default Dockerfile)"
	echo -e "\t-d \tgenerate only Dockerfile"
	echo -e "\t-h show this help"
}
function no_docker_image {
	echo "Warning: Due to -d option, script stops here. None docker image has been created." | tee -a $logfile
	echo "END "$(date -Ins) | tee -a $logfile
	exit 0
}
while getopts "h:?:a:f:d" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    a)  arch=$OPTARG
        ;;
    f)  dockerfile=$OPTARG
        ;;
    d)  stop="YES"
        ;;
    esac
done
shift $((OPTIND-1))

[ "$1" = "--" ] && shift

case "$arch" in
	x86)
	repofile="x86_alpine.lst"
	;;
	x86_64)
	;;
	*)
	echo "Not valid or supported architecture!"
	echo "Only x86 and x86_64 are valid values!"
	show_help
	;;
esac

keyserver="pgp.mit.edu"
keyid="0482D84022F52DF1C4E7CD43293ACD0907D9495A"

function error {
	tput setaf 1
	echo "Opsss... something went wrong! View log file"  | tee -a $logfile
	exit 1
	tput sgr0
}
echo "START "$(date -Ins)| tee $logfile
echo "import public key from "$keyserver  | tee -a $logfile
gpg2 --keyserver  $keyserver --recv $keyid 2>>$logfile
[ ! $? -eq 0 ] && error

###############################################################################
# download roofs
echo "get image from alpinelinux.org" | tee -a $logfile
wget -nc -a $logfile -i $repofile
echo "verify image with sha256 digest"  | tee -a $logfile
sha256sum -c alpine*sha256* 2>>$logfile
[ ! $? -eq 0 ] && error
echo "verify image with gpg2"  | tee -a $logfile
gpg2 --verify alpine*asc 2>>$logfile
[ ! $? -eq 0 ] && error


name=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 1)
version=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 3)
arch=$(ls alpine-minirootfs-*.tar.gz | cut -d - -f 4 | cut -d . -f 1)

mv alpine-minirootfs-*.tar.gz alpine-minirootfs.tar.gz 2>>$logfile

###############################################################################
# Create Dockerfile
[[ -s $dockerfile ]] && rm $dockerfile
echo "Create $dockerfile"  | tee -a $logfile
echo | tee -a $logfile
tput setaf 5
tput setab 3
echo "#######################################################"     | tee -a $dockerfile $logfile
echo "# Alpine Linux "$version" with "$arch "architecture"         | tee -a $dockerfile $logfile
echo "#######################################################"     | tee -a $dockerfile $logfile
echo "FROM scratch"                                                | tee -a $dockerfile $logfile
echo "LABEL maintainer=\"Lorenzo Lobba <lorenzo@lobba.it>\" \\"    | tee -a $dockerfile $logfile
echo "source_rootfs=\"https://www.alpinelinux.org/downloads/\" \\" | tee -a $dockerfile $logfile
echo "alpine_version=""\""$name"-"$version"-"$arch"\""             | tee -a $dockerfile $logfile
echo "ADD alpine-minirootfs.tar.gz /"                              | tee -a $dockerfile $logfile
echo "################### END FILE ###########################"    | tee -a $dockerfile $logfile
tput sgr0
echo $dockerfile" was created!" | tee -a $logfile
echo | tee -a $logfile
[ $stop == "YES" ] && no_docker_image

buildName=$name.$version.$arch
echo "Create "$buildName" image:"| tee -a $logfile
tput setaf 4
docker build -t $buildName -f $dockerfile . | tee -a 2>&1 $logfile
tput sgr0
[ ! $? -eq 0 ] && error

echo "remove downloads"  | tee -a $logfile
rm alpine-minirootfs*
echo "END "$(date -Ins) | tee -a $logfile
tput bel
exit 0
