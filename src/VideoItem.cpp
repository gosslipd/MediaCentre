#include "VideoItem.h"
#include <QSGSimpleTextureNode>
#include <QQuickWindow>
#include <QMutexLocker>
#include <gst/video/video.h>

VideoItem::VideoItem(QQuickItem *parent)
    : QQuickItem(parent), m_sample(nullptr) {
    setFlag(ItemHasContents, true);
}

VideoItem::~VideoItem() {
    if (m_sample) {
        gst_sample_unref(m_sample);
    }
}

void VideoItem::setFrame(GstSample *sample) {
    QMutexLocker locker(&m_mutex);
    if (m_sample) {
        gst_sample_unref(m_sample);
    }
    m_sample = sample ? gst_sample_ref(sample) : nullptr;
    update();  // Trigger repaint
}

QSGNode *VideoItem::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
    QMutexLocker locker(&m_mutex);
    if (!m_sample) {
        delete oldNode;
        return nullptr;
    }

    GstCaps *caps = gst_sample_get_caps(m_sample);
    GstBuffer *buffer = gst_sample_get_buffer(m_sample);
    if (!caps || !buffer) {
        delete oldNode;
        return nullptr;
    }

    GstVideoInfo vinfo;
    gst_video_info_init(&vinfo);
    if (!gst_video_info_from_caps(&vinfo, caps)) {
        delete oldNode;
        return nullptr;
    }

    // Map the buffer for reading
    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_READ)) {
        delete oldNode;
        return nullptr;
    }

    // Create texture from raw video data
    QSGSimpleTextureNode *node = static_cast<QSGSimpleTextureNode *>(oldNode);
    if (!node) {
        node = new QSGSimpleTextureNode();
    }

    qDebug() << "vinfo.width=" << vinfo.width << ", vinfo.height=" << vinfo.height;

    QImage image(map.data, vinfo.width, vinfo.height, QImage::Format_RGB32);
    QSGTexture *texture = window()->createTextureFromImage(image);
    node->setTexture(texture);
    node->setRect(boundingRect());

    gst_buffer_unmap(buffer, &map);
    return node;
}
