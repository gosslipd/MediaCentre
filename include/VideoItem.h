#ifndef VIDEOITEM_H
#define VIDEOITEM_H

#include <QQuickItem>
#include <QSGNode>
#include <QMutex>
#include <gst/gst.h>

class VideoItem : public QQuickItem {
    Q_OBJECT
public:
    explicit VideoItem(QQuickItem *parent = nullptr);
    ~VideoItem();

    void setFrame(GstSample *sample);

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    GstSample *m_sample;
    QMutex m_mutex;
};

#endif
