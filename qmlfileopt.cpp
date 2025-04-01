#include "qmlfileopt.h"
#include <QCoreApplication>
#include <QDebug>
#include <QUuid>
#include <QDir>
#include <QImage>
#include <QImageReader>
#include <QBuffer>
#include <QtPrintSupport/QtPrintSupport>
#include <ctime>
#include <thread>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#if defined(_WIN32)
#include <windows.h>
#include <winspool.h>
#endif
#include <QPrinterInfo>

QmlFileOpt::QmlFileOpt(QObject *parent)
    : QObject(parent), m_appdir(QCoreApplication::applicationDirPath())
{
}

QmlFileOpt::~QmlFileOpt()
{
}

QStringList QmlFileOpt::entryList(const QString &filePath)
{
    QUrl url(filePath);
    QDir dir(url.toLocalFile());
    return dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
}

QString QmlFileOpt::read(const QString &filePath)
{
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QFile file(realFilePath);
    QByteArray data;
    if (file.open(QIODevice::ReadOnly))
    {
        data = file.readAll();
        file.close();
    }
    return data.toHex();
}

// QString QmlFileOpt::formatData(const QString &content)
//{
//     return content.toUtf8().toHex();
// }

QString QmlFileOpt::currentDataTime(const QString &format)
{
    return QDateTime::currentDateTime().toString(format);
}

bool QmlFileOpt::write(const QString &filePath, const QString &content)
{
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QFile file(realFilePath + QUuid::createUuid().toString());
    qDebug() << __FUNCTION__ << file.fileName() << filePath << realFilePath;

    if (file.open(QIODevice::WriteOnly))
    {
        file.write(content.toLocal8Bit());
        file.flush();
        file.close();
        QFile::setPermissions(realFilePath, QFile::ReadOther | QFile::WriteOther);
        QFile::remove(realFilePath);
        bool bOk = file.rename(realFilePath);
        if (bOk)
        {
            return true;
        }
    }
    return false;
}

void QmlFileOpt::saveFile(const QString &filePath, const QString &name)
{
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QFileInfo info(realFilePath);
    qDebug() << __FUNCTION__ << __LINE__ << realFilePath << info.absoluteDir().absolutePath() + "/" + name + ".prn";
    QFile::copy(realFilePath, info.absoluteDir().absolutePath() + "/" + name + ".prn");
}

bool QmlFileOpt::append(const QString &filePath, const QString &content)
{
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QFile file(realFilePath);
    if (file.open(QIODevice::Append))
    {
        file.write(content.toLocal8Bit());
        file.flush();
        file.close();
    }
    return false;
}

bool QmlFileOpt::remove(const QString &filePath)
{
    qDebug() << __FUNCTION__ << filePath;
    QUrl url(filePath);
    return QFile::remove(url.toLocalFile());
}

bool QmlFileOpt::mkdir(const QString &filePath)
{
    qDebug() << __FUNCTION__;
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QDir dir;
    return dir.mkpath(realFilePath);
}

bool QmlFileOpt::mkrelativedir(const QString &filePath)
{
    QDir dir;
    return dir.mkpath(filePath);
}

bool QmlFileOpt::isExist(const QString &urlFile)
{
    QUrl url(urlFile);
    QString filePath = url.toLocalFile();
    qDebug() << __FUNCTION__ << __LINE__ << filePath << QFile::exists(filePath);
    return QFile::exists(filePath);
}

QString QmlFileOpt::imageToBase64(const QString &filePath)
{
    qDebug() << __FUNCTION__ << filePath;
    QUrl url(filePath);
    QString realFilePath = url.toLocalFile();
    QImage image(realFilePath);
    QByteArray ba;
    QBuffer buf(&ba);
    buf.open(QIODevice::WriteOnly);
    image.scaled(QSize(1920, 1080)).save(&buf, "jpeg");
    QByteArray ba2 = ba.toBase64();
    QString b64str = "data:image/jpeg;base64," + QString::fromLatin1(ba2);
    return b64str;
}

QString QmlFileOpt::labelFormat(QJsonObject jsObj, QString format)
{
    QString var1 = jsObj.value("var1").toString();
    QString var2 = jsObj.value("var2").toString();
    QString timeFormat = jsObj.value("time").toString();
    QString dateFormat = jsObj.value("date").toString();
    QString name = jsObj.value("name").toString();
    int num = jsObj.value("num").toInt();
    int limit = jsObj.value("limit").toInt();
    int sum = jsObj.value("sum").toInt();
    QString batch = jsObj.value("batch").toString();
    QString flow = jsObj.value("flow").toString();

    QByteArrayList match_keys = {
        "@VAR1@",
        "@VAR2@",
        "@TIME@",
        "@DATE@",
        "@DAY@",
        "@NAME@",
        "@NUM@",
        "@SUM@",
        "@BATCH@",
        "@FLOW@",
    };
    QByteArray data = format.toUtf8();
    for (auto &key : match_keys)
    {
        if (key == "@VAR1@")
        {
            QByteArray value = var1.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@VAR2@")
        {
            QByteArray value = var2.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@TIME@")
        {
            QByteArray format = timeFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@DATE@")
        {
            QByteArray format = dateFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@DAY@")
        {
            QString format;
            std::time_t t = std::time(nullptr);
            std::tm *now = std::localtime(&t);
            int dayOfYear = now->tm_yday + 1;
            QByteArray value = QString::asprintf("%03d", dayOfYear).toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@NAME@")
        {
            QByteArray value = name.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@NUM@")
        {
            QByteArray body = QByteArray(limit, '0');
            QByteArray _num = QByteArray::number(num, 10);
            QByteArray value = body.mid(0, body.length() - _num.length()) + _num;
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@BATCH@")
        {
            QByteArray value = batch.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@FLOW@")
        {
            QByteArray value = flow.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
        if (key == "@SUM@")
        {
            QByteArray value = flow.toUtf8();
            data.replace(key.toHex(), value.toHex());
        }
    }
    return data;
}

#include <QProcess>
void QmlFileOpt::cmdRunner(QString program, QStringList args)
{
    QProcess::startDetached(program, args);
}

bool QmlFileOpt::printPrn(QJsonObject jsObj, QString prnBody, QString printerName, QString binDirName)
{
    // 先计算MD5, 然后测试
    QByteArray data = prnBody.toUtf8();
    QString var1 = jsObj.value("var1").toString();
    QString var2 = jsObj.value("var2").toString();
    QString timeFormat = jsObj.value("time").toString();
    QString dateFormat = jsObj.value("date").toString();
    QString name = jsObj.value("name").toString();
    int num = jsObj.value("num").toInt();
    int limit = jsObj.value("limit").toInt();
    int sum = jsObj.value("sum").toInt();
    QString batch = jsObj.value("batch").toString();
    QString flow = jsObj.value("flow").toString();

    QByteArrayList match_keys = {
        "@VAR1@",
        "@VAR2@",
        "@TIME@",
        "@DATE@",
        "@DAY@",
        "@NAME@",
        "@NUM@",
        "@SUM@",
        "@BATCH@",
        "@FLOW@",
    };

    QCryptographicHash md(QCryptographicHash::Md5);
    QByteArray content = data;

    QJsonObject json;
    for (auto &key : match_keys)
    {
        if (key == "@VAR1@")
        {
            QByteArray value = var1.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@VAR2@")
        {
            QByteArray value = var2.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@TIME@")
        {
            QByteArray format = timeFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@DATE@")
        {
            QByteArray format = dateFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@DAY@")
        {
            QString format;
            std::time_t t = std::time(nullptr);
            std::tm *now = std::localtime(&t);
            int dayOfYear = now->tm_yday + 1;
            QByteArray value = QString::asprintf("%03d", dayOfYear).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@NAME@")
        {
            QByteArray value = name.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@NUM@")
        {
            QByteArray body = QByteArray(limit, '0');
            QByteArray _num = QByteArray::number(num, 10);
            QByteArray value = body.mid(0, body.length() - _num.length()) + _num;
            json.insert(key.data(), value.data());
        }
        if (key == "@BATCH@")
        {
            QByteArray value = batch.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@FLOW@")
        {
            QByteArray value = flow.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@SUM@")
        {
            QByteArray value = flow.toUtf8();
            json.insert(key.data(), value.data());
        }
    }
    auto dataPrn = QByteArray::fromHex(data);
    for (const auto &key : json.keys())
    {
        const auto &str = json.value(key).toString();
        dataPrn.replace(key, str.toUtf8());
    }

    if (!isVaildPrintName(printerName))
    {
        bool bOk = false;
        for (int i = 0; i < 25; i++)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(200));
            if (isVaildPrintName(printerName))
            {
                bOk = true;
                break;
            }
        }
        if (!bOk)
        {
            return false;
        }
    }

    bool ret1 = true;
    if (ret1)
        ret1 = RawDataToPrinter(printerName.toUtf8(), dataPrn, dataPrn.length());
    return ret1;
}

void QmlFileOpt::printDev(QString printerName)
{
    QString current_printer_name = printerName;
    QByteArray current_project_name = u8"测试打印";
    QByteArray data =
        "I8,A,001\n"
        "\n"
        "\n"
        "Q160,024\n"
        "q831\n"
        "rN\n"
        "S3\n"
        "D7\n"
        "ZT\n"
        "JF\n"
        "O\n"
        "R96,0\n"
        "f100\n"
        "N\n"
        "A428,45,2,4,1,1,N,\"" +
        current_project_name + "\"\n"
                               "B472,151,2,1,2,6,56,B,\"" +
        current_project_name + "\"\n"
                               "P1\n";
    RawDataToPrinter(current_printer_name.toUtf8(), data, data.length());
}

bool QmlFileOpt::printBtw(QJsonObject jsObj, QString prnBody, QString printerName, QString binDirName)
{
    // 先计算MD5, 然后测试
    QByteArray data = prnBody.toUtf8();
    QString var1 = jsObj.value("var1").toString();
    QString var2 = jsObj.value("var2").toString();
    QString timeFormat = jsObj.value("time").toString();
    QString dateFormat = jsObj.value("date").toString();
    QString name = jsObj.value("name").toString();
    int num = jsObj.value("num").toInt();
    int limit = jsObj.value("limit").toInt();
    int sum = jsObj.value("sum").toInt();
    QString batch = jsObj.value("batch").toString();
    QString flow = jsObj.value("flow").toString();

    QByteArrayList match_keys = {
        "@VAR1@",
        "@VAR2@",
        "@TIME@",
        "@DATE@",
        "@DAY@",
        "@NAME@",
        "@NUM@",
        "@SUM@",
        "@BATCH@",
        "@FLOW@",
    };

    QCryptographicHash md(QCryptographicHash::Md5);
    QByteArray content = data;
    md.addData(content);
    QString md5 = "btw/" + md.result().toHex().toUpper();
    if (!QFile::exists(md5 + ".btw"))
    {
        QFile file(md5 + ".btw");
        file.open(QIODevice::WriteOnly);
        file.write(QByteArray::fromHex(data));
        file.flush();
        file.close();
    }
    bool ret = true;
    const QUrl url = QUrl::fromUserInput("http://localhost:9123");
    QNetworkRequest qnr(url);
    qnr.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QNetworkAccessManager pNetworkManager;
    QJsonObject json;
    json["md5"] = md5;
    json["path"] = QCoreApplication::applicationDirPath() + "/" + md5 + ".btw";
    json["binDirName"] = binDirName;
    for (auto &key : match_keys)
    {
        if (key == "@VAR1@")
        {
            QByteArray value = var1.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@VAR2@")
        {
            QByteArray value = var2.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@TIME@")
        {
            QByteArray format = timeFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@DATE@")
        {
            QByteArray format = dateFormat.toUtf8();
            QByteArray value = QDateTime::currentDateTime().toString(format).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@DAY@")
        {
            QString format;
            std::time_t t = std::time(nullptr);
            std::tm *now = std::localtime(&t);
            int dayOfYear = now->tm_yday + 1;
            QByteArray value = QString::asprintf("%03d", dayOfYear).toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@NAME@")
        {
            QByteArray value = name.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@NUM@")
        {
            QByteArray body = QByteArray(limit, '0');
            QByteArray _num = QByteArray::number(num, 10);
            QByteArray value = body.mid(0, body.length() - _num.length()) + _num;
            json.insert(key.data(), value.data());
        }
        if (key == "@BATCH@")
        {
            QByteArray value = batch.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@FLOW@")
        {
            QByteArray value = flow.toUtf8();
            json.insert(key.data(), value.data());
        }
        if (key == "@SUM@")
        {
            QByteArray value = flow.toUtf8();
            json.insert(key.data(), value.data());
        }
    }
    qDebug() << __FUNCTION__ << __LINE__ << json;
    QNetworkReply *reply = pNetworkManager.post(qnr, QJsonDocument(json).toJson(QJsonDocument::Compact));
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec(QEventLoop::ExcludeUserInputEvents);
    QByteArray replyData = reply->readAll();
    reply->deleteLater();
    reply = nullptr;
    return ret;
}

bool QmlFileOpt::isVaildPrintName(const QString &name)
{
    auto isVaild = [](const QByteArray &_szPrinterName) -> BOOL
    {
        LPSTR szPrinterName = (LPSTR)_szPrinterName.data();
        HANDLE hPrinter = 0;
        DWORD dwNeeded = 0;
        PRINTER_INFO_2A *pPrinterInfo = (PRINTER_INFO_2A *)malloc(0);
        ::OpenPrinterA(szPrinterName, &hPrinter, NULL);
        if (!::GetPrinterA(hPrinter, 2, (LPBYTE)pPrinterInfo, 0, &dwNeeded))
        {
            pPrinterInfo = (PRINTER_INFO_2A *)malloc(dwNeeded);
            qDebug() << ::GetPrinterA(hPrinter, 2, (LPBYTE)pPrinterInfo, dwNeeded, &dwNeeded);
        }
        ::ClosePrinter(hPrinter);
        qDebug() << "print: "
                 << pPrinterInfo->Attributes
                 << pPrinterInfo->Priority
                 << pPrinterInfo->Status
                 << pPrinterInfo->cJobs;
        do
        {
            if (pPrinterInfo->Status == PRINTER_STATUS_PAPER_OUT)
            {
                break;
            }
            if (pPrinterInfo->Status == PRINTER_STATUS_OFFLINE)
            {
                break;
            }
            if (pPrinterInfo->cJobs)
            {
                break;
            }
            if (pPrinterInfo->Attributes & PRINTER_ATTRIBUTE_WORK_OFFLINE)
                break;
            free(pPrinterInfo);
            return TRUE;
        } while (0);
        free(pPrinterInfo);
        return FALSE;
    };
    return isVaild(name.toLocal8Bit());
}

bool QmlFileOpt::RawDataToPrinter(const QByteArray &_szPrinterName, const QByteArray &_data, int64_t _lenght)
{
    LPSTR szPrinterName = (LPSTR)_szPrinterName.data();
    LPSTR lpData = (LPSTR)_data.data();
    DWORD dwCount = (DWORD)_lenght;
    bool bStatus = FALSE;
    HANDLE hPrinter = NULL;
    DOC_INFO_1A DocInfo;
    DWORD dwJob = 0L;
    DWORD dwBytesWritten = 0L;

    // 打开打印机的手柄，这里使用OpenPrinterA()而不是OpenPrinter()是因为当前Qt编码是ANSI
    bStatus = OpenPrinterA(szPrinterName, &hPrinter, NULL);
    if (bStatus)
    {
        // 填写打印文档信息
        DocInfo.pDocName = (LPSTR) "Raw Document";
        DocInfo.pOutputFile = NULL;
        DocInfo.pDatatype = (LPSTR) "RAW";

        // 通知后台处理程序文档正在开始
        dwJob = StartDocPrinterA(hPrinter, 1, (LPBYTE)&DocInfo);
        if (dwJob > 0)
        {
            // 开始一页的打印
            bStatus = StartPagePrinter(hPrinter);
            if (bStatus)
            {
                // 发送数据到打印机
                bStatus = WritePrinter(hPrinter, lpData, dwCount, &dwBytesWritten);
                EndPagePrinter(hPrinter);
            }
            // 通知后台处理程序文档正在结束
            EndDocPrinter(hPrinter);
        }
        // 关闭打印机手柄
        ClosePrinter(hPrinter);
    }
    // 检查是否写入了正确的字节数
    if (!bStatus || (dwBytesWritten != dwCount))
    {
        bStatus = false;
    }
    else
    {
        bStatus = true;
    }
    return bStatus;
}

QString QmlFileOpt::binDirName()
{
    return qApp->applicationDirPath().split("/").last();
}

void JDirObj::test()
{
    qDebug() << __FUNCTION__ << __LINE__;
}

bool JDirObj::isExist(const QString &path)
{
    qDebug() << __FUNCTION__ << __LINE__ << path;
    return m_dir.exists(path);
}
