#Scripts to install kubernetes on CenturyLink Cloud
These scripts are still in early early alpha. This is mainly just a proof of concept at this point. 

### Prereq
Ensure these things exist before you get started. 

* Account on centurylink cloud (CLC)
* Host to run these scripts on (like linux, macos, etc). I tested on ubuntu. 
* Host has these items installed:
** ansible
** centurylink cloud ansible plugin
** python, pthyon pip
** git
* Configure and test ansible and clc plugin (clc auth)
* ssh key on the host
* host has internet access

### Howto use

Download these files
> git clone https://github.com/ckleban/k8-on-clc

Edit the passwords.yml file. This file will specify what root password and pub ssh key to use on the new servers in CLC
> vi ./passwords.yml

Run the install script. Need to pass it these variables in this specific order: <br>
(ClusterName) (CLC Location) (Number of Servers) (path to passwords.yml file) (Working directory)

> bash make-cluster.sh ca2-k8-test2 ca2 3 /root/passwords.yml /root


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


