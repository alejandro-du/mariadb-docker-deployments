# mariadb-docker-deployments

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

## Using the images

  ⚠️ **WARNING**: THESE IMAGES ARE NOT INTENDED FOR PRODUCTION ENVIRONMENTS!

See the **[test.sh](test.sh)** and [mariadb.stack.yml](stacks/mariadb.stack.yml) files for examples on how to use the images.
