import QtQuick
import QtQuick.Controls
import MediaCentre 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Webcam Streamer"

    WebcamHandler {
        id: webcamHandler
        onIsStreamingChanged: {
            console.log("Streaming state:", webcamHandler.isStreaming)
        }
        onIsRecordingChanged: {
            console.log("Recording state:", webcamHandler.isRecording)
        }
        Component.onCompleted: {
            webcamHandler.setVideoItem(videoItem)
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        VideoItem {
            id: videoItem
            width: parent.width
            height: parent.height - 150
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ComboBox {
                id: webcamCombo
                model: webcamHandler.webcamList
                currentIndex: webcamHandler.selectedWebcamIndex
                onCurrentIndexChanged: {
                    webcamHandler.setSelectedWebcamIndex(currentIndex)
                }
                width: 200
            }

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
                onClicked: webcamHandler.playback("recording.mkv")
            }
        }
    }
}
