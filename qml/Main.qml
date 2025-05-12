import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import "../../qml/components"

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

    // Custom window frame (border)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#666666"
        border.width: 1
    }

    // Custom title bar
    MainToolbar {
        id: mainToolbar
        width: parent.width
        title: window.title
        window: window
        resizeBorder: resizeBorder
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
        toolbarHeight: mainToolbar.height
    }
}
