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
#include <sailfishapp.h>

#include <QProcess>

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);

    QString program = "/usr/bin/geth";
    QStringList args = QStringList()
            << "--nodiscover"
            << "--maxpeers"
            << "0"
            << "--rpc"
            << "--rpcapi"
            << "admin,db,eth,debug,miner,net,shh,txpool,personal,web3";

    QProcess *geth = new QProcess(app);
    QObject::connect(app, SIGNAL(aboutToQuit()), geth, SLOT(terminate()));

    geth->start(program, args);
    return SailfishApp::main(argc, argv);
}
