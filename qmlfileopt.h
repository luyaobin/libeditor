#pragma once

#include <QtQuick/QQuickItem>
#include <QDir>
#include <QFile>
#include <QJsonObject>
#include <QTemporaryFile>

class QmlFileOpt : public QObject
{
    Q_OBJECT
    //    QML_ELEMENT
    Q_DISABLE_COPY(QmlFileOpt)
    Q_PROPERTY(QString appdir READ appdir WRITE setAppdir NOTIFY appdirChanged)
    Q_PROPERTY(QString binDirName READ binDirName NOTIFY binDirNameChanged)
public:
    explicit QmlFileOpt(QObject *parent = nullptr);
    ~QmlFileOpt();

    void setAppdir(const QString &value)
    {
        m_appdir = value;
        emit appdirChanged();
    }
    QString appdir() const { return m_appdir; }
    Q_INVOKABLE QString read(const QString &filePath);
    //    Q_INVOKABLE QString formatData(const QString& content);
    Q_INVOKABLE QStringList entryList(const QString &filePath);
    Q_INVOKABLE QString currentDataTime(const QString &format);
    Q_INVOKABLE bool write(const QString &filePath, const QString &content);
    Q_INVOKABLE void saveFile(const QString &filePath, const QString &name);
    Q_INVOKABLE bool append(const QString &filePath, const QString &content);
    Q_INVOKABLE bool remove(const QString &filePath);
    Q_INVOKABLE bool mkdir(const QString &filePath);
    Q_INVOKABLE bool mkrelativedir(const QString &filePath);
    Q_INVOKABLE bool isExist(const QString &urlFile);
    Q_INVOKABLE QString imageToBase64(const QString &filePath);
    Q_INVOKABLE bool printBtw(QJsonObject jsObj, QString prnBody, QString printerName, QString binDirName);
    Q_INVOKABLE bool printPrn(QJsonObject jsObj, QString prnBody, QString printerName, QString binDirName);
    Q_INVOKABLE void printDev(QString printerName);
    Q_INVOKABLE QString labelFormat(QJsonObject jsObj, QString format);
    Q_INVOKABLE void cmdRunner(QString program, QStringList args);
    bool isVaildPrintName(const QString &name);
    bool RawDataToPrinter(const QByteArray &szPrinterName, const QByteArray &data, int64_t lenght);
    QString binDirName();
signals:
    void appdirChanged();
    void binDirNameChanged();

private:
    QString m_appdir;

    QMap<QString, QString> m_filed_map_key;
};

class JFileObj : public QObject
{
    Q_OBJECT
    //    QML_ELEMENT
    Q_DISABLE_COPY(JFileObj)
public:
    explicit JFileObj(QObject *parent = nullptr)
        : QObject(parent) {};
    ~JFileObj() {};

private:
    QFile m_file;
    QTemporaryFile m_temp;
};

class JDirObj : public QObject
{
    Q_OBJECT
    //    QML_ELEMENT
    Q_DISABLE_COPY(JDirObj)
public:
    explicit JDirObj(QObject *parent = nullptr)
        : QObject(parent) {};
    ~JDirObj() {};
    Q_INVOKABLE void test();
    Q_INVOKABLE bool isExist(const QString &path);

private:
    QDir m_dir;
};
