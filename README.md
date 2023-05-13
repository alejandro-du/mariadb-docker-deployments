# mariadb-docker-deployments

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder) that I use to deploy [MariaDB Enterprise Server](https://mariadb.com) to run some of my example applications.

## Requirements

  * A Linux environment (on Windows use [WSL](https://learn.microsoft.com/windows/wsl))
  * [Docker](https://www.docker.com)

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

See the **[test.sh](test.sh)** and [replication.stack.yml](stacks/replication.stack.yml) files for examples on how to use the images.
