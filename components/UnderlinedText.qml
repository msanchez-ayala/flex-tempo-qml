import QtQuick 2.0

Item {
    id: root

    property alias text: mainText.text
    property alias textColor: mainText.color
    property alias fontSize: mainText.font.pixelSize
    property alias underlineColor: rect.color


    readonly property int spacing: 4
    readonly property int underlineHeight: 4


    height: mainText.height + spacing + underlineHeight


    Text {
        id: mainText

        anchors.horizontalCenter: parent.horizontalCenter

    }

    // Gets filled by root.underlineColor
    Rectangle {
        id: rect

        border.color: 'transparent'

        height: underlineHeight
        anchors {
            left: root.left
            right: root.right
            bottom: root.bottom
        }

    }

}
