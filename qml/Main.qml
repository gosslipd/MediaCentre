import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion // Use Fusion style for customization
import MediaCentre 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: "Webcam Streamer"
    color: "#333333" // Dark grey background
    flags: Qt.FramelessWindowHint // Remove default system frame
    minimumWidth: 400 // Minimum window width
    minimumHeight: 300 // Minimum window height

    // Define a reusable StyledButton type
    component StyledButton: Button {
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? "#555555" : "#444444" // Lighter grey on hover
            border.color: "#666666"
            border.width: 1
            radius: 10 // Rounded corners
        }
    }

    // Custom window frame (border)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#666666" // Match button border color
        border.width: 1
    }

    // Custom title bar
    Rectangle {
        id: titleBar
        width: parent.width
        height: 40
        color: "#444444" // Match button background
        anchors.top: parent.top

        // Title text
        Text {
            text: window.title
            color: "white"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        // Window control buttons
        Row {
            id: buttonRow
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            StyledButton {
                text: "−" // Minimize
                width: 35
                height: 35
                onPressed: console.log("Minimize pressed")
                onReleased: console.log("Minimize released")
                onClicked: {
                    console.log("Minimize clicked")
                    window.showMinimized()
                }
            }

            StyledButton {
                text: window.visibility === Window.Maximized ? "🗗" : "🗖" // Maximize/Restore
                width: 35
                height: 35
                onPressed: console.log("Maximize pressed")
                onReleased: console.log("Maximize released")
                onClicked: {
                    console.log("Maximize/Restore clicked, current visibility:", window.visibility)
                    if (window.visibility === Window.Maximized) {
                        window.showNormal()
                    } else {
                        window.showMaximized()
                    }
                }
            }

            StyledButton {
                text: "✕" // Close
                width: 35
                height: 35
                onPressed: console.log("Close pressed")
                onReleased: console.log("Close released")
                onClicked: {
                    console.log("Close clicked")
                    Qt.quit()
                }
            }
        }

        // Dragging functionality (exclude button area)
        MouseArea {
            anchors.left: parent.left
            anchors.right: buttonRow.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            property point lastMousePos: Qt.point(0, 0)
            onPressed: function(mouse) {
                lastMousePos = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true
            }
            onPositionChanged: function(mouse) {
                if (pressed) {
                    var deltaX = mouse.x - lastMousePos.x
                    var deltaY = mouse.y - lastMousePos.y
                    window.x += deltaX
                    window.y += deltaY
                }
            }
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
        onRecordVolumeChanged: {
            console.log("Record volume changed:", webcamHandler.recordVolume)
        }
        Component.onCompleted: {
            webcamHandler.setVideoItem(videoItem)
        }
    }

    // Resizing MouseAreas
    // Border width for resizing
    property int resizeBorder: 5

    // Left edge
    MouseArea {
        anchors.left: parent.left
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        width: resizeBorder
        cursorShape: Qt.SizeHorCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var newWidth = window.width - deltaX
                if (newWidth >= window.minimumWidth) {
                    window.x += deltaX
                    window.width = newWidth
                } else {
                    window.x += window.width - window.minimumWidth
                    window.width = window.minimumWidth
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Right edge
    MouseArea {
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        width: resizeBorder
        cursorShape: Qt.SizeHorCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var newWidth = window.width + deltaX
                if (newWidth >= window.minimumWidth) {
                    window.width = newWidth
                } else {
                    window.width = window.minimumWidth
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top edge (below title bar)
    MouseArea {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: resizeBorder
        cursorShape: Qt.SizeVerCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaY = mouse.y - lastMousePos.y
                var newHeight = window.height - deltaY
                if (newHeight >= window.minimumHeight) {
                    window.y += deltaY
                    window.height = newHeight
                } else {
                    window.y += window.height - window.minimumHeight
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom edge
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: resizeBorder
        cursorShape: Qt.SizeVerCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaY = mouse.y - lastMousePos.y
                var newHeight = window.height + deltaY
                if (newHeight >= window.minimumHeight) {
                    window.height = newHeight
                } else {
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom-left corner
    MouseArea {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeBDiagCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var deltaY = mouse.y - lastMousePos.y
                var newWidth = window.width - deltaX
                var newHeight = window.height + deltaY
                if (newWidth >= window.minimumWidth) {
                    window.x += deltaX
                    window.width = newWidth
                } else {
                    window.x += window.width - window.minimumWidth
                    window.width = window.minimumWidth
                }
                if (newHeight >= window.minimumHeight) {
                    window.height = newHeight
                } else {
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom-right corner
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeFDiagCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var deltaY = mouse.y - lastMousePos.y
                var newWidth = window.width + deltaX
                var newHeight = window.height + deltaY
                if (newWidth >= window.minimumWidth) {
                    window.width = newWidth
                } else {
                    window.width = window.minimumWidth
                }
                if (newHeight >= window.minimumHeight) {
                    window.height = newHeight
                } else {
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top-left corner
    MouseArea {
        anchors.left: parent.left
        anchors.top: titleBar.bottom
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeFDiagCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var deltaY = mouse.y - lastMousePos.y
                var newWidth = window.width - deltaX
                var newHeight = window.height - deltaY
                if (newWidth >= window.minimumWidth) {
                    window.x += deltaX
                    window.width = newWidth
                } else {
                    window.x += window.width - window.minimumWidth
                    window.width = window.minimumWidth
                }
                if (newHeight >= window.minimumHeight) {
                    window.y += deltaY
                    window.height = newHeight
                } else {
                    window.y += window.height - window.minimumHeight
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top-right corner
    MouseArea {
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeBDiagCursor
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var deltaY = mouse.y - lastMousePos.y
                var newWidth = window.width + deltaX
                var newHeight = window.height - deltaY
                if (newWidth >= window.minimumWidth) {
                    window.width = newWidth
                } else {
                    window.width = window.minimumWidth
                }
                if (newHeight >= window.minimumHeight) {
                    window.y += deltaY
                    window.height = newHeight
                } else {
                    window.y += window.height - window.minimumHeight
                    window.height = window.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: titleBar.height // Offset for title bar
        spacing: 10

        VideoItem {
            id: videoItem
            width: parent.width
            height: parent.height - 180 - titleBar.height // Adjusted for extra Row
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

                // Style CheckBox for dark theme
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

                // Style CheckBox for dark theme
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
