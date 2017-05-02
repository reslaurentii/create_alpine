# Script to create Alpine docker images from scratch

Script takes the original and ufficial Root file System from https://www.alpinelinux.org/downloads/, creates Dockerfile and the Docker image.
The script creates only dockerfile and docker image: It doesn't modify any file of root file system.

The Root file system used by script it is the one signed by "Natanael Copa\<ncopa@alpinelinux.org\>"
(His public key and his digest are available on https://www.alpinelinux.org/downloads/)

## Description
The script makes these steps:
1. import Natanael Copa public key
2. take root file system from alpinelinux.org (tar.gz form)
3. take sha256 digest and check root file system
4. take file signature  and check root file system
5. Generate Dockerfile
6. run Docker build with generated Dockerfile
7. Delete files taken from alpineLinux. Dockerfile is not deleted.

## Requirements
1. A standard Linux distribution (Debian, Fedora, ...)
2. gpg o gpg2
3. wget
4. Docker (However the part of the script calling docker command can be skipped.)

## Howto execute script
To create Dockerfile and image

```
./create_alpinebit.sh
```
It works with default paramaters.

To show help online
```
./create_alpine -h
create_alpine [options] [arguments]
        -m <Dockerfile maintainer>      Name of Dockerfile maintener
        -r <root file system version>   Root File System Version.
        -a x86|x86_64                   Choose architecture (default x86_64).
        -f <file name>                  Name of generated Dockerfile (default Dockerfile).
        -d                              Generate only Dockerfile and don't delete download files.
        -q                              Quiet. No message to standard output.
        -h                              Show this help.
```
## Parameters description
### Parameters with arguments
The default values are:
- -m maintener of Dockerfile. It is a label of dockerfile.It is a string. (Names Surname <email>)
- -r alpine root file system version: 3.5.2
- -a architecture: x86_64
- -f Dockerfile name: Dockerfile

### Parameters without arguments
- -d Don't execute steps 6 and 7. Script doesn't remove files and create docker image.
- -q Execute without any message to standard output (For scripts)
- -h show help

### Use script according your needs
- edit configure file
- use script parameters
