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
{ ansible-playbook create-servers.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5 cpu_size=$6 mem_size=$7"; } &
{ ansible-playbook download-k8.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
wait

echo "creating configuration"
{ ansible-playbook change-config.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
wait

echo "Deploying Kubernetes!!!! -> cd $5/$1/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh"
(cd $5/$1/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh)

echo "Updating PATH"
export PATH=$PATH:$5/$1/kubernetes/cluster/ubuntu/binaries/

echo "Trying addons!"
(cd $5/$1/kubernetes/cluster/ubuntu && KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh)



echo "Fix docker on minions. Need to re-run /root/kube/reconfDocker.sh for some reason after k8 deploy"
{ ansible-playbook fix-minions.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
wait

echo "All done. Try out your k8 cluster today! -ck"



