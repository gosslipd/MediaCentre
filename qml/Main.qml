import QtQuick
import QtQuick.Controls
import MediaCentre 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Webcam Streamer"
    color: "#333333" // Dark grey background

    // Define a reusable StyledButton type
    component StyledButton: Button {
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: "#444444" // Dark grey background
            border.color: "#666666"
            border.width: 1
            radius: 10 // Rounded corners
        }
    }

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

                // Style ComboBox for white text and dark background
                contentItem: Text {
                    text: webcamCombo.displayText
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    color: "#444444" // Slightly lighter dark grey for contrast
                    border.color: "#666666"
                    border.width: 1
                    radius: 5
                }

                // Add visible down-arrow indicator
                indicator: Canvas {
                    id: canvas
                    x: webcamCombo.width - width - webcamCombo.rightPadding
                    y: webcamCombo.topPadding + (webcamCombo.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = "white"; // White arrow for visibility
                        context.fill();
                    }
                }

                popup: Popup {
                    y: webcamCombo.height
                    width: webcamCombo.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: webcamCombo.delegateModel
                        currentIndex: webcamCombo.highlightedIndex
                        ScrollIndicator.vertical: ScrollIndicator {}
                    }

                    background: Rectangle {
                        color: "#444444" // Match ComboBox background
                        border.color: "#666666"
                        border.width: 1
                        radius: 5
                    }
                }

                delegate: ItemDelegate {
                    width: webcamCombo.width
                    contentItem: Text {
                        text: modelData
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: highlighted ? "#555555" : "#444444"
                    }
                }
            }

            StyledButton {
                text: webcamHandler.isStreaming ? "Stop Streaming" : "Start Streaming"
                onClicked: webcamHandler.isStreaming ? webcamHandler.stopStreaming() : webcamHandler.startStreaming()
            }

            StyledButton {
                text: "Start Recording"
                enabled: webcamHandler.isStreaming && !webcamHandler.isRecording
                onClicked: webcamHandler.startRecording()
            }

            StyledButton {
                text: "Stop Recording"
                enabled: webcamHandler.isRecording
                onClicked: webcamHandler.stopRecording()
            }

            StyledButton {
                text: "Playback Recording"
                onClicked: webcamHandler.playback("recording.mkv")
            }
        }
    }
}
