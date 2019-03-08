## Setup on AWS


* Create four t2.micro instances on AWS with 8GB SSD
* Create a new SSH keyPair and put it under ~/.ssh/ethparis.pem

* Give good permissions to ssh key


    chmod 400 ~/.ssh/ethparis.pem

Edit ~/.ssh/config and add configuration for your 4 machines


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

