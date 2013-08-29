#!/bin/bash

ansible all -k -K -m shell -a "sed -i 's/MTU=1500/MTU=9000/g' /etc/sysconfig/network-scripts/ifcfg-eth1"
ansible all -k -K -m shell -a "sed -i 's/MTU=1500/MTU=9000/g' /etc/sysconfig/network-scripts/ifcfg-eth2"

ansible all -k -K -m shell -a "sudo service network restart"
