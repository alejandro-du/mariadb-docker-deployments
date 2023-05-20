echo "************************ publish *************************"

if [ "$1" == "es" ] && [ "$2" ]; then
	host=$2
	es="true"
else
	host=$1
fi

docker tag alejandrodu/mariadb ${host}alejandrodu/mariadb
docker push ${host}alejandrodu/mariadb

docker tag alejandrodu/mariadb-maxscale ${host}alejandrodu/mariadb-maxscale
docker push ${host}alejandrodu/mariadb-maxscale

if [ "$es" ]; then
	echo "!!! PUBLISHING MARIADB ENTERPRISE SERVER TO $host !!!"
	read -p "Do you want to proceed? (yes/no) " yn

	case $yn in 
		yes ) echo OK...
			docker tag alejandrodu/mariadb-es ${host}alejandrodu/mariadb-es
			docker push ${host}alejandrodu/mariadb-es;;
		* ) echo exiting...
	esac
fi

echo
