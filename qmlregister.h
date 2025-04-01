
#ifndef QMLSYSTEM_H
#define QMLSYSTEM_H

#include <QObject>
#include <QClipboard>
#include <QMimeData>
#include <QPixmap>
#include <QObject>
#include <QProcess>
#ifdef CUS_DECL
#define CUS_DECL_EXPORT Q_DECL_EXPORT
#else
#define CUS_DECL_EXPORT
#endif

class CUS_DECL_EXPORT QmlSystem : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(bool hasImage READ hasImage NOTIFY clipboardChanged)
    Q_PROPERTY(QString image READ image NOTIFY clipboardChanged)

public:
    explicit QmlSystem(QObject *parent = nullptr);
    bool hasImage() const;
    QString image() const;
    Q_INVOKABLE bool shutdownSystem();
    Q_INVOKABLE void ctrlV(){paste(); emit clipboardChanged();};

public slots:
    void paste();

signals:
    void clipboardChanged();

private:
    QClipboard *m_clipboard;
    QString m_currentImage;
    bool m_hasImage;
    QProcess process;
};

#endif


