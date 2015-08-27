#Scripts to install kubernetes on CenturyLink Cloud

These scripts will install a kubernetes cluster for your use on CenturyLink Cloud. These scripts are tested to work from an ubuntu machine. These scripts are meant to allow people to try and learn about kubernetes on centurylink cloud. There are not meant for production purposes. 

These scripts will do the following items:

* Create new VMs in CenturyLinkCloud
* Configure the new servers with the needed software packages (docker, etc) and setup passphraseless SSH access via Keys between host and new servers
* Installs latest kubernetes to the new VMs in Centurylink Cloud
* Setup your host with the kubernetes client, kubectl, so you can start using your new kubernetes cluster


### Prereq
Ensure these things exist before you get started. 

* centurylink cloud (CLC) account. 
 * If you don't have an account, go get one here: https://www.ctl.io/free-trial/ 
 * Currently they are giving out 2500 in cloud credit for 30 days to new accounts. 
* In the CLC location you wish to create your k8 cluster, you need at least one 'network' created. 
 * This will happen automatically for you if you have created a VM via the web ui.
 * To do this manually, login to the CLC ui, navigate to networks, pick your location, and click create
* A linux host to run scripts from (I simply created a new ubuntu 14 vm on CLC)

### Setup and configure CLC Ansible Plugin on your linux host. 

You will need a host setup that has the CLC Ansible Plugin installed and configured. Here are some steps on how to do this on an ubuntu vm:

Install needed libraries
* apt-add-repository ppa:ansible/ansible
* apt-get update
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

Setup ssh keys for new VMs.
* Note: this key has no passphrase. You can also create one with a passphrase, but you will need to type that in from time to time
* 
* ssh-keygen -b 2048 -t rsa -f /root/.ssh/clc2_rsa -q -N ""
* eval $(ssh-agent -s)
* ssh-add /root/.ssh/clc2_rsa

### Install and configure these kubernetes on CLC scripts

Download this repo to your host. 
* apt-get -y install git
* git clone https://github.com/ckleban/k8-on-clc

Display the public file of the key you created (you will need to copy the contents of this in the below file)
* cat  /root/.ssh/clc2_rsa.pub

Tell the scripts what root password you want on your new VMs and provide the ssh key you created above. 
* vi ./passwords.yml

### How to run Scripts

You only need to run one script and it will take care of everything: make-cluster.sh

To create a kubernetes cluster with the default parameters, simply run: 
* bash make-cluster.sh

Default parameters are: location=ca2, servers=3, VMcpus=2, VMmem=2....

OR, to create a kubernetes cluster and specify your own parameters:

example:
* bash make-cluster.sh ca2-k8-test2 ca2 5 /path/to/your/passwords.yml /root 1 1

Note: The parameters and their specific order: (ClusterName) (CLC Location) (Number of Servers) (path to passwords.yml file) (Working directory) (cpu size per VM) (mem size per VM)

### Results:

You should now have a kubernetes cluster on CLC. Your host should now be configured to work with your new cluster. Simply run your favorite kubectl commands. If the script displayed and errors, your cluster may have not been installed correctly. Post an issue here if this happens and I'll try to help you out. 

### Test:
To test if the cluster was installed correctly and your VM can access the cluster, try using the kubectl client to list all nodes in your cluster:

* kubectl get nodes


### Kubernetes on CLC: notes and limitations

* At this time, if you want to expose kubernetes services to external users (like the internet), the 'load balancer type' foes not automatically create an external public IP for you. You need to create the service with type nodeport and create an LB pointing to the VM internal ip address for one, many or all of the servers in the cluster and the port created in the service.
* Only the DNS kubernets add-on is installed. (No ui, logging, monitoring, etc at this time)


### Kubernetes Examples

You can now run anything kubernetes commands you want from your host or any host with kubectl installed. 


List all nodes in your cluster
>kubectl get nodes

List all nodes, pods, services, and replication controllers in your cluster
>kubectl get nodes,pods,services,rc

### Delete your cluster

To delete your cluster, simply login to the CLC control portal and delete the group of new servers

### What's next

* Re-write automation to add CLC as a true 'cloud provider' inside kiubenetes. This will give us external IP support within the kubectl client and api. 
* Add additional add ons
* Support HTTPs and Certificate authentiction and api usage. 



