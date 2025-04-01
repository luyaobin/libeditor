#!/bin/bash
rm /userdata/download/software.*
rm ../bin/res -r
rm ../bin/*
mkdir -p ../buildx86
rm ../build
ln -sf buildx86 ../build
git pull
git submodule update --init
docker run  -e USER_ID=000 -v $PWD/../:/home/project -w /home/project -it fffaraz/qt:win64s-qt5 script/build.sh || echo hi
pwd
cd ..
cp bin/software.exe /userdata/download || echo hi
cp res/gl/* bin/ || echo hi
mkdir bin/res || echo hi
cp res/subprocess/* bin/res || echo hi
#touch bin/debug
zip -rqy software.zip bin/software.exe bin/res/* bin/*.dll || echo hi
mv software.zip /userdata/download || echo hi
zip -rqy software.exe.zip bin/software.exe || echo hi
mv software.exe.zip /userdata/download || echo hi
