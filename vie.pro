TARGET = vie

CONFIG += sailfishapp

SOURCES += src/vie.cpp

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

DISTFILES += \
    qml/pages/AccountsPage.qml \
    qml/pages/TransferFundsDialog.qml \
    qml/pages/NewAccountDialog.qml \
    qml/javascripts/ethereum.js \
    qml/components/AccountsModel.qml \
    qml/pages/AccountInfoPage.qml \
    qml/pages/TransferProgressPage.qml

OTHER_FILES += qml/vie.qml \
    qml/cover/CoverPage.qml \
    rpm/vie.spec \
    rpm/vie.yaml \
    translations/*.ts \
    vie.desktop

geth.path = /usr/bin
geth.files = geth

INSTALLS += geth
