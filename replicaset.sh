#!/bin/bash

get_machine_ip() {
    local -a ip_addresses
    local hostname
    hostname="$(hostname)"
    read -r -a ip_addresses <<< "$(dns_lookup "$hostname" | xargs echo)"
    if [[ "${#ip_addresses[@]}" -gt 1 ]]; then
        warn "Found more than one IP address associated to hostname ${hostname}: ${ip_addresses[*]}, will use ${ip_addresses[0]}"
    elif [[ "${#ip_addresses[@]}" -lt 1 ]]; then
        error "Could not find any IP address associated to hostname ${hostname}"
        exit 1
    fi
    echo "${ip_addresses[0]}"
}

get_mongo_hostname() {
    if [[ -n "$MONGODB_ADVERTISED_HOSTNAME" ]]; then
        echo "$MONGODB_ADVERTISED_HOSTNAME"
    else
        get_machine_ip
    fi
}

mongodb1=`getent hosts ${MONGO1:-"mongo"} | awk '{ print $1 }'`
externalMongo=`get_mongo_hostname()`
port=${PORT:-27017}

echo "Waiting for mongo (at host $mongodb1) to start up.."
until mongo --host ${mongodb1}:${port} --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done
echo "Done"

echo replicaset.sh time now: `date +"%T" `
mongo --host ${mongodb1}:${port} <<EOF
  var cfg = {
        "_id": "${RS:-"replicaset"}",
        "protocolVersion": 1,
        "members": [
            {
                "_id": 0,
                "host": "${externalMongo}:${port}"
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
    rs.secondaryOk();
EOF
