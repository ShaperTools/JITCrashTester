#include "QuickUtil.h"
#include <QQmlEngine>

QuickUtil::QuickUtil(QQmlEngine *engine, QObject *parent) : QObject(parent), mEngine(engine)
{
}

void QuickUtil::clearComponentCache() {
    mEngine->clearComponentCache();
}
