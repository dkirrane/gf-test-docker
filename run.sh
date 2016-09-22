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

read -r -p "Enter GitHub username>" username
export GITHUB_USERNAME=${username}

read -r -p "Enter GitHub password>" username
export GITHUB_PASSWORD=${password}

echo -e "\n\n"

docker-compose down

echo -e "\n\n"

runCmd docker-compose build --no-cache --force-rm

echo -e "\n\n"
runCmd docker-compose up -d
echo -e "\n\n"

docker logs --follow gitflow-test
