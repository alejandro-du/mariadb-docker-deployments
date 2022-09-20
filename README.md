# mariadb-docker-deployments

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder) that I use to set up [MariaDB](https://mariadb.com) to run some of my example applications.

## Requirements

  * A Linux environment. If you are on Windows use [WSL](https://learn.microsoft.com/windows/wsl).
  * [Docker](https://www.docker.com)

## Usage

  ⚠️ **WARNING**: These images are not intended for production environments. In most of the cases, if not all, the `root` user password is `password`! Also most images, if not all, create a `demo` database that the `user` user can access. This user's password also is `password`.

Build and publish the images:

  * Build the images by running the **build.sh** script.
  * Check the logs with **logs.sh**.
  * (Optional) publish the images on a Docker registry by customizing the `host` variable in the **publish.sh** script.

## Examples

The following sections show examples on how to use the images. Keep in mind that you might want to:

  * add `--restart unless-stopped` to let Docker start the container on boot,
  * replace `--net host` with `--publish 3306:3306` to customize the port on the host (the first one) or if you are on
  [Mac or Windows](https://docs.docker.com/network/host/#:~:text=The%20host%20networking%20driver%20only%20works%20on%20Linux%20hosts%2C%20and%20is%20not%20supported%20on%20Docker%20Desktop%20for%20Mac%2C%20Docker%20Desktop%20for%20Windows%2C%20or%20Docker%20EE%20for%20Windows%20Server),
  * add environment variables to configure the container,
  * change the `--name` option to use a custom name for the container.

### Single node

A container running [MariaDB Community Server](https://mariadb.com/products/community-server).

```bash
docker run --name mariadb --detach --net host mariadb-replication/single-node
```

### Primary

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) ready to act as a primary node.

```bash
docker run --name mariadb --detach --net host mariadb-replication/single-node
```

### Replica

A container running [MariaDB Community Server](https://mariadb.com/products/community-server) ready to act as a primary node.

```bash
docker run --detach --name mariadb-test-2 --net host --env MARIADB_PRIMARY_HOST=<PRIMARY_SERVER_IP_ADDRESS> mariadb-replication/replica
```

Note: If you run this on the same machine as the replica, change the port (for example `--publish 3307:3306`).
