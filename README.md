# mariadb-docker-deployments (armv7)

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder) that I use to deploy [MariaDB](https://mariadb.com) on armv7 architectures to run some of my example applications.

## Requirements

  * A Linux environment
  * [Docker](https://www.docker.com)

## Usage

  ⚠️ **WARNING**: These images are not intended for production environments. In most of the cases the `root` user password is `password`! Also, most images create a `demo` database that the `user` user can access. This user's password also is `password`. Access and privileges are not restricted in database users assigned to replication (`replication_user`) or MaxScale (`maxscale`) and also use `password` as password.

To build the images run the **build.sh** script.

### Publish the images (optional)

Create a private registry:

```shell
docker run --name docker-registry \
	--detach \
	--restart=always \
	--mount source=docker-registry,target=/var/lib/registry \
	--net host \
	--env REGISTRY_STORAGE_DELETE_ENABLED=true \
	registry:2
```
Publish the images in the Docker registry by passing the registry host to the **publish.sh** script:

```
./publish.sh your.hostname.local:5000
```

You might have to list the new registry as insecure in the `/etc/docker/daemon.json` file of any machine from which you want to use the images:

```json
{
  "insecure-registries" : ["your.hostname.local:5000"]
}
```

## Examples

The following sections show examples on how to use the images. Keep in mind that you might want to:

  * change the `--name` option to use a custom name for the container.
  * add `--restart unless-stopped` to let Docker start the container on boot,
  * replace `--net host` with `--publish 3306:3306` to customize the port on the host (the first number) or if you are on
  [Mac or Windows](https://docs.docker.com/network/host/#:~:text=The%20host%20networking%20driver%20only%20works%20on%20Linux%20hosts%2C%20and%20is%20not%20supported%20on%20Docker%20Desktop%20for%20Mac%2C%20Docker%20Desktop%20for%20Windows%2C%20or%20Docker%20EE%20for%20Windows%20Server),
  * add environment variables to configure the container.

### Primary

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) listening on port 3306 and ready to act as a primary node in a replication cluster.

```bash
docker run --name mariadb \
	--detach \
	--net host \
	alejandrodu/mariadb-arm-primary
```

### Replica

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) as a replica in read-only mode.

```bash
docker run --name mariadb \
	--detach \
	--net host \
	--env MARIADB_PRIMARY_HOST='<PRIMARY_SERVER_IP_ADDRESS>' \
	alejandrodu/mariadb-arm-replica
```

Replace `<PRIMARY_SERVER_IP_ADDRESS>` with the ip address of the the primary node.

✏️ **Note:** If you run this on the same machine as the primary or another replica, change the port (for example `--publish 3307:3306`).

### Deploying a Docker Swarm stack

Edit the **stacks/replication.stack.yml** file to set the number of replicas that you want to deploy.
Create a [Docker Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/) and run the following on the manager node:

```bash
docker stack deploy -c stacks/replication.stack.yml mariadb
```