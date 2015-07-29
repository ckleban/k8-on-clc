#!/bin/sh
#
# deploy k8 cluster on clc

{ ansible-playbook create-servers.yml --extra-vars "server_group=ca2-k8-qa1 location=ca2 server_count=2 password_file=/root/passwords.yml" -vvvv; } &
{ ansible-playbook download-k8.yml --extra-vars "server_group=ca2-k8-qa1 location=ca2 server_count=2 password_file=/root/passwords.yml" -vvvv; } &
wait
{ ansible-playbook change-config.yml --extra-vars "server_group=ca2-k8-qa1 location=ca2 server_count=2 password_file=/root/passwords.yml" -vvvv; } &
wait
(cd /root/ca2-k8-qa1/kubernetes/cluster && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh)


