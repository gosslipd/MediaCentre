#ifndef WEBCAMHANDLER_H
#define WEBCAMHANDLER_H

#include <QObject>
#include <gst/gst.h>
#include <gst/app/gstappsink.h>
#include <QStringList>

class VideoItem;

class WebcamHandler : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isStreaming READ isStreaming NOTIFY isStreamingChanged)
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
    Q_PROPERTY(QStringList webcamList READ webcamList NOTIFY webcamListChanged)
    Q_PROPERTY(int selectedWebcamIndex READ selectedWebcamIndex WRITE setSelectedWebcamIndex NOTIFY selectedWebcamIndexChanged)

public:
    explicit WebcamHandler(QObject *parent = nullptr);
    ~WebcamHandler();

    bool isStreaming() const { return m_isStreaming; }
    bool isRecording() const { return m_isRecording; }
    QStringList webcamList() const { return m_webcamList; }
    int selectedWebcamIndex() const { return m_selectedWebcamIndex; }

    Q_INVOKABLE void setVideoItem(VideoItem *item);

public slots:
    void startStreaming();
    void stopStreaming();
    void startRecording();
    void stopRecording();
    void playback(const QString &filePath);
    void setSelectedWebcamIndex(int index);

signals:
    void isStreamingChanged();
    void isRecordingChanged();
    void webcamListChanged();
    void selectedWebcamIndexChanged();

private:
    static GstFlowReturn onNewSample(GstAppSink *sink, gpointer user_data);
    void processSample(GstSample *sample);
    void enumerateWebcams();

    GstElement *pipeline;
    GstAppSink *appsink;
    VideoItem *m_videoItem;
    bool m_isStreaming = false;
    bool m_isRecording = false;
    QStringList m_webcamList;
    int m_selectedWebcamIndex = 0;
};

#endif
