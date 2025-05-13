import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import MediaCentre 1.0

Item {
    id: mainContent
    anchors.fill: parent

    // Property for toolbar height
    property real toolbarHeight: 0

    // WebcamHandler instance
    WebcamHandler {
        id: webcamHandler
        onIsStreamingChanged: {
            console.log("Streaming state:", webcamHandler.isStreaming)
        }
        onIsRecordingChanged: {
            console.log("Recording state:", webcamHandler.isRecording)
        }
        onRecordVolumeChanged: {
            console.log("Record volume changed:", webcamHandler.recordVolume)
        }
        Component.onCompleted: {
            webcamHandler.setVideoItem(videoItem)
        }
    }

    // Define StyledButton
    component StyledButton: Button {
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? "#555555" : "#444444"
            border.color: "#666666"
            border.width: 1
            radius: 10
        }
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: toolbarHeight
        spacing: 10

        VideoItem {
            id: videoItem
            width: parent.width
            height: parent.height - 180 - toolbarHeight
            onSmoothScalingChanged: {
                console.log("Smooth scaling:", videoItem.smoothScaling)
            }
            onMirrorHorizontallyChanged: {
                console.log("Horizontal mirroring:", videoItem.mirrorHorizontally)
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            StyledButton {
                text: "Open Config"
                onClicked: {
                    var component = Qt.createComponent("qrc:/qml/components/ConfigDialog.qml")
                    if (component.status === Component.Ready) {
                        var dialog = component.createObject(null)
                        dialog.show()
                    } else {
                        console.error("Error loading ConfigDialog:", component.errorString())
                    }
                }
            }

            ComboBox {
                id: webcamCombo
                model: webcamHandler.webcamList
                currentIndex: webcamHandler.selectedWebcamIndex
                onCurrentIndexChanged: {
                    webcamHandler.setSelectedWebcamIndex(currentIndex)
                }
                width: 200

                contentItem: Text {
                    text: webcamCombo.displayText
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    color: "#444444"
                    border.color: "#666666"
                    border.width: 1
                    radius: 5
                }

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
                        context.fillStyle = "white";
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
                        color: "#444444"
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
                onPressed: console.log("Streaming button pressed")
                onReleased: console.log("Streaming button released")
                onClicked: webcamHandler.isStreaming ? webcamHandler.stopStreaming() : webcamHandler.startStreaming()
            }

            StyledButton {
                text: "Start Recording"
                enabled: webcamHandler.isStreaming && !webcamHandler.isRecording
                onPressed: console.log("Start Recording pressed")
                onReleased: console.log("Start Recording released")
                onClicked: webcamHandler.startRecording()
            }

            StyledButton {
                text: "Stop Recording"
                enabled: webcamHandler.isRecording
                onPressed: console.log("Stop Recording pressed")
                onReleased: console.log("Stop Recording released")
                onClicked: webcamHandler.stopRecording()
            }

            StyledButton {
                text: "Playback Recording"
                onPressed: console.log("Playback pressed")
                onReleased: console.log("Playback released")
                onClicked: webcamHandler.playback("recording.mkv")
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                text: "Record volume"
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            Slider {
                id: volumeSlider
                from: 0.0
                to: 4.0
                value: webcamHandler.recordVolume
                stepSize: 0.1
                width: 200
                onValueChanged: {
                    webcamHandler.setRecordVolume(value)
                }

                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: "#444444"

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: "#666666"
                        radius: 2
                    }
                }

                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: volumeSlider.pressed ? "#555555" : "#666666"
                    border.color: "#777777"
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                text: "Enable Smooth Scaling"
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            CheckBox {
                id: smoothScalingCheckBox
                checked: videoItem.smoothScaling
                onCheckedChanged: {
                    videoItem.smoothScaling = checked
                    console.log("Smooth scaling checkbox:", checked)
                }

                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: smoothScalingCheckBox.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    border.color: "#666666"
                    color: "#444444"

                    Rectangle {
                        width: 14
                        height: 14
                        x: 6
                        y: 6
                        radius: 2
                        color: smoothScalingCheckBox.checked ? "#666666" : "#444444"
                        visible: smoothScalingCheckBox.checked
                    }
                }

                contentItem: Text {
                    text: ""
                    leftPadding: smoothScalingCheckBox.indicator.width + smoothScalingCheckBox.spacing
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                text: "Enable Horizontal Mirroring"
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            CheckBox {
                id: mirrorHorizontallyCheckBox
                checked: videoItem.mirrorHorizontally
                onCheckedChanged: {
                    videoItem.mirrorHorizontally = checked
                    console.log("Horizontal mirroring checkbox:", checked)
                }

                indicator: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    x: mirrorHorizontallyCheckBox.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    border.color: "#666666"
                    color: "#444444"

                    Rectangle {
                        width: 14
                        height: 14
                        x: 6
                        y: 6
                        radius: 2
                        color: mirrorHorizontallyCheckBox.checked ? "#666666" : "#444444"
                        visible: mirrorHorizontallyCheckBox.checked
                    }
                }

                contentItem: Text {
                    text: ""
                    leftPadding: mirrorHorizontallyCheckBox.indicator.width + mirrorHorizontallyCheckBox.spacing
                }
            }
        }
    }
}
