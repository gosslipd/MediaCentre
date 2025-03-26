import QtQuick 6.8
import QtQuick.Controls 6.8
import QtMultimedia 6.8

import MediaCentre 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Media Centre"

    WebcamHandler {
        id: webcam
        onIsStreamingChanged: {
            console.log("Streaming state:", webcam.isStreaming)
        }
        onIsRecordingChanged: {  // New handler
            console.log("Recording state:", webcam.isRecording)
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
             id: statusText
             text: "Streaming: " + (webcam.isStreaming ? "Yes" : "No") +
                   " | Recording: " + (webcam.isRecording ? "Yes" : "No")
        }

        Button {
            text: webcam.isStreaming ? "Stop Streaming" : "Start Streaming"
            onClicked: webcam.isStreaming ? webcam.stopStreaming() : webcam.startStreaming()
        }

        Button {
            text: "Start Recording"
            enabled: webcam.isStreaming && !webcam.isRecording
            onClicked: webcam.startRecording()
        }

        Button {
            text: "Stop Recording"
            enabled: webcam.isRecording
            onClicked: webcam.stopRecording()
        }

        Button {
            text: "Playback Recording"
            onClicked: webcam.playback("recording.mp4")
        }
    }
}
