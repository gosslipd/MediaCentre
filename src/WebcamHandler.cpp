#include "WebcamHandler.h"
#include <gst/video/videooverlay.h>
#include <QDebug>

WebcamHandler::WebcamHandler(QObject *parent) : QObject(parent), pipeline(nullptr) {
    gst_init(nullptr, nullptr); // Initialize GStreamer
}

WebcamHandler::~WebcamHandler() {
    stopStreaming();
    gst_deinit();
}

void WebcamHandler::startStreaming() {
    if (m_isStreaming) return;

    // Pipeline: webcam -> display, mic -> audio
    const char *pipeline_str =
        "v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,width=640,height=480 ! "
        "autovideosink name=videosink "
        "dshowsrc ! audioconvert ! autoaudiosink";
    
    pipeline = gst_parse_launch(pipeline_str, nullptr);
    if (!pipeline) {
        qDebug() << "Failed to create pipeline";
        return;
    }

    videosink = gst_bin_get_by_name(GST_BIN(pipeline), "videosink");
    GstStateChangeReturn ret = gst_element_set_state(pipeline, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        qDebug() << "Failed to start pipeline";
        gst_object_unref(pipeline);
        pipeline = nullptr;
        return;
    }

    m_isStreaming = true;
    emit isStreamingChanged();
}

void WebcamHandler::stopStreaming() {
    if (!m_isStreaming) return;

    gst_element_set_state(pipeline, GST_STATE_NULL);
    gst_object_unref(pipeline);
    pipeline = nullptr;
    m_isStreaming = false;
    m_isRecording = false;
    emit isStreamingChanged();
}

void WebcamHandler::startRecording() {
    if (!m_isStreaming || m_isRecording) return;

    stopStreaming(); // Restart with recording pipeline
    const char *pipeline_str =
        "v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,width=640,height=480 ! "
        "x264enc ! mp4mux name=mux ! filesink location=recording.mp4 "
        "dshowsrc ! audioconvert ! avenc_aac ! mux.";
    
    pipeline = gst_parse_launch(pipeline_str, nullptr);
    if (!pipeline) {
        qDebug() << "Failed to create recording pipeline";
        return;
    }

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
}

void WebcamHandler::stopRecording() {
    if (!m_isRecording) return;
    stopStreaming(); // Stops and saves the file
    m_isRecording = false;
}

void WebcamHandler::playback(const QString &filePath) {
    stopStreaming(); // Stop any existing stream

    QString pipeline_str = QString(
        "filesrc location=%1 ! qtdemux ! decodebin ! videoconvert ! autovideosink "
        "filesrc location=%1 ! qtdemux ! decodebin ! audioconvert ! autoaudiosink"
    ).arg(filePath);

    pipeline = gst_parse_launch(pipeline_str.toUtf8().constData(), nullptr);
    if (!pipeline) {
        qDebug() << "Failed to create playback pipeline";
        return;
    }

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