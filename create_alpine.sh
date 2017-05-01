#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

source configure

function show_help {
	echo -e "create_alpine [options] [arguments]"
	echo -e "\t-m <Dockerfile maintainer>\tName of Dockerfile maintener"
	echo -e "\t-r <root file system version>\tRoot File System Version."
	echo -e "\t-a x86|x86_64\t\t\tChoose architecture (default x86_64)."
	echo -e "\t-f <file name>\t\t\tName of generated Dockerfile (default Dockerfile)."
	echo -e "\t-d \t\t\t\tGenerate only Dockerfile and don't delete download files."
	echo -e "\t-q \t\t\t\tQuiet. No message to standard output."
	echo -e "\t-h \t\t\t\tShow this help."
}

function error {
	tput setaf 1
	echo "Opsss... something went wrong! View log file"
	tput sgr0
	echo "FAIL! "$(date -Ins)>> $logfile
	exit 1
}

function no_docker_image {
	echo "Warning: Due to -d option, script stops here. None docker image has been created." | tee -a $logfile
}
function bad_arch {
	echo -e $1 "is not a valid or supported architecture!" | tee -a $logfile
	echo "Only x86 and x86_64 are valid values!"| tee -a $logfile
}

function doIt {
	echo "import public key from "$keyserver  | tee -a $logfile
	gpg2 --keyserver  $keyserver --recv $keyid 2>>$logfile
	[ ! $? -eq 0 ] && error

###############################################################################
# download roofs
	echo "get image from alpinelinux.org" | tee -a $logfile
	emv=$(echo $version | awk -F'.' '{print $1"."$2}')
	urlrfs="https://nl.alpinelinux.org/alpine/v"$emv"/releases/"$arch"/alpine-minirootfs-"$version"-"$arch
	for filetype in "tar.gz" "tar.gz.asc" "tar.gz.sha256"; do
		wget -nc -a $logfile $urlrfs.$filetype
	done

	echo "verify image with sha256 digest"  | tee -a $logfile
	echo
	sha256sum -c "alpine-minirootfs-"$version"-"$arch".tar.gz.sha256"  2>>$logfile
	[ ! $? -eq 0 ] && error || echo "Passed"
	echo "verify image with gpg2"  | tee -a $logfile
	gpg2 --verify "alpine-minirootfs-"$version"-"$arch".tar.gz.asc" 2>>$logfile
	[ ! $? -eq 0 ] && error || echo "Passed"

	#mv alpine-minirootfs-*.tar.gz alpine-minirootfs.tar.gz 2>>$logfile

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
	echo "LABEL maintainer=\""$maintainer"\" \\"    | tee -a $dockerfile $logfile
	echo "source_rootfs=\"https://www.alpinelinux.org/downloads/\" \\" | tee -a $dockerfile $logfile
	echo "alpine_version=""\""$name"-"$version"-"$arch"\""             | tee -a $dockerfile $logfile
	echo "ADD alpine-minirootfs-"$version"-"$arch".tar.gz /"           | tee -a $dockerfile $logfile
	echo "################### END FILE ###########################"    | tee -a $dockerfile $logfile
	tput sgr0
	echo $dockerfile" was created!" | tee -a $logfile
	echo | tee -a $logfile
	[ $stop == "YES" ] && return 1

	buildName=$name.$version.$arch
	echo "Create "$buildName" image:"| tee -a $logfile
	tput setaf 4
	docker build -t $buildName -f $dockerfile . | tee -a 2>&1 $logfile
	tput sgr0
	[ ! $? -eq 0 ] && error

	echo "remove downloads"  | tee -a $logfile
	rm alpine-minirootfs*
	tput bel
	return 0
}

echo "START "$(date -Ins)>$logfile
while getopts "h?r:a:f:dqm:" opt; do
	case "$opt" in
		h|\?)
		show_help
		exit 0
		;;
		a) arch=$OPTARG
		;;
		r) version=$OPTARG
		;;
		f) dockerfile=$OPTARG
		;;
		m) maintainer=$OPTARG
		;;
		d) stop="YES"
		;;
		q) quiet="YES"
	esac
done
shift $((OPTIND-1))

[ "$1" = "--" ] && shift

case "$arch" in
	x86|x86_64)
	;;
	*)
	bad_arch $arch
	error
	;;
esac

[ $quiet == "YES" ] && doIt >/dev/null || doIt
[ $? -eq 1 ] && no_docker_image
echo "END "$(date -Ins)>> $logfile

exit 0
