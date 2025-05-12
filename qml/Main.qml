import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import MediaCentre 1.0
import "../../qml/components" // Import components directory

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: "Webcam Streamer"
    color: "#333333"
    flags: Qt.FramelessWindowHint
    minimumWidth: 400
    minimumHeight: 300

    // Define StyledButton (kept for consistency, though not used here)
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

    // Custom window frame (border)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#666666"
        border.width: 1
    }

    // Custom title bar
    Rectangle {
        id: titleBar
        width: parent.width
        height: 40
        color: "#444444"
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
                text: "−"
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
                text: window.visibility === Window.Maximized ? "🗗" : "🗖"
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
                text: "✕"
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

        // Dragging functionality (exclude button area and top resize border)
        MouseArea {
            anchors.left: parent.left
            anchors.right: buttonRow.left
            anchors.top: parent.top
            anchors.topMargin: resizeBorder
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
            onDoubleClicked: {
                console.log("Title bar double-clicked, current visibility:", window.visibility)
                if (window.visibility === Window.Maximized) {
                    window.showNormal()
                } else {
                    window.showMaximized()
                }
            }
        }
    }

    // Resizing MouseAreas
    property int resizeBorder: 5

    // Left edge
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: resizeBorder
        cursorShape: Qt.SizeHorCursor
        z: 1
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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: resizeBorder
        cursorShape: Qt.SizeHorCursor
        z: 1
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

    // Top edge
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: resizeBorder
        cursorShape: Qt.SizeVerCursor
        z: 1
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
        z: 1
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
        z: 1
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
        z: 1
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
        anchors.top: parent.top
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeFDiagCursor
        z: 1
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
                    window.height = newHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top-right corner
    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeBDiagCursor
        z: 1
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
                    window.height = newHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    MainContent {
        anchors.fill: parent
        titleBarHeight: titleBar.height
    }
}
