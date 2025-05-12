import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion

Item {
    id: mainToolbar
    height: 40 // Match original title bar height

    // Properties to expose window title, window object, and resize border
    property string title: ""
    property var window: null
    property int resizeBorder: 0

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

    // Title bar rectangle
    Rectangle {
        anchors.fill: parent
        color: "#444444"

        // Title text
        Text {
            text: mainToolbar.title
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
                    if (mainToolbar.window) {
                        mainToolbar.window.showMinimized()
                    }
                }
            }

            StyledButton {
                text: mainToolbar.window && mainToolbar.window.visibility === Window.Maximized ? "🗗" : "🗖"
                width: 35
                height: 35
                onPressed: console.log("Maximize pressed")
                onReleased: console.log("Maximize released")
                onClicked: {
                    console.log("Maximize/Restore clicked, current visibility:", mainToolbar.window ? mainToolbar.window.visibility : "null")
                    if (mainToolbar.window) {
                        if (mainToolbar.window.visibility === Window.Maximized) {
                            mainToolbar.window.showNormal()
                        } else {
                            mainToolbar.window.showMaximized()
                        }
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
            anchors.topMargin: mainToolbar.resizeBorder
            anchors.bottom: parent.bottom
            property point lastMousePos: Qt.point(0, 0)
            onPressed: function(mouse) {
                lastMousePos = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true
            }
            onPositionChanged: function(mouse) {
                if (pressed && mainToolbar.window) {
                    var deltaX = mouse.x - lastMousePos.x
                    var deltaY = mouse.y - lastMousePos.y
                    mainToolbar.window.x += deltaX
                    mainToolbar.window.y += deltaY
                }
            }
            onDoubleClicked: {
                console.log("Toolbar double-clicked, current visibility:", mainToolbar.window ? mainToolbar.window.visibility : "null")
                if (mainToolbar.window) {
                    if (mainToolbar.window.visibility === Window.Maximized) {
                        mainToolbar.window.showNormal()
                    } else {
                        mainToolbar.window.showMaximized()
                    }
                }
            }
        }
    }
}
