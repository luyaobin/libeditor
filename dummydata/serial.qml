import "./callcom/serial.mjs" as Serial
import Qt.labs.settings 1.0
import QtQuick 2.14
import qmlcpplib.qmlserial 1.0

Item {
    property Timer timer
    property int timeout: 1000
    property Settings settings
    property alias probeListModel: probeListModel

    ListModel {
        id: probeListModel
    }

    QmlSerial {
        id: serial

        function getStrPoint(value) {
            if (value === -1)
                return "";

            let a = 0, b = 0, c = 0;
            a = (value >> 10) + 1;
            b = ((value % (1 << 10)) >> 6) + 1;
            c = (value % 64) + 1;
            return `${a}-${b}-${c}`;
        }

        portName: "COM32"
        baudRate: 115200
        running: true
        onCallJsFunc: {
            const recvData = jsonStr;
            const result = Serial.streamProtocol(recvData);
            if (result.length > 0)
                result.forEach((item) => {
                const cmd = item.cmdId.cmdIdNum;
                const chunks = Serial.dataToHexChunks(item.data);
                timeout = 11;
                // console.log(cmd, chunks);
                probeListModel.clear();
                chunks.forEach((chunk) => {
                    probeListModel.append({
                        "chunk": getStrPoint(chunk)
                    });
                });
            });

        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            serial.callJsFunc("8A 8A 87 87 00 00 8B 8B");
        }
    }

    settings: Settings {
        property alias portName: serial.portName

        fileName: "./serial.ini"
    }

    timer: Timer {
        interval: 50
        repeat: true
        running: true
        onTriggered: {
            if (timeout++ > 10)
                serial.sendData("7E 00 7E A7");

        }
    }

}
