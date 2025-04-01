#!/bin/bash
docker run  -e USER_ID=000 -v $PWD:/home/project -w /home/project -it fffaraz/qt:win64s-qt5 || echo hi
#eval $(echo ls || echo hello)
