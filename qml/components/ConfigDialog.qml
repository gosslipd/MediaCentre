import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import "../../qml/components"

CustomisedWindow {
    id: configDialog
    width: 400
    height: 300
    title: "Configuration"
    showMinimizeButton: false
    showMaximizeButton: false
    showCloseButton: true
    showToolbar: true
    resizeEnabled: false

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: toolbarHeight
        color: "#333333"

        Text {
            anchors.centerIn: parent
            text: "Configuration Dialog"
            color: "white"
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            text: "Close"
            onClicked: configDialog.close()
        }
    }
}
