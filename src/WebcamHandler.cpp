#include "WebcamHandler.h"
#include "VideoItem.h"
#include <gst/gst.h>
#include <gst/app/gstappsink.h>  // Added for GST_APP_SINK and gst_app_sink_pull_sample
#include <gst/video/video.h> // Added for GstVideoInfo
#include <QDebug>

WebcamHandler::WebcamHandler(QObject *parent)
    : QObject(parent), pipeline(nullptr), appsink(nullptr), m_videoItem(nullptr) {
    //g_setenv("GST_DEBUG", "4", TRUE);
    g_setenv("GST_PLUGIN_PATH", "C:/gstreamer/1.0/msvc_x86_64/lib/gstreamer-1.0;C:/CMakeBuildFolder/MediaCentre/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Release/Release/gstreamer-1.0", TRUE);
    g_setenv("GST_PLUGIN_SYSTEM_PATH", "", TRUE); // Disable system-wide plugin scanning (removes warnings)
    g_setenv("GI_TYPELIB_PATH", "", TRUE); // Disable GObject introspection (removes warnings)
    g_setenv("GST_PLUGIN_BLACKLIST", "python", TRUE); // Blacklist python plugin (removes warnings)
    gst_init(nullptr, nullptr);
}

WebcamHandler::~WebcamHandler() {
    stopStreaming();
    gst_deinit();
}

void WebcamHandler::setVideoItem(VideoItem *item) {
    m_videoItem = item;
}

void WebcamHandler::startStreaming() {
    const char *pipeline_str =
#ifdef Q_OS_WIN
        "mfvideosrc ! videoscale ! videoconvert ! video/x-raw,format=RGB,width=640,height=480 ! "
        "appsink name=appsink emit-signals=true"
#else
        "v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,format=RGB,width=640,height=480 ! "
        "appsink name=appsink emit-signals=true"
#endif
        ;

    GError *error = nullptr;
    pipeline = gst_parse_launch(pipeline_str, &error);
    if (!pipeline || error) {
        qCritical() << "Failed to create pipeline:" << (error ? error->message : "Unknown error");
        if (error) g_error_free(error);
        return;
    }

    GstElement *sink = gst_bin_get_by_name(GST_BIN(pipeline), "appsink");
    if (!sink) {
        qCritical() << "Failed to get appsink";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }
    appsink = GST_APP_SINK(sink);

    g_signal_connect(appsink, "new-sample", G_CALLBACK(WebcamHandler::onNewSample), this);

    GstStateChangeReturn ret = gst_element_set_state(pipeline, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        qCritical() << "Failed to start pipeline";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        gst_object_unref(appsink);
        appsink = nullptr;
        return;
    }

    qDebug() << "Pipeline started successfully";
    m_isStreaming = true;
    emit isStreamingChanged();
}

GstFlowReturn WebcamHandler::onNewSample(GstAppSink *sink, gpointer user_data) {
    WebcamHandler *self = static_cast<WebcamHandler *>(user_data);
    GstSample *sample = gst_app_sink_pull_sample(sink);
    if (!sample) {
        qWarning() << "Failed to pull sample";
        return GST_FLOW_ERROR;
    }

    // Post to GUI thread
    QMetaObject::invokeMethod(self, [self, sample]() {
        self->processSample(sample);
    }, Qt::QueuedConnection);

    return GST_FLOW_OK;
}

void WebcamHandler::processSample(GstSample *sample) {
    GstBuffer *buffer = gst_sample_get_buffer(sample);
    if (!buffer) {
        qWarning() << "No buffer in sample";
        gst_sample_unref(sample);
        return;
    }

    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_READ)) {
        qWarning() << "Failed to map buffer";
        gst_sample_unref(sample);
        return;
    }

    GstCaps *caps = gst_sample_get_caps(sample);
    GstVideoInfo vinfo;
    gst_video_info_init(&vinfo);
    if (!gst_video_info_from_caps(&vinfo, caps)) {
        qWarning() << "Failed to get video info";
        gst_buffer_unmap(buffer, &map);
        gst_sample_unref(sample);
        return;
    }

    // Expect RGB888: 3 bytes per pixel
    qint64 expected_size = static_cast<qint64>(vinfo.width) * vinfo.height * 3;
    //qDebug() << "Buffer size:" << map.size << ", expected:" << expected_size
    //         << ", format:" << vinfo.finfo->name << ", width:" << vinfo.width << ", height:" << vinfo.height;
    if (map.size < expected_size) {
        qWarning() << "Buffer size too small:" << map.size << ", expected:" << expected_size;
        gst_buffer_unmap(buffer, &map);
        gst_sample_unref(sample);
        return;
    }

    if (m_videoItem) {
        //qDebug() << "Updating frame: width=" << vinfo.width << ", height=" << vinfo.height;
        m_videoItem->updateFrame(map.data, vinfo.width, vinfo.height);
    }

    gst_buffer_unmap(buffer, &map);
    gst_sample_unref(sample);
}

void WebcamHandler::stopStreaming() {
    if (!m_isStreaming) return;

    qDebug() << "Stopping streaming...";
    if (pipeline) {
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(pipeline);
        pipeline = nullptr;
    }
    m_isStreaming = false;
    m_isRecording = false;
    emit isStreamingChanged();
    emit isRecordingChanged();
}

void WebcamHandler::startRecording() {
    if (!m_isStreaming || m_isRecording) return;

    stopStreaming();
    const char *pipeline_str =
#ifdef Q_OS_WIN
        "mfvideosrc ! videoscale ! videoconvert ! video/x-raw,format=RGB,width=640,height=480 ! "
        "tee name=t ! queue ! x264enc ! mp4mux name=mux ! filesink location=recording.mp4 "
        "t. ! queue ! appsink name=appsink emit-signals=true "
        "wasapisrc ! audioconvert ! avenc_aac ! mux.";
#else
        "v4l2src device=/dev/video0 ! videoscale ! videoconvert ! video/x-raw,format=RGB,width=640,height=480 ! "
        "tee name=t ! queue ! x264enc ! mp4mux name=mux ! filesink location=recording.mp4 "
        "t. ! queue ! appsink name=appsink emit-signals=true "
        "wasapisrc ! audioconvert ! avenc_aac ! mux.";
#endif

    qDebug() << "Creating recording pipeline:" << pipeline_str;
    pipeline = gst_parse_launch(pipeline_str, nullptr);
    if (!pipeline) {
        qDebug() << "Failed to create recording pipeline";
        return;
    }

    GstElement *sink = gst_bin_get_by_name(GST_BIN(pipeline), "appsink");
    appsink = GST_APP_SINK(sink);
    if (!appsink) {
        qDebug() << "Failed to get appsink element";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }

    g_signal_connect(appsink, "new-sample", G_CALLBACK(WebcamHandler::onNewSample), this);

    GstStateChangeReturn ret = gst_element_set_state(pipeline, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        qDebug() << "Failed to start recording";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }

    m_isStreaming = true;
    m_isRecording = true;
    emit isStreamingChanged();
    emit isRecordingChanged();
}

void WebcamHandler::stopRecording() {
    if (!m_isRecording) return;
    stopStreaming();
    m_isRecording = false;
    emit isRecordingChanged();
}

void WebcamHandler::playback(const QString &filePath) {
    stopStreaming();

    QString pipeline_str = QString(
#ifdef Q_OS_WIN
                               "filesrc location=%1 ! qtdemux ! decodebin ! videoconvert ! video/x-raw,format=RGB ! "
                               "appsink name=appsink emit-signals=true"
#else
                               "filesrc location=%1 ! qtdemux ! decodebin ! videoconvert ! video/x-raw,format=RGB ! "
                               "appsink name=appsink emit-signals=true"
#endif
                               ).arg(filePath);

    qDebug() << "Creating playback pipeline:" << pipeline_str;
    pipeline = gst_parse_launch(pipeline_str.toUtf8().constData(), nullptr);
    if (!pipeline) {
        qDebug() << "Failed to create playback pipeline";
        return;
    }

    GstElement *sink = gst_bin_get_by_name(GST_BIN(pipeline), "appsink");
    appsink = GST_APP_SINK(sink);
    if (!appsink) {
        qDebug() << "Failed to get appsink element";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }

    g_signal_connect(appsink, "new-sample", G_CALLBACK(WebcamHandler::onNewSample), this);

    GstStateChangeReturn ret = gst_element_set_state(pipeline, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        qDebug() << "Failed to start playback";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }

    m_isStreaming = true;
    emit isStreamingChanged();
}
