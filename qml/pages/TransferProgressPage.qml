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

    property var localApi
    property var remoteApi

    function startTx(account, password, txArgs) {
        indicator.running = true;
        label.text = "Unlocking Account...";

        localApi.personal.unlockAccount(
                    [account, passwordField.text, 5],
                    function(response) {
                        // Call SignTransaction (and wait for response?)
                        console.log("Account Unlocked for 5 seconds...")
                        label.text = "Signing Transaction...";
                        localApi.eth.signTransaction(
                                    [txArgs],
                                    function(response) {
                                        // On Successful Response, SendRawTransaction to remote.
                                        console.log("Tx Signed RawData: " + JSON.stringify(response));
                                        label.text = "Sending Transaction...";
                                        remoteApi.eth.sendRawTransaction(
                                                    [response.raw],
                                                    function(response) {
                                                        console.log("Tx Accepted, ID: " + JSON.stringify(response));
                                                        indicator.visible = false;
                                                        indicator.running = false;
                                                        label.text = "Transaction Accepted"
                                                    },
                                                    function(conn, err) {
                                                        indicator.running = false;
                                                        indicator.visible = false;
                                                        label.text = "Failed to send transaction!";
                                                    });
                                    },
                                    function(conn, err) {
                                        indicator.running = false;
                                        indicator.visible = false;
                                        label.text = "Failed to sign transaction!";
                                    }
                                    );
                    },
                    function(conn, err) {
                        indicator.running = false;
                        indicator.visible = false;
                        label.text = "Failed to unlock wallet!";
                    });
    }

    Column {
        width: parent.width
        anchors.centerIn: parent

        spacing: Theme.paddingLarge

        BusyIndicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
        }

        Label {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
