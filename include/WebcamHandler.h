#ifndef WEBCAMHANDLER_H
#define WEBCAMHANDLER_H

#include <QObject>
#include <gst/gst.h>

class WebcamHandler : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isStreaming READ isStreaming NOTIFY isStreamingChanged)
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)

public:
    explicit WebcamHandler(QObject *parent = nullptr);
    ~WebcamHandler();

    bool isStreaming() const { return m_isStreaming; }
    bool isRecording() const { return m_isRecording; }

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
    GstElement *pipeline;
    GstElement *videosink;
    bool m_isStreaming = false;
    bool m_isRecording = false;
};

#endif
