#Scripts to install kubernetes on CenturyLink Cloud
These scripts are still in early early alpha. This is mainly just a proof of concept at this point. 

These scripts do the following items:

* Create new VMs in CenturyLinkCloud
* Configure the new servers with the needed software packages (docker, etc) and setup passphraseless SSH access via Keys between host and new servers
* Installs latest kubernetes to the new VMs in Centurylink Cloud
* Setup your host with the kubernetes client, kubectl, so you can start using your new kubernetes cluster


### Prereq
Ensure these things exist before you get started. 

* centurylink cloud (CLC) account
* a 'network created' in the CLC location of your choice
* A linux host to run scripts from (I tested on ubuntu)
* These installed packages on your script host:
 * ansible (latest version preferred. Should work on some older versions.)
 * centurylink cloud ansible plugin
 * python, pthyon pip
 * git
* Configure and test ansible and clc plugin (make sure your auth is setup right)
* ssh key on the host

For insturctions on how to do all this, see the prepare-host.MD

### How to setup scripts

Download this repo to your host. 
> git clone https://github.com/ckleban/k8-on-clc

Create a SSH key on your host and install it on your host to access new remote VMs (note: this key has no passphrase. You can also create one with a passphrase, but you will need to type that in from time to time)

> ssh-keygen -b 2048 -t rsa -f /root/.ssh/clc2_rsa -q -N ""

> eval $(ssh-agent -s)

> ssh-add /root/.ssh/clc2_rsa

Set the credentials for the CLC ansible plugin:
>export CLC_V2_API_USERNAME=yourCLCusername

>export CLC_V2_API_PASSWD=yourCLCpassword

Display the public file of the key you created (you will need to copy the contents of this in the below file)
> cat  /root/.ssh/clc2_rsa.pub

Tell the scripts what root password you want on your new VMs and provide the ssh key you created above. 
> vi ./passwords.yml

### How to run Scripts

You only need to run one script and it will take care of everything: make-cluster.sh

To run this and use all the defaults: location=ca2, servers=3, VMcpus=2, VMmem=2....

> bash make-cluster.sh

OR specify your own parameters:

The parameters and their specific order: (ClusterName) (CLC Location) (Number of Servers) (path to passwords.yml file) (Working directory) (cpu size per VM) (mem size per VM)

example:
> bash make-cluster.sh ca2-k8-test2 ca2 5 /path/to/your/passwords.yml /root 1 1

You should now have a kubernetes cluster on CLC. Your host should now be configured to work with your new cluster. Simply run your favorite kubectl commands. 

### Kubernetes notes

At this time, if you want to expose kubernetes services to external users (like the internet), the 'load balancer type' foes not automatically create an external public IP for you. You need to create the service with type nodeport and create an LB pointing to the VM internal ip address for one, many or all of the servers in the cluster and the port created in the service. 

### Kubernetes Examples

You can now run anything kubernetes commands you want from your host or any host with kubectl installed. 


List all nodes in your cluster
>kubectl get nodes

List all nodes, pods, services, and replication controllers in your cluster
>kubectl get nodes,pods,services,rc

### Delete your cluster

To delete your cluster, simply login to the CLC control portal and delete the group of new servers


