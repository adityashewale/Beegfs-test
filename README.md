# Beegfs-test

Here by using script configuring beegfs file system 

Requirements 
1. 4 servers or vm for mgmt,meta-data,storage and client it can be possible on single vm or server. 
2. For storage and meta-data raw storage partion is required.
3. All 4 vm should have hostname same /etc/hosts entry and password less with each others.

In the below step -h is for hostname and -d is for block device.


Steps:

# chmod +x Beegfs-install.sh
#./Beegfs-install.sh -h mgmt,meta,storage,client -d /dev/sda,/dev/sdb 




