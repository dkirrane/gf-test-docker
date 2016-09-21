#!/bin/bash

function runCmd {
    echo "\$ $@" ; "$@" ;
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Failed to run with $1" >&2
        exit
    fi
    return $status
}

# Determine default interface & get the Host IP address
IFACE=$(ip route list | awk '/^default/{ print $5 }' | tail -n -1)
export HOST_IP=`ip addr show ${IFACE} | awk '/inet / {print $2}' | cut -d/ -f1`

echo -e "\n"
echo -e "HOST_IP=${HOST_IP}"
echo -e "\n"

docker-compose -f bdd.yml down

echo -e "\n\n"

if git diff-index --quiet HEAD --; then
	# no local git changes we can pull latest
	runCmd git pull --rebase origin master
else
	# there are local git changes we cannot pull latest
	echo -e "WARNING You have local changes. A git pull will not be performed"
fi

echo -e "\n\n"
runCmd docker-compose -f bdd.yml build --force-rm mvngit
runCmd docker-compose -f bdd.yml build --force-rm --no-cache bdd
# runCmd docker-compose -f bdd.yml build --force-rm bdd
echo -e "\n\n"
runCmd docker-compose -f bdd.yml up -d
echo -e "\n\n"
echo -e "You can follow BDD test progress with this command:\t docker logs --follow bdd"
