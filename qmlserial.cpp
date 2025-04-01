#include "qmlserial.h"
#include <QDebug>
#include <QTimerEvent>
#include <QJsonObject>
#include <QJsonDocument>

QmlSerial::QmlSerial(QObject *parent)
    : QObject(parent)
{
    // startTimer(1);
    connect(&m_serial, &QSerialPort::readyRead, this, &QmlSerial::onReadyRead);
}

QmlSerial::~QmlSerial()
{
    disconnect(&m_serial, &QSerialPort::readyRead, this, &QmlSerial::onReadyRead);
}

void QmlSerial::responceFunc(const QString &result) { m_result = result; }

void QmlSerial::sendData(const QString &result) {
    m_serial.write(QByteArray::fromHex(result.toUtf8()));
    m_serial.waitForBytesWritten(result.size() / 2);
}

void QmlSerial::sendBeebModbus(const QString &result)
{
    auto crc_chk = [](unsigned char *data,unsigned char length) -> uint16_t
    {
        int j;
        unsigned int crc_reg = 0xffff;
        while(length--) {
            crc_reg^=*data++;
            for(j=0;j<8;j++)
                if(crc_reg&0x01)
                    crc_reg=(crc_reg>>1)^0xA001;
                else
                    crc_reg=crc_reg>>1;
        }
        return crc_reg;
    };
    QByteArray data = QByteArray::fromHex(result.toUtf8());
    auto crc = crc_chk((unsigned char*)data.data(),data.size());
    data += QByteArray((char*)&crc, 2);
    //    m_serial.write(data);
    if (m_beeb.size() < 3) {
        m_beeb.append(data);
    }
}

void QmlSerial::sendModbus(const QString &result)
{
    auto crc_chk = [](unsigned char *data,unsigned char length) -> uint16_t
    {
        int j;
        unsigned int crc_reg = 0xffff;
        while(length--) {
            crc_reg^=*data++;
            for(j=0;j<8;j++)
                if(crc_reg&0x01)
                    crc_reg=(crc_reg>>1)^0xA001;
                else
                    crc_reg=crc_reg>>1;
        }
        return crc_reg;
    };
    QByteArray data = QByteArray::fromHex(result.toUtf8());
    auto crc = crc_chk((unsigned char*)data.data(),data.size());
    data += QByteArray((char*)&crc, 2);
    //    m_serial.write(data);
    //    if (data.at(0) == 1 || data.at(0) == 5) {
    if (m_queue.size() < 5) {
        m_queue.append(data);
        // qDebug() << __FUNCTION__ << __LINE__ << data;
    }
    //    }
}

void QmlSerial::setBaudRate(int baudRate) {
    m_baudRate = baudRate;
    m_serial.setBaudRate(baudRate);
    emit baudRateChanged();
    triggerChanged();
}

void QmlSerial::setStopBits(int stopBits) {
    switch(stopBits) {
    case 1:
        m_serial.setStopBits(QSerialPort::OneStop);
        break;
    case 2:
        m_serial.setStopBits(QSerialPort::TwoStop);
        break;
    case 3:
        m_serial.setStopBits(QSerialPort::OneAndHalfStop);
        break;
    }
    m_stopBits = stopBits;
    emit stopBitsChanged();
    m_serial.close();
    triggerChanged();
}

void QmlSerial::setHostname(const QString &hostname) {
    m_hostname = hostname;
    m_serial.setPortName(hostname);
    emit hostnameChanged();
    m_serial.close();
    triggerChanged();
}

void QmlSerial::setRunning(bool running) {
    m_running = running;
    emit runningChanged();
    triggerChanged();
}

void QmlSerial::triggerChanged() {
    if (m_running) {
        if (m_baudRate != 0 && !m_hostname.isEmpty()) {
            m_serial.open(QIODevice::ReadWrite);
        }
    }
    else {
        m_serial.close();
    }
}

void QmlSerial::timerEvent(QTimerEvent *e)
{
    if (!m_queue.isEmpty()) {
        if (w.hasExpired(1000)) {
            if (!r.isValid()) {
                r.start();
                // m_serial.close();
                // m_serial.open(QIODevice::ReadWrite);
            }
        }
        if (r.isValid()) {
            auto data = m_queue.front();
            m_queue.pop_front();
            // qDebug() << __FUNCTION__ << __LINE__ << data.toHex();
            m_serial.write(data);
            r.invalidate();
            w.restart();
        }
    }
    else if (!m_beeb.isEmpty()) {
        if (w.hasExpired(100)) {
            r.start();
        }
        if (r.isValid()) {
            auto data = m_beeb.front();
            m_beeb.pop_front();
            m_serial.write(data);
            r.invalidate();
            w.restart();
        }
    }
}

void QmlSerial::onReadyRead()
{
    auto content = m_serial.readAll();
    emit callJsFunc(content.toHex());
    // qDebug() << __FUNCTION__ << __LINE__ << content.toHex();
    // if (!m_result.isEmpty()) {
    //     m_queue.append(m_result.toUtf8());
    // }
    // r.restart();
}

