# mariadb-docker-deployments

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder) that I use to deploy [MariaDB](https://mariadb.com) to run some of my example applications.

## Requirements

  * A Linux environment (on Windows use [WSL](https://learn.microsoft.com/windows/wsl))
  * [Docker](https://www.docker.com)

## Usage

  ⚠️ **WARNING**: These images are not intended for production environments. In most of the cases the `root` user password is `password`! Also, most images create a `demo` database that the `user` user can access. This user's password also is `password`. Access and privileges are not restricted in database users assigned to replication (`replication_user`) or MaxScale (`maxscale`) and also use `password` as password.

Build the images:

  * Build the images with the **build.sh** script.
  * Check the logs with **logs.sh**.

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
Publish the images in the Docker registry by customizing the `host` variable in the **publish.sh** script.

## Examples

The following sections show examples on how to use the images. Keep in mind that you might want to:

  * change the `--name` option to use a custom name for the container.
  * add `--restart unless-stopped` to let Docker start the container on boot,
  * replace `--net host` with `--publish 3306:3306` to customize the port on the host (the first number) or if you are on
  [Mac or Windows](https://docs.docker.com/network/host/#:~:text=The%20host%20networking%20driver%20only%20works%20on%20Linux%20hosts%2C%20and%20is%20not%20supported%20on%20Docker%20Desktop%20for%20Mac%2C%20Docker%20Desktop%20for%20Windows%2C%20or%20Docker%20EE%20for%20Windows%20Server),
  * add environment variables to configure the container,

### Single node

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) listening on port 3306.

```bash
docker run --name mariadb \
	--detach \
	--net host \
	alejandrodu/mariadb-single-node
```

### Primary

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) listening on port 3306 and ready to act as a primary node in a replication cluster.

```bash
docker run --name mariadb \
	--detach \
	--net host \
	alejandrodu/mariadb-primary
```

### Replica

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) as a replica in read-only mode.

```bash
docker run --name mariadb \
	--detach \
	--net host \
	--env MARIADB_PRIMARY_HOST='<PRIMARY_SERVER_IP_ADDRESS>' \
	alejandrodu/mariadb-replica
```

Replace `<PRIMARY_SERVER_IP_ADDRESS>` with the ip address of the the primary node. To create additional replicas add `--server-id <SERVER_ID>` replacing `<SERVER_ID>` with an integer >= 3. In orchestrated environments use the `$RANDOM` [variable](https://tldp.org/LDP/abs/html/randomvar.html).

✏️ **Note:** If you run this on the same machine as the primary or another replica, change the port (for example `--publish 3307:3306`).

### MaxScale

A container running [MaxScale](https://mariadb.com/products/maxscale/) listening on port 4000 and ready to split reads and writes between replicas and primary nodes.

```bash
	docker run --name maxscale \
		--detach \
		--net host \
		--env MARIADB_HOST_1=<HOST_IP_1> \
		--env MARIADB_HOST_2=<HOST_IP_1> \
		--env MARIADB_HOST_3=<HOST_IP_1> \
		alejandrodu/mariadb-maxscale
```

Replace `<MARIADB_HOST_X>` with the IP address or hostname of the the MariaDB server to add. You can add as many servers as needed.

✏️ **Note:** If you run this on the same machine as the primary or a replica, change the port (for example `--publish 3307:3306`).
