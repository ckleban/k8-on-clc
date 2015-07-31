#!/bin/sh
#
# deploy k8 cluster on clc

server_group=${1:-kubernetes1} 
location=${2:-ca2} 
server_count=${3:-3} 
password_file=${4:-./passwords.yml} 
working_dir=${5:-/root} 
cpu_size=${6:-2} 
mem_size=${7:-2} 

echo "Starting servers and downloading k8"
{ ansible-playbook create-servers.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir cpu_size=$cpu_size mem_size=$mem_size"; } &
{ ansible-playbook download-k8.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait

echo "creating configuration"
{ ansible-playbook change-config.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait

echo "Deploying Kubernetes!!!! -> cd $working_dir/$server_group/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh"
(cd $working_dir/$server_group/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh)

echo "Updating PATH"
export PATH=$PATH:$working_dir/$server_group/kubernetes/cluster/ubuntu/binaries/

echo "Trying addons!"
(cd $working_dir/$server_group/kubernetes/cluster/ubuntu && KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh)



echo "Fix docker on minions. Need to re-run /root/kube/reconfDocker.sh for some reason after k8 deploy"
{ ansible-playbook fix-minions.yml --extra-vars "server_group=$server_group location=$location server_count=$server_count password_file=$password_file working_dir=$working_dir"; } &
wait

echo "All done. Try out your k8 cluster today! -ck"



