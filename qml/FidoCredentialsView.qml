import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

Flickable {

    id: fidoCredentialsView
    objectName: 'fidoCredentialsViewFlickable'
    contentWidth: app.width
    contentHeight: expandedHeight

    property var expandedHeight: content.implicitHeight + dynamicMargin

    onExpandedHeightChanged: {
        if (expandedHeight > app.height - toolBar.height) {
             scrollBar.active = true
         }
    }

    onFocusChanged: {
        if(fidoCredentialsView.focus) {
            yubiKey.fidoVerifyPin(fidoPinCache, function(resp) {
                if (resp.success) {
                    yubiKey.credentials = resp.credentials
                } else {
                    console.log("error")
                }
            })
        }
    }

    ScrollBar.vertical: ScrollBar {
        id: scrollBar
        width: 8
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        hoverEnabled: true
        z: 2
    }
    boundsBehavior: Flickable.StopAtBounds

    property string searchFieldPlaceholder: ""

    ColumnLayout {
        width: fidoCredentialsView.contentWidth
        id: content
        spacing: 0

        ColumnLayout {
            width: fidoCredentialsView.contentWidth - 32
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Label {
                text: "Credentials"
                font.pixelSize: 16
                font.weight: Font.Normal
                color: yubicoGreen
                opacity: fullEmphasis
                Layout.topMargin: 24
                Layout.bottomMargin: 24
                Layout.fillWidth: true
            }

            Label {
                text: yubiKey.credentials.length > 0 ? qsTr("Credentials on this YubiKey") : qsTr("There are no credentials on this YubiKey")
                color: primaryColor
                opacity: lowEmphasis
                font.pixelSize: 13
                lineHeight: 1.2
                textFormat: TextEdit.PlainText
                wrapMode: Text.WordWrap
                Layout.maximumWidth: parent.width
                Layout.bottomMargin: 16
            }

            Repeater {
                model: yubiKey.credentials
                id: credentialsRepeater

                RowLayout {
                    spacing: 0
                    StyledTextField {
                        text: modelData.name + " " + modelData.rpId + " " + modelData.userId
                        isEnabled: false
                        noedit: true
                        Layout.bottomMargin: -8

                        RowLayout {
                            anchors.right: parent.right

                            ToolButton {
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop

                                onClicked: navigator.confirm({
                                    "heading": qsTr("Delete " + (modelData.name ? modelData.name : modelData.userId) + " ?"),
                                    "message": qsTr("Credential will be removed from YubiKey."),
                                    "buttonAccept": qsTr("Delete"),
                                    "acceptedCb": function () {
                                        yubiKey.credDelete(modelData.userId, function (resp) {
                                           if (resp.success) {
                                                yubiKey.credentials = yubiKey.credentials.filter(item => item.userId !== modelData.userId)
//                                                navigator.snackBar(qsTr("Fingerprint deleted"))
                                           } else {
                                               if (resp.error_id === "multiple_matches") {
                                                   navigator.snackBarError(qsTr("Multiple matches."))
                                               } else {
                                                   navigator.snackBarError(qsTr("Credential not deleted"))
                                               }
                                           }
                                       })
                                    }
                                })

                                icon.source: "../images/clear.svg"
                                icon.color: primaryColor
                                opacity: hovered ? highEmphasis : disabledEmphasis
                                implicitHeight: 30
                                implicitWidth: 30

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    propagateComposedEvents: true
                                    enabled: false
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}