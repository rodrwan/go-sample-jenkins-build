#!/bin/bash
sed "s/tagVersion/$1/g" pods.yaml > app1.yaml
sed "s,repositoryUrl,$2,g" app1.yaml > app.yaml
rm app1.yaml