#!/bin/sh
#
# deploy k8 cluster on clc

server_group=$1
location=$2
server_count=$3
password_file=$4
working_dir=$5

echo "Starting servers and downloading k8"
{ ansible-playbook create-servers.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
{ ansible-playbook download-k8.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
wait

echo "creating configuration"
{ ansible-playbook change-config.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &
wait

echo "Deploying Kubernetes!!!! -> cd $5/$1/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh"
(cd $5/$1/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh)

echo "Updating PATH"
PATH=$PATH:$5/$1/kubernetes/cluster/ubuntu/binaries/

echo "Fix docker on minions. Need to re-run /root/kube/reconfDocker.sh for some reason after k8 deploy"
{ ansible-playbook fix-minions.yml --extra-vars "server_group=$1 location=$2 server_count=$3 password_file=$4 working_dir=$5"; } &

echo "All done. Try out your k8 cluster today! -ck"



