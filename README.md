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

