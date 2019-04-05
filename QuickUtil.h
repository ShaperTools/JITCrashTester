#ifndef QUICKUTIL_H
#define QUICKUTIL_H

#include <QObject>
class QQmlEngine;

class QuickUtil : public QObject
{
    Q_OBJECT
public:
    explicit QuickUtil(QQmlEngine* engine, QObject *parent = nullptr);

    Q_INVOKABLE void clearComponentCache();

private:
    QQmlEngine* mEngine;
};

#endif // QUICKUTIL_H
