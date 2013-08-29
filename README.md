HDP 1.3 install with Ansible
==============
Copy the ansible_hosts file to a different file and open it.

	#cp ansible_hosts ansible_hosts_clusterN
	#vi ansible_hosts_cluterN

Do not change the values which are enclosed in “[ ]”. You need to change the names of the server. More specifically you need to change the lines which are after: 
-	[namenode]
-	[secondary_namenode]
-	[datanodes]
-	[jobtracker]
-	[history_server]
-	[client_nodes]
-	[oozie] 
-	[ganglia_master]
-	[nagios_master]
-	[hiveMetastore] if you are installing a metastore for hive
-	[hbaseMaster] and [hbaseRegionServers] – if you are installing HBase
-	[zookeeper] – if you are installing Zookeeper (if you are installing HBase, you need to install Zookeeper)

Set the ANSIBLE_HOSTS environmental variable to the previously created file:

	# export ANSIBLE_HOSTS=~/ansible_hosts_clusterN

In the ansible hosts file we are using groups of groups and assign variables/hosts only to groups. (This is done with the “groupname: children” construction.) 

Note: For Hadoop it’s advised to run the TaskTracker and Datanode daemons on each slave node, that’s why we have 
[tasktrackers:children]
datanodes
specified in the file.

Setting kernel parameters on the physical machines (slaves):
1.	vm.swappiness is a Linux Kernel Parameter that controls how aggressively memory pages are swapped to disk. It can be set to a value between 0-100; the higher the value, the more aggressive the kernel is in seeking out inactive memory pages and swapping them to disk. On most systems, it is set to 60 by default. This is not suitable for Hadoop clusters nodes, because it can cause processes to get swapped out even when there is free memory available. This can affect stability and performance, and may cause problems such as lengthy garbage collection pauses for important system daemons. It is recommended that you set this parameter to 0. 
2.	vm.overcommit_memory & vm.overcommit_ratio
Processes commonly allocate memory by calling the function malloc(). The kernel decides if enough RAM is available and either grants or denies the allocation request. Linux (and a few other Unix variants) support the ability to overcommit memory; that is, to permit more memory to be allocated than is available in physical RAM plus swap. This is scary, but sometimes it is necessary since applications commonly allocate memory for “worst case” scenarios but never use it.
When a process forks, or calls the fork() function, its entire page table is cloned. In other words, the child process has a complete copy of the parent’s memory space, which requires, as you’d expect, twice the amount of RAM. If that child’s intention is to immediately call exec() (which replaces one process with another) the act of cloning the parent’s memory is a waste of time. Because this pattern is so common, the vfork() function was created, which unlike fork(), does not clone the parent memory, instead blocking it until the child either calls exec() or exits. The problem is that the HotSpot JVM developers implemented Java’s fork operation using fork() rather than vfork().
So why does this matter to Hadoop? Hadoop Streaming—a library that allows MapReduce jobs to be written in any language that can read from standard in and write to standard out—works by forking the user’s code as a child process and piping data through it. This means that not only do we need to account for the memory the Java child task uses, but also that when it forks, for a moment in time before it execs, it uses twice the amount of memory we’d expect it to. For this reason, it is sometimes necessary to set vm.overcommit_memory to the value 1 (one) and adjust vm.overcommit_ratio accordingly. 
These parameters should be set in /etc/sysctl.conf.
To achieve these settings you can run the tasks/kernel_param.yml ansible playbook:

	#ansible_playbook –k –K tasks/kernel_params.yml

To install the cluster run:

	#ansible_playbook –k –K site.yml –tags=”install,install_nagios,install_oozie”

This script will do the following:
-	install NTPD
-	shut down IP tables
-	Disable IPv6
-	Disable SELinux
-	Set ulimit -- A busy Hadoop daemon might need to open a lot of files. The open fd ulimit in Linux defaults to 1024, which might be too low. You can set to something more generous — maybe 16384. Setting this an order of magnitude higher (e.g., 128K) is probably not a good idea. No individual Hadoop daemon is supposed to need hundreds of thousands of fds; if it’s consuming that many, then there’s probably an fd leak or other bug that needs fixing. You can set the ulimit for the hadoop user in /etc/security/limits.conf; this mechanism will set the value persistently. Make sure pam_limits is enabled for whatever auth mechanism the hadoop daemon is using.
-	Install Java 1.6 from Oracle
-	Install Hortonworks HDFS/MapReduce, distribute configuration files and start the cluster


Afterwards we should install Ganglia:

	#ansible_playbook –k –K site.yml –tags=”install_ganglia”
	#ansible_playbook –k –K site.yml –tags=”config_ganglia”
	#ansible_playbook –k –K site.yml –tags=”start_ganglia,start_nagios”

Depending what else you need you can do:

	#ansible_playbook –k –K site.yml –tags=”install_hiveM,install_hive”
	#ansible_playbook –k –K site.yml –tags=”install_pig”
	#ansible_playbook –k –K site.yml –tags=”install_zookeeper,install_hbase”


