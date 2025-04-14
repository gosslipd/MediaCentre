#include "VideoItem.h"
#include <QSGSimpleTextureNode>
#include <QQuickWindow>
#include <QMutexLocker>
#include <gst/video/video.h>

VideoItem::VideoItem(QQuickItem *parent) : QQuickItem(parent), m_image() {
    setFlag(ItemHasContents, true);
}

void VideoItem::updateFrame(const uchar *data, int width, int height) {
    QMutexLocker locker(&m_mutex);
    m_image = QImage(data, width, height, width * 3, QImage::Format_RGB888).copy();
    //qDebug() << "Updated frame: width=" << width << ", height=" << height;
    update();
}

QSGNode *VideoItem::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
    QMutexLocker locker(&m_mutex);
    if (m_image.isNull()) {
        qDebug() << "Image is null";
        delete oldNode;
        return nullptr;
    }

    //qDebug() << "Creating texture for image size:" << m_image.size();
    QSGSimpleTextureNode *node = static_cast<QSGSimpleTextureNode *>(oldNode);
    if (!node) {
        qDebug() << "Creating new texture node";
        node = new QSGSimpleTextureNode();
    }

    QSGTexture *texture = window()->createTextureFromImage(m_image);
    if (!texture) {
        qWarning() << "Failed to create texture";
        delete node;
        return nullptr;
    }

    node->setTexture(texture);
    node->setRect(boundingRect());
    node->markDirty(QSGNode::DirtyMaterial);
    //qDebug() << "Texture node updated";

    return node;
}
