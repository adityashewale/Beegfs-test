#!/bin/bash

#mgmt=$1

#meta=$2
#storage=$3
#client=$4

#echo mgmt ip  $mgmt

#echo metadata  $meta

#echo storage ip $storage

#echo client ip $client


while getopts "h:d:" catchvar
do
        args=$OPTARG
        case $catchvar in
                h)
                        echo "Hostnames : $args"
                        ah=$args
                ;;
                d)
                        echo "Block device : $args"
                        bd=$args
                ;;
                *)
                        echo "option not found -h is for hostname and -d for block device    use -h mgmt-hostname,metadata-hostname2,storage-hostname3,client-hostname -d /dev/sda,/dev/sdb,/dev/sdd"
                ;;
        esac


done


IFS="," read -a h <<< $ah
IFS="," read -a d <<< $bd


##########   Created storage pool #############

echo "ssh  ${h[1]} mkfs.ext4 ${d[0]}"

echo "ssh ${h[1]} mkdir /meta-data "

echo "ssh ${h[1]} mount ${d[0]} /meta-data"


echo "ssh ${h[3]}  mkfs.xfs  ${d[1]}"
echo "ssh ${h[3]}  mkfs.xfs  ${d[2]}"

echo "ssh ${h[3]}  mkdir   /data1 "
echo "ssh ${h[3]}  mkdir   /data2 "

echo "ssh ${h[3]}  mount   ${d[1]}  /data1"
echo "ssh ${h[3]}  mount   ${d[2]}  /data2"





#cho ${h[0]}

#fh=`echo $ah | awk -F ',' '{print $1}'`

#sh=`echo $ah | awk -F ',' '{print $2}'`

#th=`echo $ah | awk -F ',' '{print $3}'`


#fcl=`echo $ah| awk -F ',' '{print $3}'`



#mgmt=$fh

#meta=$sh

#storage=$th

#client=$fcl

cat <<EOT > b.repo
[beegfs]
name=BeeGFS 7.2 (rhel8)
# If you have an active BeeGFS support contract, use the alternative URL below
# to retrieve early updates. Replace username/password with your account for
# the BeeGFS customer login area.
#baseurl=https://username:password@www.beegfs.io/login/release/beegfs_7.2/dists/rhel8
baseurl=https://www.beegfs.io/release/beegfs_7.2/dists/rhel8
gpgkey=https://www.beegfs.io/release/beegfs_7.2/gpg/RPM-GPG-KEY-beegfs
gpgcheck=0
enabled=1
EOT

       for i in  ${h[@]}
       
do
       echo "scp beegfs.repo $i:/etc/yum.repos.d/"
	if [[ $i == ${h[0]} ]]
  	then
        echo "Installing packages on management server"
       echo " ssh $i yum -y install beegfs-mgmtd "

        fi
       
	if [[ $i == ${h[1]} ]]
        then

       echo "Installing packages on metadata server"
       echo "ssh $i yum -y install beegfs-meta libbeegfs-ib"

        fi
       if [[ $i == ${h[2]} ]]
       then

       echo "Installing packages on storage server"
      echo " ssh $i yum -y install beegfs-meta libbeegfs-ib  "

       fi
	if [[ $i == ${h[3]} ]]
then
       
       echo "Installing packages on client  server"
       
       echo "ssh $i yum -y install beegfs-client beegfs-helperd beegfs-utils"


fi
done


echo "ssh ${h[1]}  /opt/beegfs/sbin/beegfs-setup-meta -p /data/beegfs/beegfs_meta -s 2 -m ${h[0]}"

echo "ssh ${h[2]} /opt/beegfs/sbin/beegfs-setup-storage -p /data1 -s 3 -i 101 -m ${h[0]}"


echo "ssh ${h[3]} /opt/beegfs/sbin/beegfs-setup-client -m ${h[0]}"


echo "ssh ${h[0]}  systemctl start beegfs-mgmtd "

echo "ssh ${h[1]}   systemctl start beegfs-meta "

echo "ssh ${h[2]}   systemctl start beegfs-storage"

echo "ssh ${h[3]}   systemctl start beegfs-storage;systemctl start beegfs-client "


