#!/bin/bash
declare -a components=("controller" "server" "broker" "quickstart-offline" "quickstart-realtime")
user="jfim"

echo "Building base Pinot image $user/pinot"
docker build -t ${user}/pinot:latest -f Dockerfile-pinot .

for component in "${components[@]}"
do
  echo "Building image $user/pinot-$component"
  docker build -t ${user}/pinot-${component}:latest -f Dockerfile-${component} .
done

echo "Pushing base Pinot image $user/pinot"
docker push ${user}/pinot:latest

for component in "${components[@]}"
do
  echo "Pushing image $user/pinot-$component"
  docker push ${user}/pinot-${component}:latest
done
