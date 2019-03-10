#!/usr/bin/env bash

    #change tls to "strict" to enable it (don't forget to also change http -> https)
    DDIR=/root/tdata

    if ! [ -f /root/tdata/tm.key ]; then
        echo "\n\n" | java -Xms128M -Xmx128M -jar /tessera/tessera-app.jar -keygen
        mv /.pub /root/tdata/tm.pub
        mv /.key /root/tdata/tm.key
    fi

    cat <<EOF > ${DDIR}/tessera-config.json
{
    "useWhiteList": false,
    "jdbc": {
        "username": "sa",
        "password": "",
        "url": "jdbc:h2:${DDIR}/db;MODE=Oracle;TRACE_LEVEL_SYSTEM_OUT=0",
        "autoCreateTables": true
    },
    "serverConfigs":[
        {
            "app":"ThirdParty",
            "enabled": true,
            "serverSocket":{
                "type":"INET",
                "port": 9080,
                "hostName": "http://${HOSTNAME}"
            },
            "bindingAddress": "http://0.0.0.0:9080",
            "communicationType" : "REST"
        },
        {
            "app":"Q2T",
            "enabled": true,
            "serverSocket":{
                "type":"UNIX",
                "path":"/root/qdata/tm.ipc"
            },
            "communicationType" : "UNIX_SOCKET"
        },
        {
            "app":"P2P",
            "enabled": true,
            "serverSocket":{
                "type":"INET",
                "port": 9000,
                "hostName": "http://${HOSTNAME}"
            },
            "bindingAddress": "http://0.0.0.0:9000",
            "sslConfig": {
                "tls": "OFF",
                "generateKeyStoreIfNotExisted": true
            },
            "communicationType" : "REST"
        }
    ],
    "peer": [
        {
            "url": "http://18.191.160.159:9000"
        },
        {
            "url": "http://52.14.85.155:9000"
        },
        {
            "url": "http://18.191.142.136:9000"
        },
        {
            "url": "http://3.16.41.72:9000"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {
                "privateKeyPath": "${DDIR}/tm.key",
                "publicKeyPath": "${DDIR}/tm.pub"
            }
        ]
    },
    "alwaysSendTo": []
}
EOF

exec java -jar /tessera/tessera-app.jar -configfile /root/tdata/tessera-config.json
