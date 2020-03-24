#!/bin/bash
sed "s/tagVersion/$1/g" pods.yaml > app.yaml
sed "s/repositoryUrl/$2/g" app.yaml > app.yaml