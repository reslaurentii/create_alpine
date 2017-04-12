#######################################################
# Alpine Linux with 32 bit (i386) architecture
#######################################################
FROM scratch
LABEL maintainer="Lorenzo Lobba <lorenzo@lobba.it>" \
        description="Alpine 32 bit" \
        source_rootfs="https://www.alpinelinux.org/downloads/"
ADD alpine-minirootfs.tar.gz /
