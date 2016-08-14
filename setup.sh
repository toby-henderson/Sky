#!/bin/bash
# install 
sudo yum install -y pkgconfig
#install coachbase meta data packages  
curl -O http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-2-x86_64.rpm 
sudo rpm -i couchbase-release-1.0-2-x86_64.rpm

if [ `rpm -q -a | grep -c "openssl"` -eq 1 ] 
then 
	yum -y update openSSL; 
else 
	yum -y install openSSL; 
fi

#Disable Transparent Huge Pages
cat << EOF > /etc/init.d/disable-thp
#!/bin/bash
### BEGIN INIT INFO
          # Provides:          disable-thp
          # Required-Start:    \$local_fs
          # Required-Stop:
          # X-Start-Before:    couchbase-server
          # Default-Start:     2 3 4 5
          # Default-Stop:      0 1 6
          # Short-Description: Disable THP
          # Description:       disables Transparent Huge Pages (THP) on boot
          ### END INIT INFO
          
          case \$1 in
          start)
          if [ -d /sys/kernel/mm/transparent_hugepage ]; then
          	echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
          	echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
          elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
          	echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/enabled
          	echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag
          else
          	return 0
          fi
          ;;
          esac
EOF

sudo chmod 755 /etc/init.d/disable-thp
sudo service disable-thp start

if [ ! `cat /sys/kernel/mm/redhat_transparent_hugepage/enabled` -eq "always madvise [never]" && `cat /sys/kernel/mm/redhat_transparent_hugepage/defrag` -eq "always madvise [never]" ]; then 
 exit 1
fi

#turn swappiness off
sudo sh -c 'echo 0 > /proc/sys/vm/swappiness'
sudo cp -p /etc/sysctl.conf /etc/sysctl.conf.`date +%Y%m%d-%H:%M`
sudo sh -c 'echo "" >> /etc/sysctl.conf'
sudo sh -c 'echo "#Set swappiness to 0 to avoid swapping" >> /etc/sysctl.conf'
sudo sh -c 'echo "vm.swappiness = 0" >> /etc/sysctl.conf' 

sudo yum -y update
sudo yum -y install couchbase-server

sudo service couchbase-server stop

sudo sed -i '/# End of file/i \
mongod \thard \tnofile \t250000 \
mongod \tsoft \tnofile \t250000' 
/etc/security/limits.conf

sudo sysctl -w net.ipv4.tcp_keepalive_time=600
echo "net.ipv4.tcp_keepalive_time=600" >> /etc/sysctl.conf
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=10
echo "net.ipv4.tcp_keepalive_intvl=10" >> /etc/sysctl.conf
sudo sysctl -w net.ipv4.tcp_keepalive_probes=9
echo "net.ipv4.tcp_keepalive_probes=9" >> /etc/sysctl.conf
sudo sysctl -w "net.ipv4.tcp_retries2=8"
echo "net.ipv4.tcp_retries2=8" >> /etc/sysctl.conf

#Scan for devices
for HOST in `sudo ls -1 /sys/class/scsi_host/host*/scan`; do echo $HOST; echo "- - -" > $HOST; done
for DISK in `sudo ls -1 /sys/class/scsi_disk/*:*:*/device/rescan`; do echo $DISK; echo '1' > $DISK; done

#Create Physical Devices
sudo pvcreate /dev/sdc
sudo pvcreate /dev/sdd

#create Volumn Groups 
vgcreate vg_data /dev/sdc
vgcreate vg_index /dev/sdd

#Create logical volumns
sudo lvcreate --name lv_data -l"+100%FREE" vg_datardm
sudo lvcreate --name lv_index -l"+100%FREE" vg_indexrdm

#Format the logical volumns -  this could be xfs 
sudo mkfs -t ext4  /dev/vg_data/lv_datardm
sudo mkfs -t ext4  /dev/vg_index/lv_index

sudo mkdir -p /data/db/
sudo mkdir -p /data/index/

sudo echo '/dev/sdc /data/db auto noatime,noexec,nodiratime 0 0' >> /etc/fstab
sudo echo '/dev/sdd /data/index auto noatime,noexec,nodiratime 0 0' >> /etc/fstab

#monunt storage
sudo mount -a /dev/sdc /data/db
sudo mount -a /dev/sdd /data/index

#change ownerships
sudo chown couchbase /data/db /data/index

sudo reboot