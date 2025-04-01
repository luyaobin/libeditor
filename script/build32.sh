#!/bin/bash
cd build && qmake .. && make -j6 || echo hi
cd .. || echo hi
chmod 777 bin || echo hi
cd bin || echo hi
chmod 777 . || echo hi
