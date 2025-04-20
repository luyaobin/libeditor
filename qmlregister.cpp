#include "qmlregister.h"
#include <QDebug>
#include <QUrl>
QmlSystem::QmlSystem(QObject *parent) : QObject(parent)
{
    // 连接进程信号
    qDebug() << __FUNCTION__ << __LINE__;
    // qDebug() << __FUNCTION__ << __LINE__;
    // connect(m_clipboard, &QClipboard::dataChanged, this, &QmlSystem::clipboardChanged);

    qDebug() << __FUNCTION__ << __LINE__;
    connect(&process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error)
            { qDebug() << "Process error:" << error; });

    qDebug() << __FUNCTION__ << __LINE__;
}

bool QmlSystem::hasImage() const
{
    return m_hasImage;
}

QString QmlSystem::image() const
{

    return m_currentImage;
}

#include <QBuffer>
void QmlSystem::paste()
{
    const QMimeData *mimeData = m_clipboard->mimeData();
    qDebug() << __FUNCTION__ << __LINE__ << mimeData->formats();
    if (mimeData->hasImage())
    {
        auto currentImage = qvariant_cast<QPixmap>(mimeData->imageData());
        // m_currentImage ;
        m_hasImage = true;
        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        buffer.open(QIODevice::WriteOnly);
        currentImage.save(&buffer, "PNG");

        m_currentImage = "data:image/png;base64," + QString::fromLatin1(byteArray.toBase64());

        // 添加base64图片头
        // m_base64Image =  m_base64Image;
    }
    else if (mimeData->hasUrls())
    {
        QList<QUrl> urls = mimeData->urls();
        if (!urls.isEmpty())
        {
            QUrl url = urls.first();
            if (url.isValid() && url.isLocalFile())
            {
                auto currentImage = QPixmap(url.toLocalFile());
                m_hasImage = true;

                // 将图像编码为base64
                QByteArray byteArray;
                QBuffer buffer(&byteArray);
                buffer.open(QIODevice::WriteOnly);
                currentImage.save(&buffer, "PNG");
                // QByteArray base64Data = byteArray.toBase64();
                m_currentImage = "data:image/png;base64," + QString::fromLatin1(byteArray.toBase64());
            }
        }
    }
    else
    {
        m_currentImage = QString();
        m_hasImage = false;
    }

    emit clipboardChanged();
}

bool QmlSystem::shutdownSystem()
{
#ifdef Q_OS_WIN
    // Windows下使用shutdown命令
    process.start("shutdown", QStringList() << "-s" << "-t" << "0");
#else
    // Linux/Unix下使用shutdown命令
    process.start("shutdown", QStringList() << "-h" << "now");
#endif

    // 等待命令启动
    if (!process.waitForStarted())
    {
        qDebug() << "Failed to start shutdown command";
        return false;
    }

    // 等待命令完成
    process.waitForFinished();

    // 检查退出状态
    return process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
}
