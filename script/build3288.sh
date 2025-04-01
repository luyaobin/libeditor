#!/bin/bash
mkdir -p ../build3288
rm ../build
ln -sf build3288 ../build
git pull
git submodule update --init

CPU_CHIP="3288"
if [[ "$CPU_CHIP" = "3288" ]]; then
    CPU_SPEC="linux-arm-gnueabihf-g++"
    GNU_BUILD="arm-buildroot-linux-gnueabihf"
else
    CPU_SPEC="linux-aarch64-gnu-g++"
    GNU_BUILD="aarch64-buildroot-linux-gnu"
fi
CPU_SPEC=${CPU_SPEC}
CPU_SYSROOT=${GNU_BUILD}
#sudo apt-get install gcc-arm-linux-gnueabihf
#sudo apt-get install g++-arm-linux-gnueabihf
docker run \
    --rm \
    -e USER_ID=000 \
    -e CPU_CHIP=${CPU_CHIP} \
    -e CPU_SPEC=${CPU_SPEC} \
    -e LD_LIBRARY_PATH=/home/project \
    -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/sysroot/usr/local/qt/bin:/home/cross_compile/bin \
    -v $PWD/../:/home/project \
    -v /nfsroot/cross_compile/host/:/home/cross_compile \
    -v /nfsroot/cross_compile/host/${CPU_SYSROOT}/sysroot/:/home/sysroot \
    -v /nfsroot/cross_compile/qt:/home/sysroot/usr/local/qt \
    -i buildroot-1804-jenkins-base bash -x -c "cd build; qmake ..; make -j6"

pwd
cd ..
#touch bin/debug
#zip -rqy software3288.zip bin/software || echo hi
#mv software3288.zip /userdata/download || echo hi
