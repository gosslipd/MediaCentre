#ifndef VIDEOITEM_H
#define VIDEOITEM_H

#include <QQuickItem>
#include <QSGNode>
#include <QMutex>
#include <QImage>
#include <gst/gst.h>

class VideoItem : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(bool smoothScaling READ smoothScaling WRITE setSmoothScaling NOTIFY smoothScalingChanged)
public:
    explicit VideoItem(QQuickItem *parent = nullptr);

    bool smoothScaling() const { return m_smoothScaling; }
    void setSmoothScaling(bool enabled);

    void updateFrame(const uchar *data, int width, int height);

signals:
    void smoothScalingChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    QImage m_image;
    QMutex m_mutex;
    bool m_smoothScaling = true; // Default to enabled
};

#endif
