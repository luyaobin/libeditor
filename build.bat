
@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
mkdir build
cd build
qmake.exe .. -spec win32-msvc "CONFIG+=debug" "CONFIG+=qml_debug" && C:/Qt/Qt5.14.2/Tools/QtCreator/bin/jom.exe qmake_all
cd ..
nodemon --exec "cd build && jom" -e "qml,mjs,cpp,hpp,h" -i "build/*" -i "build/**/*"