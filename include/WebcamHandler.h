#ifndef WEBCAMHANDLER_H
#define WEBCAMHANDLER_H

#include <QObject>
#include <gst/gst.h>
#include <gst/app/gstappsink.h>

class VideoItem;

class WebcamHandler : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isStreaming READ isStreaming NOTIFY isStreamingChanged)
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)

public:
    explicit WebcamHandler(QObject *parent = nullptr);
    ~WebcamHandler();

    bool isStreaming() const { return m_isStreaming; }
    bool isRecording() const { return m_isRecording; }

    Q_INVOKABLE void setVideoItem(VideoItem *item);

public slots:
    void startStreaming();
    void stopStreaming();
    void startRecording();
    void stopRecording();
    void playback(const QString &filePath);

signals:
    void isStreamingChanged();
    void isRecordingChanged();

private:
    static GstFlowReturn onNewSample(GstAppSink *sink, gpointer user_data);
    void processSample(GstSample *sample);

    GstElement *pipeline;
    GstAppSink *appsink;
    VideoItem *m_videoItem;
    bool m_isStreaming = false;
    bool m_isRecording = false;
};

#endif
