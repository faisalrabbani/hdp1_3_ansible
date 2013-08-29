#!/bin/bash

sudo yum remove oozie
sudo rm -rf /var/lib/oozie
sudo rm -rf /var/tmp/oozie
sudo rm -rf /usr/lib/oozie
sudo rm -rf /var/run/oozie
sudo rm -rf /etc/oozie
sudo rm -rf /var/db/oozie
sudo rm -rf /usr/share/doc/oozie-* 
sudo rm -rf /usr/bin/oozie
sudo rm -rf /var/log/oozie
sudo mkdir /etc/oozie
sudo mkdir /etc/oozie/conf
sudo chown -R oozie:hadoop /etc/oozie
