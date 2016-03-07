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

import "javascripts/ethereum.js" as Ethereum

import "components"
import "pages"

ApplicationWindow
{
    id: main

    property int gasPrice: 0

    property var  localApi: Ethereum.connect("localhost", 8545)
    property var remoteApi: Ethereum.connect("buildbox.tspre.org", 8545)

    property string filterId

    initialPage: Component { AccountsPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.Portrait
    _defaultPageOrientations: Orientation.Portrait

    //TODO: Need to differentiate between different error types.
    function __api_failure(connection, response) {
        console.log("RPC API failed host: http://" + connection.host + ":" + connection.port + "/");
        console.log("  Error: " + JSON.stringify(response));
    }

    Timer {
        id: updateTimer
        interval: 5000
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            /*
            remoteApi.eth.getFilterChanges([filterId],
                                           function(r) {
                                               console.log("FILTER " + filterId + ":" + JSON.stringify(r))
                                           }, __api_failure);*/

            localApi.personal.listAccounts(
                        function(response) {
                            for(var i = 0; i < response.length; i++) {
                                var index = accountsModel.getAccountIndex(response[i]);

                                if(index === -1) {
                                    var account = {
                                        accountId: response[i],
                                          txCount: "",
                                           latest: 0.0
                                    }

                                    index = i;
                                    accountsModel.append(account);
                                }

                                (function(index) {
                                    remoteApi
                                        .eth
                                        .getTransactionCount([response[index], 'latest'],
                                                             function(result) {
                                                                 accountsModel.setProperty(index, 'txCount', result);
                                                             },
                                                             __api_failure);
                                    remoteApi
                                        .eth
                                        .getBalance([response[index], 'latest'],
                                                    function(result) {
                                                        accountsModel.setProperty(index, 'latest', result);
                                                    },
                                                    __api_failure);
                                })(index);
                            }
                        },
                        __api_failure);
        }
    }

    Component.onCompleted: {
        // TODO
        // - Get Accounts.
        // - Get current balance for all accounts.
        // - Setup filter for account transactions.
        /*remoteApi.eth.newFilter([{
                                     fromBlock: "0x0",
                                     toBlock: "pending",
                                     account: "0x4e74a549adaca611a8cad67aae40c1005c9018ca"
                                 }],
                                function(r) {
                                    filterId = r
                                }, __api_failure);*/

        remoteApi.eth.gasPrice(function(r) {
            main.gasPrice = parseInt(r);
        }, __api_failure);

        updateTimer.start();
    }

    AccountsModel { id: accountsModel }
}
