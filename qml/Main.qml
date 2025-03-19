import QtQuick 6.8
import QtQuick.Controls 6.8
import QtMultimedia 6.8

import MediaCentre 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Webcam Streamer"

    WebcamHandler {
        id: webcamHandler
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Button {
            text: webcamHandler.isStreaming ? "Stop Streaming" : "Start Streaming"
            onClicked: webcamHandler.isStreaming ? webcamHandler.stopStreaming() : webcamHandler.startStreaming()
        }

        Button {
            text: "Start Recording"
            enabled: webcamHandler.isStreaming && !webcamHandler.isRecording
            onClicked: webcamHandler.startRecording()
        }

        Button {
            text: "Stop Recording"
            enabled: webcamHandler.isRecording
            onClicked: webcamHandler.stopRecording()
        }

        Button {
            text: "Playback Recording"
            onClicked: webcamHandler.playback("recording.mp4")
        }
    }
}