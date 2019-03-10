# Abstract

Application : Corporate bonds that can be used as collateral for fast offchain payments
This repo contains all the infrastructure part which made this possible with quorum deployment
The bond contract is deployed at 0x451875bdd0e524882550ec1ce52bcc4d0ff90eae and you can attach

    geth attach http://3.16.41.72:8545

2 repos: one dedicated to infrastructure part(this current one), and the other one dedicated to the Dapp part : [https://github.com/cryptotuxorg/nanti-dapp](https://github.com/cryptotuxorg/nanti-dapp)

The idea is to deploy a quorum network between 4 validators nodes
4 AWS machines has been instancied and the quorum network is up and running
Useful deployment files are under [quorum_deployment folder](quorum_deployment)

The challenge was to adapt quorum network setup examples currently available to cloud provider deployment, which was not so easy to do.

![Image of VMs](https://github.com/cryptotuxorg/nanti/blob/master/machines.png)


The challenge, which currently WIP, is to deploy POA network bridge between ethereum mainnet and a private quorum sidechain
Instead of using POA Sokol network, we'll use our custom private quorum network
It will allow people to lock some DAI into mainnet, to issue x$ equivalent in the quorum private chain, which will give the possibility to buy bonds directly


## Setup on AWS


Create four t2.micro Ubuntu 18.04 instances on AWS with 8GB SSD


Create a new SSH keyPair and put it under ~/.ssh/ethparis.pem on your host

Give good permissions to ssh key on your host


    chmod 400 ~/.ssh/ethparis.pem


Edit ~/.ssh/config on your host and add configuration for your 4 machines


    Host aws-quorum-node-1
        HostName PUBLIC_DNS_OR_IP
        Port 22
        User ubuntu
        IdentityFile ~/.ssh/ethparis.pem
    Host aws-quorum-node-2
        HostName YOUR_PUBLIC_DNS_OR_IP
        Port 22
        User ubuntu
        IdentityFile ~/.ssh/ethparis.pem
    Host aws-quorum-node-3
        HostName YOUR_PUBLIC_DNS_OR_IP
        Port 22
        User ubuntu
        IdentityFile ~/.ssh/ethparis.pem
    Host aws-quorum-node-4
        HostName YOUR_PUBLIC_DNS_OR_IP
        Port 22
        User ubuntu
        IdentityFile ~/.ssh/ethparis.pem


Connect to each server like this

    ssh aws-quorum-node-1

And install some useful stuff when you are connected to the remote server

    sudo apt-get update && sudo apt-get install python build-essential

Verify that you can reach all your servers ([ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) has to be installed on your host only). The output should be green with a 'SUCCESS' message

ansible -i ansible/hosts quorum-nodes -u ubuntu -m ping

ABORTED - Then build quorum on each machine (preferred one build on a 64bits linux machine then scp to all remotes validator nodes)

    ansible -i ansible/hosts quorum-nodes -u ubuntu -a "git clone https://github.com/jpmorganchase/quorum.git"
    ansible -i ansible/hosts quorum-nodes -u ubuntu -a "wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz"
    ansible -i ansible/hosts quorum-nodes -u ubuntu -a "sudo tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz"
    ansible -i ansible/hosts quorum-nodes -b -m lineinfile -a 'dest=/etc/profile line="export PATH=$PATH:/usr/local/go/bin"'

Then build quorum on your host

    git clone https://github.com/jpmorganchase/quorum.git
    cd quorum
    make all

Copy the bin folder to the remote servers

    scp -r build/bin aws-quorum-node-1:~/
    scp -r build/bin aws-quorum-node-2:~/
    scp -r build/bin aws-quorum-node-3:~/
    scp -r build/bin aws-quorum-node-4:~/


Generate one account per validator on each server

    geth account new


Result:

    aws-quorum-node-1 c2379a1d4ff094eef9d7074afabbe4bdb29a565f
    aws-quorum-node-2 8202d027c62c578ed3d8bd98f1f9a0a106f3f592
    aws-quorum-node-3 64e0cebf10639346f43c6fbe5d5e728cdbede67c
    aws-quorum-node-4 d6a47a9516cb53a54d3766858e7258c816a821b0

Use Puppeth on your host to create a new genesis file


    Please specify a network name to administer (no spaces, hyphens or capital letters please)
    > nanti

    Sweet, you can set this via --network=nanti next time!

    INFO [03-09|17:19:20.416] Administering Ethereum network           name=nanti
    WARN [03-09|17:19:20.424] No previous configurations found         path=/home/alex/.puppeth/nanti

    What would you like to do? (default = stats)
    1. Show network stats
    2. Configure new genesis
    3. Track new remote server
    4. Deploy network components
    > 2

    What would you like to do? (default = create)
    1. Create new genesis from scratch
    2. Import already existing genesis
    > 1

    Which consensus engine to use? (default = clique)
    1. Ethash - proof-of-work
    2. Clique - proof-of-authority
    > 2

    How many seconds should blocks take? (default = 15)
    > 3

    Which accounts are allowed to seal? (mandatory at least one)
    > 0xc2379a1d4ff094eef9d7074afabbe4bdb29a565f
    > 0x8202d027c62c578ed3d8bd98f1f9a0a106f3f592
    > 0x64e0cebf10639346f43c6fbe5d5e728cdbede67c
    > 0xd6a47a9516cb53a54d3766858e7258c816a821b0
    > 0x

    Which accounts should be pre-funded? (advisable at least one)
    > 0xc2379a1d4ff094eef9d7074afabbe4bdb29a565f
    > 0x8202d027c62c578ed3d8bd98f1f9a0a106f3f592
    > 0x64e0cebf10639346f43c6fbe5d5e728cdbede67c
    > 0xd6a47a9516cb53a54d3766858e7258c816a821b0
    > 0x

    Should the precompile-addresses (0x1 .. 0xff) be pre-funded with 1 wei? (advisable yes)
    > yes

    Specify your chain/network ID if you want an explicit one (default = random)
    > 1664
    INFO [03-09|17:20:46.094] Configured new genesis block

    What would you like to do? (default = stats)
    1. Show network stats
    2. Manage existing genesis
    3. Track new remote server
    4. Deploy network components

Add support of quorum in the genesis file befor "clique section"

    "isQuorum":true,

Copy the genesis to the remotes servers

    scp nanti.json aws-quorum-node-1:~
    scp nanti.json aws-quorum-node-2:~
    scp nanti.json aws-quorum-node-3:~
    scp nanti.json aws-quorum-node-4:~

Be sure to have 8545 TCP and 30303 TCP/UDP inbound rules allowed on AWS

Then init geth with the genesis on each node

    geth init nanti.json


## QUORUM SETUP

    scp quorum folder into remote server
    cd quorum
    mkdir ~/quorum_data
    ansible -i ansible/hosts quorum-nodes -u ubuntu -b -m command -a 'mv /home/ubuntu/.ethereum/keystore /home/ubuntu/quorum_data/'
    echo "MYPASS" >> pass.txt
    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -genkey /root/qdata/nodekey

Display on host

    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -nodekeyhex 8ddb455b5d72454171a1591ef914d4ab81f1ed706d7eb4dde639f21a717cfe72 -writeaddress

    f7a4a853b0f6469dee9c1cdcd33854f0854b43190ad2ee5e513c441b068a98afb8c4715f8d58e341d03d6f1c865a2fecd5aa90bdaa24c335a6c9ecd8048270dd


    sudo cat ../quorum_data/nodekey
    2a3f4db45e40d3d5458684a036a79c52f4c42f9b65016f85d657303b2701d997

    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -nodekeyhex 2a3f4db45e40d3d5458684a036a79c52f4c42f9b65016f85d657303b2701d997 -writeaddress

    fc529f773f3f41a8daba7af677466a031d31130d9d55085a6c9e4adf57fe09e8af4f7d1299e3168e73744a6367df81a2a84cd5553f847b5e03baa021ffad3bd2

    sudo cat ../quorum_data/nodekey
    b4159f4a8a645818393ef55426671cdf8df2fb156979e9d53f78ab700744caa3

    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -nodekeyhex b4159f4a8a645818393ef55426671cdf8df2fb156979e9d53f78ab700744caa3 -writeaddress

    1d85bc2ebeb1820138039fde266264fb4ea68bc93f0216a89b0ddbc2b015f8c8bb17b53bb4c58a11e490610e982a9c9840b17410cc9a4349aa4af5c5de1f6e6f

    sudo cat ../quorum_data/nodekey
    b90fc697ab597a1a68e4fd5e97e84841bd174296b6aa71df6a6aec44a27f98d3

    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -nodekeyhex b90fc697ab597a1a68e4fd5e97e84841bd174296b6aa71df6a6aec44a27f98d3 -writeaddress

    57e987a7d1a1e16d4f3198994fc39fa3d959e1ee0cc81e7c6dbf651cc9683516a33c663dc28b2a6afb3e6ab7395d38436611b0ae761eac15a611773394cd098b


    sudo docker-compose run --rm --entrypoint /usr/local/bin/bootnode quorum -nodekey /root/qdata/nodekey -writeaddress



On each VM

    sed -e s#localhost#http://18.191.160.159#g -i docker-compose.yml
    sed -e s#localhost#http://52.14.85.155#g -i docker-compose.yml
    sed -e s#localhost#http://18.191.142.136#g -i docker-compose.yml
    sed -e s#localhost#http://3.16.41.72#g -i docker-compose.yml


    for i in aws-quorum-node-1 aws-quorum-node-2 aws-quorum-node-3 aws-quorum-node-4; do scp -r quorum/Dockerfile.quorum ${i}:~/quorum/Dockerfile.quorum; done

    for i in aws-quorum-node-1 aws-quorum-node-2 aws-quorum-node-3 aws-quorum-node-4; do scp -r quorum/Dockerfile.tessera ${i}:~/quorum/Dockerfile.tessera; done

    ansible -i ansible/hosts quorum-nodes -u ubuntu -b -m command -a 'sudo chmod +x /home/ubuntu/quorum/quorum-start.sh'

    for i in aws-quorum-node-1 aws-quorum-node-2 aws-quorum-node-3 aws-quorum-node-4; do scp -r quorum/nanti.json ${i}:~/quorum_data/nanti.json; done


    for i in aws-quorum-node-1 aws-quorum-node-2 aws-quorum-node-3 aws-quorum-node-4; do scp -r quorum/static-nodes.json ${i}:~/quorum_data/dd; done

    sudo docker-compose up --build