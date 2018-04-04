#!/bin/bash
# This shell script runs when the docker image starts.
# In this script, you configure your cluster parameters.

echo "starting ...."
wait_for_start() {
    "$@"
    while [ $? -ne 0 ]
    do
        echo 'waiting for couchbase to start'
        sleep 5
        "$@"
    done
}

# if this node should reach an existing server (a couchbase link is defined)  => env is set by docker compose link
if [ -n "${COUCHBASE_NAME:+1}" ]; then

    echo "add node to cluster"
    # wait for couchbase clustering to be setup
    wait_for_start couchbase-cli server-list -c $COUCHBASE_HOST:$COUCHBASE_PORT --username $ADMIN_LOGIN --password $ADMIN_PASSWORD

    echo "launch couchbase"
    /entrypoint.sh couchbase-server &

    # wait for couchbase to be up (this is the local couchbase belonging to this container)
    wait_for_start couchbase-cli server-info -c $COUCHBASE_HOST:$COUCHBASE_PORT --username $ADMIN_LOGIN --password $ADMIN_PASSWORD

    # add this new node to the cluster
    ip=`hostname --ip-address`
    #couchbase-cli server-add -c couchbase --cluster-username $ADMIN_LOGIN --cluster-password $ADMIN_PASSWORD --server-add=$ip:8091 --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PASSWORD

    echo "node added to cluster"

    # wait for other node to connect to the cluster
    #sleep 10

    echo "adding and rebalancing ..."

    # rebalance
    couchbase-cli rebalance -c $COUCHBASE_HOST --username $ADMIN_LOGIN --password $ADMIN_PASSWORD --server-add=$ip:$COUCHBASE_PORT --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PASSWORD --services=data,index,query
else

    echo "launch couchbase"
    /entrypoint.sh couchbase-server &

    # wait for couchbase to be up
    wait_for_start couchbase-cli server-info -c localhost:8091 --username $ADMIN_LOGIN --password $ADMIN_PASSWORD

    echo "start initial cluster configuration"

    # init the cluster
    couchbase-cli cluster-init -c $COUCHBASE_HOST:$COUCHBASE_PORT --cluster-username $ADMIN_LOGIN --cluster-password $ADMIN_PASSWORD --cluster-port=$COUCHBASE_PORT --services=data,index,query,fts --cluster-ramsize=512 --cluster-index-ramsize=256 --cluster-fts-ramsize=256 --index-storage-setting=default

    # create bucket data
    couchbase-cli bucket-create -c $COUCHBASE_HOST:$COUCHBASE_PORT --username $ADMIN_LOGIN --password $ADMIN_PASSWORD --bucket=default --bucket-type=couchbase --bucket-ramsize=256 --wait
fi

wait
