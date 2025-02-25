# mariadb-docker-deployments

⚠️ **DEPRECATED: The official MariaDB image includes options to automatically configure replication (via the MARIADB_REPLICATION_USER, MARIADB_REPLICATION_PASSWORD_HASH, and MARIADB_REPLICATION_PASSWORD (environment variables)[https://mariadb.com/kb/en/mariadb-server-docker-official-image-environment-variables/]).**

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder) that I use to deploy [MariaDB Enterprise Server](https://mariadb.com/products/enterprise/), [MariaDB Community Server](https://mariadb.com/products/community-server/), and [MariaDB MaxScale](https://mariadb.com/products/maxscale/) to run some of my example applications and demos.

## Requirements

  * A Linux or Mac environment (on Windows use [WSL](https://learn.microsoft.com/windows/wsl))
  * [Docker](https://www.docker.com)
  * (Optional) A MariaDB [Customer Download Token](https://mariadb.com/docs/xpand/deploy/token/) if you want to use [MariaDB Enterprise](https://mariadb.com/products/enterprise/).

## Building the images

  ⚠️ **WARNING**: THESE IMAGES ARE NOT INTENDED FOR PRODUCTION ENVIRONMENTS!

Build the images using the **build.sh** script:
```shell
./build.sh
```

**Note:** If you want to build the MariaDB Enterprise image, you need to pass `es` as a parameter to `build.sh`. You also need to define the following environment variable using your [Customer Download Token](https://mariadb.com/docs/xpand/deploy/token/) value:

```
export CUSTOMER_DOWNLOAD_TOKEN=xxxxx-xxxx-xxxxx-xxx-xxxxx 
```

### Publishing the images (optional)

Create a private registry:

```shell
docker run --name docker-registry \
	--detach \
	--restart=always \
	--mount source=docker-registry,target=/var/lib/registry \
	--publish 5000:5000 \
	--env REGISTRY_STORAGE_DELETE_ENABLED=true \
	registry:2
```

Publish the images in the Docker registry by passing the registry host to the **publish.sh** script (add a trailing `/`):

```shell
./publish.sh your.hostname.local:5000/
```

You might have to list the new registry as insecure in the `/etc/docker/daemon.json` file of any machine from which you want to use the images:

```json
{
  "insecure-registries" : ["your.hostname.local:5000"]
}
```

  **Note:** If you want to publish the MariaDB Enterprise image, pass `es` as a parameter of `publish.sh` followed by the URL of your **private** Docker registry.

⚠️ **WARNING:** Don't push the MariaDB Enterprise Docker image to a public or unsecured Docker registry if you don't want your private [Customer Download Token](https://mariadb.com/docs/xpand/deploy/token/) to be exposed.

## Using the images

  ⚠️ **WARNING**: THESE IMAGES ARE NOT INTENDED FOR PRODUCTION ENVIRONMENTS!

See the **[test.sh](test.sh)** and [mariadb.stack.yml](stacks/mariadb.stack.yml) files for examples on how to use the images.
