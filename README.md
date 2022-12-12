# settlemint/mongo

A MongoDB 6 image with a replicaset setup script added to enable change streams.

## Usage

```
version: '3.6'

services:
  mongo:
    container_name: 'mongo'
    image: 'settlemint/mongo:latest'
    command: mongod --replSet replicaset
    hostname: mongo
    ports:
      - '27017:27017'

  mongo-replicaset-setup:
    container_name: 'mongo-replicaset-setup'
    image: 'settlemint/mongo:latest'
    depends_on:
      - 'mongo'
    links:
      - mongo:mongo
    entrypoint: [ './replicaset.sh' ]
```

You can connect to it via Studio 3T like this: <https://cln.sh/mFPIfi>
Or via `mongodb://localhost:27017/?replicaSet=replicaset&readPreference=primaryPreferred`
