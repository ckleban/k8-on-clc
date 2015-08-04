# More detailed instructions on how to prepare a host to run these scripts. 

> These steps were tested on a Unbuntu VM on CLC 

Install needed libraries
* apt-add-repository ppa:ansible/ansible
* apg-get update
* apt-get -y install ansible
* apt-get -y install python-pip
* pip install clc-ansible-module


Configure CLC module for ansible
* mv /etc/ansible/hosts /etc/ansible/hosts-back
* ln -s /usr/local/bin/clc_inv.py /etc/ansible/hosts
* export CLC_V2_API_USERNAME=yourCLCusername
* export CLC_V2_API_PASSWD=yourCLCpassword

Test CLC Ansible Module
* ansible all -i /usr/local/bin/clc_inv.py --list-hosts

Setup SSH Keys
* ssh-keygen -b 2048 -t rsa -f /root/.ssh/clc2_rsa -q -N ""
* eval $(ssh-agent -s)
* ssh-add /root/.ssh/clc2_rsa
