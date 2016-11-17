#ifndef MONITORMOUSEEVENT_H
#define MONITORMOUSEEVENT_H

#if(QT_VERSION>=0x050000)
#include <QQuickPaintedItem>
#else
#include <QDeclarativeItem>
#endif

class QMouseEvent;
#if(QT_VERSION>=0x050000)
class MonitorMouseEvent : public QQuickPaintedItem
#else
class MonitorMouseEvent : public QDeclarativeItem
#endif
{
    Q_OBJECT

    Q_PROPERTY(QDeclarativeItem* target READ target WRITE setTarget NOTIFY targetChanged)
public:
#if(QT_VERSION>=0x050000)
    explicit MonitorMouseEvent(QQuickPaintedItem *parent = 0);
#else
    explicit MonitorMouseEvent(QDeclarativeItem *parent = 0);
#endif
    
    QDeclarativeItem* target() const;

signals:
    void targetChanged(QDeclarativeItem* arg);

    void mousePress(QPointF pos);
    void mouseRelease(QPointF pos);
    void mouseDoubleClicked(QPointF pos);
public slots:
    void setTarget(QDeclarativeItem* arg);

private:
    QDeclarativeItem* m_target;
#if(QT_VERSION>=0x050000)
#else
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    bool eventFilter(QObject *target, QEvent *event);
#endif

};

#endif // MONITORMOUSEEVENT_H
