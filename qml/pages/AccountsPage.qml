/*
    Copyright (C) 2016 Imogen Software Carsten Valdemar Munk

    Contact: Tom Swindell <t.swindell@rubyx.co.uk>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    SilicaListView {
        id: accountsList

        anchors.fill: parent

        spacing: 10

        model: accountsModel

        PullDownMenu {
            MenuItem {
                text: qsTr("New Account")
                onClicked: pageStack.push(Qt.resolvedUrl("NewAccountDialog.qml"))
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Accounts")
        }

        delegate: ListItem {
            id: listItem

            contentHeight: Theme.itemSizeMedium

            onClicked: pageStack.push(Qt.resolvedUrl("AccountInfoPage.qml"), {accountId: model.accountId})

            menu: contextMenu

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Copy Address")
                        onClicked: Clipboard.text = model.accountId
                    }

                    MenuItem {
                        text: qsTr("Send Funds")
                        onClicked: pageStack.push(Qt.resolvedUrl("TransferFundsDialog.qml"), {fromAccountId: model.accountId})
                    }
                }
            }

            Column {
                anchors.fill: parent

                Label {
                    width: parent.width
                    text: model.accountId
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 26
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    anchors.right: parent.right
                    text: 'Funds: ' + model.latest
                }
            }
        }
    }
}
