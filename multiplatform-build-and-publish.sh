#!/bin/bash
echo "************************ publish *************************"

if [ "$1" == "es" ] && [ "$2" ]; then
	host=$2
	es="true"
else
	host=$1
fi

# Not working. See https://github.com/docker/buildx/issues/1642

docker buildx build --push --platform linux/amd64,linux/arm64 --file mariadb/Dockerfile --tag ${host}alejandrodu/mariadb .
docker buildx build --push --platform linux/amd64,linux/arm64 --file maxscale/Dockerfile --tag ${host}alejandrodu/mariadb-maxscale .

if [ "$es" ]; then
	echo "!!! PUBLISHING MARIADB ENTERPRISE SERVER TO $host !!!"
	read -p "Do you want to proceed? (yes/no) " yn

	case $yn in 
		yes ) echo OK...
			docker buildx build --push --build-arg CUSTOMER_DOWNLOAD_TOKEN=$CUSTOMER_DOWNLOAD_TOKEN --platform linux/amd64,linux/arm64 --file mariadb-es/Dockerfile --tag ${host}alejandrodu/mariadb-es .;;
		* ) echo exiting...
	esac
fi

echo
