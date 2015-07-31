#!/bin/sh
#
# deploy k8 cluster on clc
# 
# Make a cluster with default values listed below:
# > bash make-cluster.sh 
# 
# Make a cluster with custom values:
# > bash make-cluster.sh ClusterName Location #ofServers PathToPasswords.ymlFile WorkingDir CPUperVM MEMperVM
#
#


# Set variables to what was passed in CLI or to the defaults below
server_group=${1:-kubernetes1} 
location=${2:-ca2} 
server_count=${3:-3} 
password_file=${4:-./passwords.yml} 
working_dir=${5:-/root} 
cpu_size=${6:-2} 
mem_size=${7:-2} 



#### Part1

echo "Starting servers and downloading k8"
{ ansible-playbook create-servers.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir cpu_size=$cpu_size mem_size=$mem_size"; } &
{ ansible-playbook download-k8.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait

#### Part2
echo "creating configuration"
{ ansible-playbook change-config.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait

#### Part3
echo "Deploying Kubernetes!!!! -> cd $working_dir/$server_group/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh"
(cd $working_dir/$server_group/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh)

#### Part4
echo "Updating PATH"
echo "export PATH=$PATH:$working_dir/$server_group/kubernetes/cluster/ubuntu/binaries/" >> ./set-path-$server_group.sh
source ./set-path-$server_group.sh


#### Part5
echo "Trying addons!"
(cd $working_dir/$server_group/kubernetes/cluster/ubuntu && KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh)


#### Part6
echo "Fix docker on minions. Need to re-run /root/kube/reconfDocker.sh for some reason after k8 deploy"
{ ansible-playbook fix-minions.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait



echo "All done. Try out your k8 cluster today! -ck"
echo "> kubectl get nodes"
echo "> kubectl cluster-info"


