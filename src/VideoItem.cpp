#include "VideoItem.h"
#include <QSGSimpleTextureNode>
#include <QQuickWindow>
#include <QMutexLocker>
#include <gst/video/video.h>

VideoItem::VideoItem(QQuickItem *parent) : QQuickItem(parent), m_image(), m_smoothScaling(true) {
    setFlag(ItemHasContents, true);
}

void VideoItem::setSmoothScaling(bool enabled) {
    if (m_smoothScaling != enabled) {
        m_smoothScaling = enabled;
        qDebug() << "Smooth scaling set to:" << m_smoothScaling;
        emit smoothScalingChanged();
        update(); // Trigger repaint to apply new scaling
    }
}

void VideoItem::updateFrame(const uchar *data, int width, int height) {
    QMutexLocker locker(&m_mutex);
    QImage image(data, width, height, width * 3, QImage::Format_RGB888);

    if (m_smoothScaling) {
        // Scale to match VideoItem size
        QSize targetSize = boundingRect().size().toSize();
        if (targetSize.width() > 0 && targetSize.height() > 0) {
            m_image = image.scaled(targetSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            //qDebug() << "Scaled image to:" << m_image.size();
        } else {
            m_image = image.copy();
            //qDebug() << "Used original image size:" << m_image.size();
        }
    } else {
        m_image = image.copy();
        //qDebug() << "Used original image size:" << m_image.size();
    }

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
