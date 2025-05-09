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
    Q_PROPERTY(bool mirrorHorizontally READ mirrorHorizontally WRITE setMirrorHorizontally NOTIFY mirrorHorizontallyChanged)
public:
    explicit VideoItem(QQuickItem *parent = nullptr);

    bool smoothScaling() const { return m_smoothScaling; }
    void setSmoothScaling(bool enabled);

    bool mirrorHorizontally() const { return m_mirrorHorizontally; }
    void setMirrorHorizontally(bool enabled);

    void updateFrame(const uchar *data, int width, int height);

signals:
    void smoothScalingChanged();
    void mirrorHorizontallyChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    QImage m_image;
    QMutex m_mutex;
    bool m_smoothScaling = true; // Default to enabled
    bool m_mirrorHorizontally = true; // Default to enabled
};

#endif
