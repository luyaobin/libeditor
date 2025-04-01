#pragma once

#include <QtQuick/QQuickItem>
#include <QSerialPort>
#include <QQueue>
#include <QElapsedTimer>
#ifdef CUS_DECL
#define CUS_DECL_EXPORT Q_DECL_EXPORT
#else
#define CUS_DECL_EXPORT
#endif
class CUS_DECL_EXPORT QmlSerial : public QObject {
    Q_OBJECT
    // QML_ELEMENT
    // Q_DISABLE_COPY(QmlSerial)
    Q_PROPERTY(QString portName READ hostname WRITE setHostname NOTIFY hostnameChanged)
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
    Q_PROPERTY(int stopBits READ stopBits WRITE setStopBits NOTIFY stopBitsChanged)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
public:
    explicit QmlSerial(QObject *parent = nullptr);
    ~QmlSerial() override;
    Q_INVOKABLE bool isOpen() const { return m_serial.isOpen(); }
    Q_INVOKABLE void responceFunc(const QString& result);;
    Q_INVOKABLE void sendData(const QString& result);
    Q_INVOKABLE void sendBeebModbus(const QString& result);
    Q_INVOKABLE void sendModbus(const QString& result);
    void setBaudRate(int baudRate);
    void setStopBits(int stopBits);
    void setHostname(const QString& hostname);
    void setRunning(bool running);
    void triggerChanged();

    bool running() const { return m_running; }
    int baudRate() const { return m_baudRate; }
    int stopBits() const { return m_stopBits; }
    QString hostname() const { return m_hostname; }
    virtual void timerEvent(QTimerEvent * e) override;
private slots:
    void onReadyRead();
signals:
    void callJsFunc(const QString& jsonStr);
    void hostnameChanged();
    void baudRateChanged();
    void stopBitsChanged();
    void runningChanged();
public:
private:
    bool m_running = false;
    int m_baudRate = 0;
    int m_stopBits = 0;
    QString m_hostname;
    QString m_result;
    QSerialPort m_serial;
    QQueue<QByteArray> m_queue;
    QQueue<QByteArray> m_beeb;
    QElapsedTimer r;
    QElapsedTimer w;
};
