/*
    Copyright (C) 2016 Tom Swindell

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
.pragma library

function __build_REQ(url, method, success, failure) {
    var xhr = new XMLHttpRequest();

    if(!failure) failure = function() {};

    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            //console.log(xhr.getAllResponseHeaders());
        }

        if(xhr.readyState !== XMLHttpRequest.DONE) return;

        // Request complete, log response.
        //console.log(xhr.status + ' ' + xhr.statusText + ' | ' + method + ' ' + url + ' ' + xhr.responseText.length + ' byte/s');

        if(xhr.status < 200 || xhr.status >= 300) return failure(xhr);

        success(xhr);
    }

    xhr.open(method, url);
    return xhr;
}

function get(url, success, failure) {
    var xhr = __build_REQ(url, 'GET', success, failure);
    xhr.send();
}

function post(url, data, success, failure) {
    var xhr = __build_REQ(url, 'POST', success, failure);
    xhr.send(data);
}

var JSONRPC = {};

JSONRPC.get = function(url, success, failure) {
    get(url,
        function(xhr) {
            var response = JSON.parse(xhr.responseText);
            success(response);
        },
        failure);
}

JSONRPC.post = function(url, object, success, failure) {
    var data = JSON.stringify(object);

    //console.log(" << " + data);

    post(url, data,
         function(xhr) {
             var response = JSON.parse(xhr.responseText);
             success(response);
         },
         failure);
}

function connect(host, port)
{
    var c = {};

    c.scheme = 'http'
    c.host   = host;
    c.port   = port;

    c.__message_id = 0;
    c.__build_rpc = function(method, params) {
        params = params || [];

        this.__message_id += 1;

        return {
            jsonrpc: "2.0",
            method: method,
            params: params,
            id: this.__message_id
        };
    }

    c.post_rpc = function(method, params, success, failure, formatter) {
        formatter = formatter || function(r) { return r }

        JSONRPC.post(c.scheme + '://' + c.host + ':' + c.port,
                     c.__build_rpc(method, params),
                     function(response) {
                         //console.log(' >> ' + JSON.stringify(response));

                         if(response.error) {
                             return failure(c, response.error.message);
                         }

                         return success(formatter(response.result));
                     },
                     function(response) { failure(c, response) }
                     );
    }

    c.add_module = function(name) {
        var module = {};

        module.register_rpc = function(method, hasParams, formatter) {
            if(hasParams) {
                module[method] = function(params, success, failure, tag) {
                    c.post_rpc(name + '_' + method, params, success, failure, formatter, tag)
                }
            } else {
                module[method] = function(success, failure, tag) {
                    c.post_rpc(name + '_' + method, [], success, failure, formatter, tag)
                }
            }
        }

        c[name] = module;
        return module;
    }

    var eth = c.add_module('eth');
    eth.register_rpc('version');
    eth.register_rpc('protocolVersion');
    eth.register_rpc('syncing');
    eth.register_rpc('coinbase');
    eth.register_rpc('mining');
    eth.register_rpc('hashrate');
    eth.register_rpc('gasPrice');
    eth.register_rpc('accounts');
    eth.register_rpc('blockNumber');
    eth.register_rpc('getBalance', true, function(r) { return parseInt(r) / 1000000000000000000 });
    eth.register_rpc('getStorageAt', true);
    eth.register_rpc('getTransactionCount', true);
    eth.register_rpc('getBlockTransactionCountByHash', true);
    eth.register_rpc('getBlockTransactionCountByNumber', true);
    eth.register_rpc('getUncleCountByBlockHash', true);
    eth.register_rpc('getUncleCountByBlockNumber', true);
    eth.register_rpc('getCode', true);
    eth.register_rpc('sign', true);
    eth.register_rpc('sendTransaction', true);
    eth.register_rpc('sendRawTransaction', true);
    eth.register_rpc('signTransaction', true);
    eth.register_rpc('call', true);
    eth.register_rpc('estimateGas', true);
    eth.register_rpc('getBlockByHash', true);
    eth.register_rpc('getBlockByNumber', true);
    eth.register_rpc('getTransactionByHash', true);
    eth.register_rpc('getTransactionByBlockHashAndIndex', true);
    eth.register_rpc('getTransactionByBlockNumberAndIndex', true);
    eth.register_rpc('getTransactionReceipt', true);
    eth.register_rpc('getUncleByBlockHashAndIndex', true);
    eth.register_rpc('getUncleByBlockNumberAndIndex', true);
    eth.register_rpc('getCompilers');
    eth.register_rpc('compileLLL', true);
    eth.register_rpc('compileSolidity', true);
    eth.register_rpc('compileSerpent', true);
    eth.register_rpc('newFilter', true);
    eth.register_rpc('newBlockFilter', true);
    eth.register_rpc('newPendingTransactionFilter', true);
    eth.register_rpc('uninstallFilter', true);
    eth.register_rpc('getFilterChanges', true);
    eth.register_rpc('getFilterLogs', true);
    eth.register_rpc('getLogs', true);
    eth.register_rpc('getWork');
    eth.register_rpc('submitWork', true);
    eth.register_rpc('submitHashrate', true);

    var net = c.add_module('net');
    net.register_rpc('version');
    net.register_rpc('peerCount');
    net.register_rpc('listening');

    var personal = c.add_module('personal');
    personal.register_rpc('version');
    personal.register_rpc('listAccounts');
    personal.register_rpc('newAccount', true);
    personal.register_rpc('unlockAccount', true);

    return c;
}
