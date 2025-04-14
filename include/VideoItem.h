#ifndef VIDEOITEM_H
#define VIDEOITEM_H

#include <QQuickItem>
#include <QSGNode>
#include <QMutex>
#include <QImage>
#include <gst/gst.h>

class VideoItem : public QQuickItem {
    Q_OBJECT
public:
    explicit VideoItem(QQuickItem *parent = nullptr);

    void updateFrame(const uchar *data, int width, int height);

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    QImage m_image;
    QMutex m_mutex;
};

#endif
