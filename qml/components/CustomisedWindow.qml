import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion

Window {
    id: customWindow
    visible: true
    color: "#333333"
    flags: Qt.FramelessWindowHint
    minimumWidth: 400
    minimumHeight: 300

    // Properties for customization
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true
    property bool showToolbar: true
    property bool resizeEnabled: true
    property string title: ""
    property real toolbarHeight: showToolbar ? toolbarLoader.height : 0

    // Custom window frame (border)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#555555"
        border.width: 2
    }

    // Toolbar (loaded dynamically)
    Loader {
        id: toolbarLoader
        active: showToolbar
        width: parent.width
        source: "qrc:/qml/components/MainToolbar.qml"
        onLoaded: {
            item.title = Qt.binding(function() { return customWindow.title })
            item.window = Qt.binding(function() { return customWindow })
            item.resizeBorder = Qt.binding(function() { return resizeBorder })
            item.showMinimizeButton = Qt.binding(function() { return showMinimizeButton })
            item.showMaximizeButton = Qt.binding(function() { return showMaximizeButton })
            item.showCloseButton = Qt.binding(function() { return showCloseButton })
        }
    }

    // Resizing MouseAreas
    property int resizeBorder: 5

    // Left edge
    MouseArea {
        enabled: resizeEnabled
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
                var newWidth = customWindow.width - deltaX
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.x += deltaX
                    customWindow.width = newWidth
                } else {
                    customWindow.x += customWindow.width - customWindow.minimumWidth
                    customWindow.width = customWindow.minimumWidth
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Right edge
    MouseArea {
        enabled: resizeEnabled
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
                var newWidth = customWindow.width + deltaX
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.width = newWidth
                } else {
                    customWindow.width = customWindow.minimumWidth
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top edge
    MouseArea {
        enabled: resizeEnabled
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
                var newHeight = customWindow.height - deltaY
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.y += deltaY
                    customWindow.height = newHeight
                } else {
                    customWindow.y += customWindow.height - customWindow.minimumHeight
                    customWindow.height = customWindow.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom edge
    MouseArea {
        enabled: resizeEnabled
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
                var newHeight = customWindow.height + deltaY
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.height = newHeight
                } else {
                    customWindow.height = customWindow.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom-left corner
    MouseArea {
        enabled: resizeEnabled
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
                var newWidth = customWindow.width - deltaX
                var newHeight = customWindow.height + deltaY
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.x += deltaX
                    customWindow.width = newWidth
                } else {
                    customWindow.x += customWindow.width - customWindow.minimumWidth
                    customWindow.width = customWindow.minimumWidth
                }
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.height = newHeight
                } else {
                    customWindow.height = customWindow.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Bottom-right corner
    MouseArea {
        enabled: resizeEnabled
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
                var newWidth = customWindow.width + deltaX
                var newHeight = customWindow.height + deltaY
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.width = newWidth
                } else {
                    customWindow.width = customWindow.minimumWidth
                }
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.height = newHeight
                } else {
                    customWindow.height = customWindow.minimumHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top-left corner
    MouseArea {
        enabled: resizeEnabled
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
                var newWidth = customWindow.width - deltaX
                var newHeight = customWindow.height - deltaY
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.x += deltaX
                    customWindow.width = newWidth
                } else {
                    customWindow.x += customWindow.width - customWindow.minimumWidth
                    customWindow.width = customWindow.minimumWidth
                }
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.y += deltaY
                    customWindow.height = newHeight
                } else {
                    customWindow.y += customWindow.height - customWindow.minimumHeight
                    customWindow.height = newHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }

    // Top-right corner
    MouseArea {
        enabled: resizeEnabled
        anchors.right: parent.right
        anchors.top: parent.top
        width: resizeBorder
        height: resizeBorder
        cursorShape: Qt.SizeBDiagCursor
        z: 1
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) {
            lastMousePos = Qt.point(0, 0)
            mouse.accepted = true
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                var deltaX = mouse.x - lastMousePos.x
                var deltaY = mouse.y - lastMousePos.y
                var newWidth = customWindow.width + deltaX
                var newHeight = customWindow.height - deltaY
                if (newWidth >= customWindow.minimumWidth) {
                    customWindow.width = newWidth
                } else {
                    customWindow.width = customWindow.minimumWidth
                }
                if (newHeight >= customWindow.minimumHeight) {
                    customWindow.y += deltaY
                    customWindow.height = newHeight
                } else {
                    customWindow.y += customWindow.height - customWindow.minimumHeight
                    customWindow.height = newHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }
}
