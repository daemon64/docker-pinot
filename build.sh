#!/bin/bash
declare -a components=("controller" "server" "broker" "quickstart-offline" "quickstart-realtime")
user="jfim"
version=$1

echo "Building base Pinot image $user/pinot with version $version"
docker build -t ${user}/pinot:$version -f Dockerfile-pinot --build-arg pinotVersion=$version .
docker tag ${user}/pinot:$version ${user}/pinot:latest

for component in "${components[@]}"
do
  echo "Building image $user/pinot-$component"
  docker build -t ${user}/pinot-${component}:$version -f Dockerfile-${component} --build-arg pinotVersion=$version .
done

echo "Pushing base Pinot image $user/pinot"
docker push ${user}/pinot:$version
docker push ${user}/pinot:latest

for component in "${components[@]}"
do
  echo "Pushing image $user/pinot-$component"
  docker tag ${user}/pinot-${component}:$version ${user}/pinot-${component}:latest
  docker push ${user}/pinot-${component}:$version
  docker push ${user}/pinot-${component}:latest
done
