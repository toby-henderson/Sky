#Add 2 additional nodes to cluster (Nodes to carry out all services)

export CB_REST_USERNAME=admin; 
export CB_REST_PASSWORD=superuser;

couchbase-cli node-init -c [host]:8091 -u [admin] -p [password] [options]

couchbase-cli node-init -c localhost:8091 --node-init-data-path=/data/db \
--node-init-index-path=/data/index \
--node-init-hostname=`echo $( uname -n ).$(dnsdomainname)`


couchbase-cli server-add \
            --cluster=<Cluster Master Node Name>:8080 \     
            --server-add=`echo $( uname -n ).$(dnsdomainname)`:8091 \ 
            --server-add-username=node-username \ 
            --server-add-password=node-password \
            --index-storage-setting=memopt \
            --services=data,index,query

couchbase-cli server-add \
            --cluster=`echo $( uname -n ).$(dnsdomainname)`:8080 \     
            --server-add=`echo $( uname -n ).$(dnsdomainname)`:8091 \ 
            --server-add-username=node-username \ 
            --server-add-password=node-password \
            --index-storage-setting=memopt \
            --services=data,index,query


# Depending on the type of failure we have two options. 
#1. Graceful or hard failover
#2. Remove offending nodes from cluster via the rebalance functionality.

couchbase-cli failover -c <Cluster Node Name>:8091 -u Administrator -p password \
--server-failover=<Host Name of server to failover>

couchbase-cli rebalance-status -c <Cluster Node Name>:8080

#Or we could remove from cluster.

couchbase-cli rebalance -c <<HostName>>:8080
          --server-remove=<<HostName>>
