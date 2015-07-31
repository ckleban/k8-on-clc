#Scripts to install kubernetes on CenturyLink Cloud
These scripts are still in early early alpha. This is mainly just a proof of concept at this point. 

### Prereq
Ensure these things exist before you get started. 

* centurylink cloud (CLC) account
* A linux host to run scripts from (I tested on ubuntu)
* These installed packages on your script host:
 * ansible (latest version preferred. Should work on some older versions.)
 * centurylink cloud ansible plugin
 * python, pthyon pip
 * git
* Configure and test ansible and clc plugin (make sure your auth is setup right)
* ssh key on the host

For insturctions on how to do all this, see the prepare-host.MD

### Howto use

Download these files
> git clone https://github.com/ckleban/k8-on-clc

Edit the passwords.yml file. This file will specify what root password and pub ssh key to use on the new servers in CLC
> vi ./passwords.yml

Run the install script with no parameters passed (if you are okay with default parameters)

The defaults are: location=ca2, servers=3, VMcpus=2, VMmem=2....

> bash make-cluster.sh

OR Run the install script with parameters passed (if you want to customize your cluster)

The parameters and their specific order: (ClusterName) (CLC Location) (Number of Servers) (path to passwords.yml file) (Working directory) (cpu size per VM) (mem size per VM)

example:
> bash make-cluster.sh ca2-k8-test2 ca2 5 /path/to/your/passwords.yml /root 1 1

You should now have a kubernetes cluster on CLC. Your host should now be configured to work with your new cluster. Simply run your favorite kubectl commands. 

### Kubernetes notes

At this time, if you want to expose kubernetes services to external users (like the internet), the 'load balancer type' foes not automatically create an external public IP for you. You need to create the service with type nodeport and create an LB pointing to the VM internal ip address for one, many or all of the servers in the cluster and the port created in the service. 

### Kubernetes Examples

You can now run anything kubernetes commands you want from your host or any host with kubectl installed. 
<br><br>

List all nodes in your cluster
>kubectl get nodes

List all nodes, pods, services, and replication controllers in your cluster
>kubectl get nodes,pods,services,rc


