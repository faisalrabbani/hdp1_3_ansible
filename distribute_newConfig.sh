#First stop cluster (HDFS & MR)
ansible-playbook site.yml --tags "stop_mr,stop_hdfs"
#Copy new config files
ansible-playbook site.yml --tags "distribute_config"
#Start cluster
ansible-playbook site.yml --tags "start_hdfs,start_mr"


