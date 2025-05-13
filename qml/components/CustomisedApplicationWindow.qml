import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion

ApplicationWindow {
    id: appWindow
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

    // Reference to MainContent's dialogs list
    property var dialogs: mainContent ? mainContent.dialogs : []

    // Handle window closing
    onClosing: {
        console.log("Main window closing, closing", dialogs.length, "dialogs")
        for (var i = 0; i < dialogs.length; ++i) {
            if (dialogs[i]) {
                dialogs[i].close()
            }
        }
        dialogs = [] // Clear the list
    }

    // Custom window frame (border)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#444444"
        border.width: 1
    }

    // Main content
    MainContent {
        id: mainContent
        anchors.fill: parent
        toolbarHeight: appWindow.toolbarHeight
    }

    // Toolbar (loaded dynamically)
    Loader {
        id: toolbarLoader
        active: showToolbar
        width: parent.width
        source: "qrc:/qml/components/MainToolbar.qml"
        onLoaded: {
            item.title = Qt.binding(function() { return appWindow.title })
            item.window = Qt.binding(function() { return appWindow })
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
                var newWidth = appWindow.width - deltaX
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.x += deltaX
                    appWindow.width = newWidth
                } else {
                    appWindow.x += appWindow.width - appWindow.minimumWidth
                    appWindow.width = appWindow.minimumWidth
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
                var newWidth = appWindow.width + deltaX
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.width = newWidth
                } else {
                    appWindow.width = appWindow.minimumWidth
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
                var newHeight = appWindow.height - deltaY
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.y += deltaY
                    appWindow.height = newHeight
                } else {
                    appWindow.y += appWindow.height - appWindow.minimumHeight
                    appWindow.height = appWindow.minimumHeight
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
                var newHeight = appWindow.height + deltaY
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.height = newHeight
                } else {
                    appWindow.height = appWindow.minimumHeight
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
                var newWidth = appWindow.width - deltaX
                var newHeight = appWindow.height + deltaY
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.x += deltaX
                    appWindow.width = newWidth
                } else {
                    appWindow.x += appWindow.width - appWindow.minimumWidth
                    appWindow.width = appWindow.minimumWidth
                }
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.height = newHeight
                } else {
                    appWindow.height = appWindow.minimumHeight
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
                var newWidth = appWindow.width + deltaX
                var newHeight = appWindow.height + deltaY
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.width = newWidth
                } else {
                    appWindow.width = appWindow.minimumWidth
                }
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.height = newHeight
                } else {
                    appWindow.height = appWindow.minimumHeight
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
                var newWidth = appWindow.width - deltaX
                var newHeight = appWindow.height - deltaY
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.x += deltaX
                    appWindow.width = newWidth
                } else {
                    appWindow.x += appWindow.width - appWindow.minimumWidth
                    appWindow.width = appWindow.minimumWidth
                }
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.y += deltaY
                    appWindow.height = newHeight
                } else {
                    appWindow.y += appWindow.height - appWindow.minimumHeight
                    appWindow.height = newHeight
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
                var newWidth = appWindow.width + deltaX
                var newHeight = appWindow.height - deltaY
                if (newWidth >= appWindow.minimumWidth) {
                    appWindow.width = newWidth
                } else {
                    appWindow.width = appWindow.minimumWidth
                }
                if (newHeight >= appWindow.minimumHeight) {
                    appWindow.y += deltaY
                    appWindow.height = newHeight
                } else {
                    appWindow.y += appWindow.height - appWindow.minimumHeight
                    appWindow.height = newHeight
                }
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
        }
    }
}
