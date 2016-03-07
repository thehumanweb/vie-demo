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

Dialog {
    id: dialog

    property string fromAccountId

    canAccept: destAccountField.acceptableInput && transferAmountField.text.length > 0

    acceptDestination: Component { TransferProgressPage { } }
    acceptDestinationAction: PageStackAction.Replace

    SilicaFlickable {
        anchors.fill: parent

        contentWidth: column.width
        contentHeight: column.height

        Column {
            id: column

            width: dialog.width
            height: childrenRect.height

            DialogHeader { }

            PageHeader { title: qsTr("Send Funds") }

            TextField {
                id: fromAccountField
                width: parent.width
                text: fromAccountId
                readOnly: true
                label: qsTr("From")
            }

            TextField {
                id: destAccountField
                width: parent.width
                placeholderText: qsTr("Send to")
                label: qsTr("Send To")
                validator: RegExpValidator { regExp: /^(0x)?[0-9a-f]{40}$/i }
                focus: true
            }

            ComboBox {
                id: currencyUnitField
                width: parent.width
                label: qsTr("Units")

                menu: ContextMenu {
                    MenuItem { text: "ether" }
                    MenuItem { text: "wei" }
                }
            }

            TextField {
                id: transferAmountField
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                placeholderText: qsTr("Amount")
                label: qsTr("Amount")
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: qsTr("Account Password");
                echoMode: TextInput.Password
                label: placeholderText
            }
        }
    }

    onAccepted: {
        var index = accountsModel.getAccountIndex(fromAccountField.text);

        if(index === -1) {
            console.log("Failed to find valid local account in model!")
            return;
        }

        var account = accountsModel.get(index);
        var transferAmount;

        if (currencyUnitField.value === "ether") {
            transferAmount = parseFloat(transferAmountField.text) * 1000000000000000000;
        } else {
            transferAmount = parseInt(transferAmountField.text);
        }

        // Construct SignTransaction call arguments.
        var txArgs = {
                from: account.accountId,
                  to: destAccountField.text,
               value: "0x" + transferAmount.toString(16),
                 gas: "0x" + (21000).toString(16),
               nonce: account.txCount,
                data: ""
        };

        acceptDestinationInstance.localApi  = main.localApi;
        acceptDestinationInstance.remoteApi = main.remoteApi;
        acceptDestinationInstance.startTx(account.accountId, passwordField.text, txArgs);

    }
}
