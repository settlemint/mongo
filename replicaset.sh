#!/bin/bash

mongodb1=`getent hosts ${MONGO1:-"mongo"} | awk '{ print $1 }'`

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
                "host": "localhost:${port}"
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
    rs.secondaryOk();
EOF
