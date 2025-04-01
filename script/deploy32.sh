#!/bin/bash
mkdir -p ../buildx86
mkdir -p ../bin
rm ../build
ln -sf buildx86 ../build
git pull
git submodule update --init
docker run  -e USER_ID=000 -v $PWD/../:/home/project -w /home/project -it fffaraz/qt:win32s-qt5 script/build32.sh || echo hi
pwd
cd ..

cp build/release/project.exe /userdata/download/loopeditor.exe
