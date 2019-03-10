# Wait for the socket to Tessera to be available
while [ ! -S "/root/qdata/tm.ipc" ]; do
   sleep 0.1
done

modules="admin,db,eth,debug,miner,net,txpool,personal,web3,quorum,clique"

# nodiscover : because we specify permissioned.json, --no-discover because everything is in the file
GETH_ARGS="--syncmode full --mine --rpc --rpcaddr 0.0.0.0 --ws --wsaddr 0.0.0.0 --rpcapi $modules --wsapi $modules --nodiscover --datadir /root/qdata/dd --nodekey /root/qdata/nodekey --unlock 0 --networkid 1664 --password /root/qdata/pass.txt"


env
/usr/local/bin/geth --datadir /root/qdata/dd  init /root/qdata/nanti.json
PRIVATE_CONFIG=/root/qdata/tm.ipc
echo "YO"
/usr/local/bin/geth $GETH_ARGS