# settlemint/mongo

A MongoDB 4 image with a replicaset setup script added to enable change streams.

## Usage

```
version: '3.6'

services:
  mongo:
    container_name: 'mongo'
    image: 'settlemint/mongo:latest'
    command: mongod --replSet replicaset --smallfiles
    restart: always

  mongo-replicaset-setup:
    container_name: 'mongo-replicaset-setup'
    image: 'settlemint/mongo:latest'
    depends_on:
      - 'mongo'
    links:
      - mongo:mongo
    entrypoint: ['replicaset.sh']
```
