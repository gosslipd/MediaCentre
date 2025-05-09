#include "WebcamHandler.h"
#include "VideoItem.h"
#include <gst/gst.h>
#include <gst/app/gstappsink.h>
#include <gst/video/video.h>
#include <QDebug>
#ifdef Q_OS_WIN
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <combaseapi.h>
#endif

WebcamHandler::WebcamHandler(QObject *parent)
    : QObject(parent), pipeline(nullptr), appsink(nullptr), m_videoItem(nullptr), m_selectedWebcamIndex(0), m_recordVolume(1.0) {
    //g_setenv("GST_DEBUG", "4", TRUE);
    g_setenv("GST_PLUGIN_PATH", "C:/gstreamer/1.0/msvc_x86_64/lib/gstreamer-1.0;C:/CMakeBuildFolder/MediaCentre/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Release/Release/gstreamer-1.0", TRUE);
    g_setenv("GST_PLUGIN_SYSTEM_PATH", "", TRUE); // Disable system-wide plugin scanning (removes warnings)
    g_setenv("GI_TYPELIB_PATH", "", TRUE); // Disable GObject introspection (removes warnings)
    g_setenv("GST_PLUGIN_BLACKLIST", "python", TRUE); // Blacklist python plugin (removes warnings)
    gst_init(nullptr, nullptr);
#ifdef Q_OS_WIN
    CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    MFStartup(MF_VERSION, MFSTARTUP_FULL);
#endif
    enumerateWebcams();
}

WebcamHandler::~WebcamHandler() {
    stopStreaming();
    gst_deinit();
#ifdef Q_OS_WIN
    MFShutdown();
    CoUninitialize();
#endif
}

void WebcamHandler::setVideoItem(VideoItem *item) {
    m_videoItem = item;
}

void WebcamHandler::enumerateWebcams() {
#ifdef Q_OS_WIN
    m_webcamList.clear();
    IMFAttributes *pAttributes = nullptr;
    IMFActivate **ppDevices = nullptr;
    UINT32 count = 0;

    HRESULT hr = MFCreateAttributes(&pAttributes, 1);
    if (SUCCEEDED(hr)) {
        hr = pAttributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
    }

    if (SUCCEEDED(hr)) {
        hr = MFEnumDeviceSources(pAttributes, &ppDevices, &count);
    }

    if (SUCCEEDED(hr)) {
        for (UINT32 i = 0; i < count; ++i) {
            WCHAR *name = nullptr;
            hr = ppDevices[i]->GetAllocatedString(MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME, &name, nullptr);
            if (SUCCEEDED(hr)) {
                m_webcamList.append(QString::fromWCharArray(name));
                CoTaskMemFree(name);
            }
            ppDevices[i]->Release();
        }
        CoTaskMemFree(ppDevices);
    }

    if (pAttributes) {
        pAttributes->Release();
    }

    if (m_webcamList.isEmpty()) {
        m_webcamList.append("No webcams detected");
        m_selectedWebcamIndex = -1;
    } else {
        m_selectedWebcamIndex = 0;
    }

    qDebug() << "Detected webcams:" << m_webcamList;
    emit webcamListChanged();
#else
    m_webcamList = QStringList{"Default Webcam"};
    m_selectedWebcamIndex = 0;
    emit webcamListChanged();
#endif
}

void WebcamHandler::startStreaming() {
    if (m_selectedWebcamIndex < 0) {
        qCritical() << "No valid webcam selected";
        return;
    }

    const char *pipeline_str =
#ifdef Q_OS_WIN
        QString("mfvideosrc device-index=%1 ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! videoconvert ! video/x-raw,format=RGB ! queue ! appsink name=appsink emit-signals=true")
            .arg(m_selectedWebcamIndex).toUtf8().constData()
#else
        "v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,format=RGB,width=640,height=480 ! queue ! appsink name=appsink emit-signals=true"
#endif
        ;

    qDebug() << "Creating streaming pipeline:" << pipeline_str;
    GError *error = nullptr;
    pipeline = gst_parse_launch(pipeline_str, &error);
    if (!pipeline || error) {
        qCritical() << "Failed to create pipeline:" << (error ? error->message : "Unknown error");
        if (error) g_error_free(error);
        if (pipeline) {
            gst_object_unref(pipeline);
            pipeline = nullptr;
        }
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
        gst_object_unref(appsink);
        gst_object_unref(pipeline);
        appsink = nullptr;
        pipeline = nullptr;
        return;
    }

    qDebug() << "Pipeline started successfully";
    m_isStreaming = true;
    emit isStreamingChanged();
}

void WebcamHandler::stopStreaming() {
    if (!m_isStreaming) return;

    qDebug() << "Stopping streaming...";
    if (pipeline) {
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(pipeline);
        pipeline = nullptr;
        qDebug() << "Pipeline unreferenced";
    }
    if (appsink) {
        gst_object_unref(appsink);
        appsink = nullptr;
        qDebug() << "Appsink unreferenced";
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
        QString("mfvideosrc device-index=%1 ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! videoconvert ! video/x-raw,format=I420 ! "
                "tee name=t ! queue leaky=downstream ! x264enc tune=zerolatency key-int-max=30 ! matroskamux name=mux ! filesink location=recording.mkv "
                "t. ! queue ! videoconvert ! video/x-raw,format=RGB ! queue ! appsink name=appsink emit-signals=true "
                "wasapisrc ! audioconvert ! volume volume=%2 ! avenc_aac bitrate=128000 ! queue ! mux.")
            .arg(m_selectedWebcamIndex).arg(m_recordVolume).toUtf8().constData()
#else
        QString("v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,format=I420,width=640,height=480 ! "
                "tee name=t ! queue leaky=downstream ! x264enc tune=zerolatency key-int-max=30 ! matroskamux name=mux ! filesink location=recording.mkv "
                "t. ! queue ! videoconvert ! video/x-raw,format=RGB ! queue ! appsink name=appsink emit-signals=true "
                "alsasrc ! audioconvert ! volume volume=%1 ! avenc_aac bitrate=128000 ! queue ! mux.")
            .arg(m_recordVolume).toUtf8().constData()
#endif
        ;

    qDebug() << "Creating recording pipeline:" << pipeline_str;
    GError *error = nullptr;
    pipeline = gst_parse_launch(pipeline_str, &error);
    if (!pipeline || error) {
        qCritical() << "Failed to create recording pipeline:" << (error ? error->message : "Unknown error");
        if (error) g_error_free(error);
        if (pipeline) {
            gst_object_unref(pipeline);
            pipeline = nullptr;
        }
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
        qCritical() << "Failed to start recording";
        gst_object_unref(appsink);
        gst_object_unref(pipeline);
        appsink = nullptr;
        pipeline = nullptr;
        return;
    }

    qDebug() << "Recording started successfully";
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
                               "filesrc location=%1 ! matroskademux name=demux "
                               "demux. ! queue ! decodebin name=video_decoder ! videoconvert ! video/x-raw,format=RGB ! appsink name=appsink emit-signals=true "
                               "demux. ! queue ! decodebin name=audio_decoder ! audioconvert ! autoaudiosink"
#else
                               "filesrc location=%1 ! matroskademux name=demux "
                               "demux. ! queue ! decodebin name=video_decoder ! videoconvert ! video/x-raw,format=RGB ! appsink name=appsink emit-signals=true "
                               "demux. ! queue ! decodebin name=audio_decoder ! audioconvert ! autoaudiosink"
#endif
                               ).arg(filePath);

    qDebug() << "Creating playback pipeline:" << pipeline_str;
    GError *error = nullptr;
    pipeline = gst_parse_launch(pipeline_str.toUtf8().constData(), &error);
    if (!pipeline || error) {
        qCritical() << "Failed to create playback pipeline:" << (error ? error->message : "Unknown error");
        if (error) g_error_free(error);
        if (pipeline) {
            gst_object_unref(pipeline);
            pipeline = nullptr;
        }
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
        qCritical() << "Failed to start playback";
        gst_object_unref(appsink);
        gst_object_unref(pipeline);
        appsink = nullptr;
        pipeline = nullptr;
        return;
    }

    qDebug() << "Playback started successfully";
    m_isStreaming = true;
    emit isStreamingChanged();
}

void WebcamHandler::setSelectedWebcamIndex(int index) {
    if (index < 0 || index >= m_webcamList.size() || index == m_selectedWebcamIndex) {
        return;
    }

    qDebug() << "Selected webcam index:" << index;
    m_selectedWebcamIndex = index;
    emit selectedWebcamIndexChanged();

    if (m_isStreaming) {
        bool wasRecording = m_isRecording;
        stopStreaming();
        startStreaming();
        if (wasRecording) {
            startRecording();
        }
    }
}

void WebcamHandler::setRecordVolume(double volume) {
    if (volume < 0.0) volume = 0.0;
    if (volume > 4.0) volume = 4.0; // Cap at 4.0 to prevent excessive amplification
    if (m_recordVolume != volume) {
        m_recordVolume = volume;
        qDebug() << "Record volume set to:" << m_recordVolume;
        emit recordVolumeChanged();
    }
}

struct SampleDeleter {
    void operator()(GstSample *sample) const {
        if (sample) {
            gst_sample_unref(sample);
            qDebug() << "GstSample unreferenced";
        }
    }
};

GstFlowReturn WebcamHandler::onNewSample(GstAppSink *sink, gpointer user_data) {
    WebcamHandler *self = static_cast<WebcamHandler *>(user_data);
    GstSample *sample = gst_app_sink_pull_sample(sink);
    if (!sample) {
        qWarning() << "Failed to pull sample";
        return GST_FLOW_ERROR;
    }

    // Use RAII to ensure sample is unreferenced
    std::unique_ptr<GstSample, SampleDeleter> sampleGuard(sample);

    // Post to GUI thread
    bool invoked = QMetaObject::invokeMethod(self, [self, sample = sampleGuard.get()]() {
        self->processSample(sample);
    }, Qt::QueuedConnection);

    if (!invoked) {
        qWarning() << "Failed to invoke processSample";
        return GST_FLOW_ERROR;
    }

    return GST_FLOW_OK;
}

void WebcamHandler::processSample(GstSample *sample) {
    GstBuffer *buffer = gst_sample_get_buffer(sample);
    if (!buffer) {
        qWarning() << "No buffer in sample";
        return;
    }

    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_READ)) {
        qWarning() << "Failed to map buffer";
        return;
    }

    GstCaps *caps = gst_sample_get_caps(sample);
    GstVideoInfo vinfo;
    gst_video_info_init(&vinfo);
    if (!gst_video_info_from_caps(&vinfo, caps)) {
        qWarning() << "Failed to get video info";
        gst_buffer_unmap(buffer, &map);
        return;
    }

    // Expect RGB888: 3 bytes per pixel
    qint64 expected_size = static_cast<qint64>(vinfo.width) * vinfo.height * 3;
    //qDebug() << "Buffer size:" << map.size << ", expected:" << expected_size
    //         << ", format:" << vinfo.finfo->name << ", width:" << vinfo.width << ", height:" << vinfo.height;
    if (map.size < expected_size) {
        qWarning() << "Buffer size too small:" << map.size << ", expected:" << expected_size;
        gst_buffer_unmap(buffer, &map);
        return;
    }

    if (m_videoItem) {
        //qDebug() << "Updating frame: width=" << vinfo.width << ", height=" << vinfo.height;
        m_videoItem->updateFrame(map.data, vinfo.width, vinfo.height);
    }

    gst_buffer_unmap(buffer, &map);
}

