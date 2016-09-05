#! /bin/bash

export AWS_ACCESS_KEY_ID=`pass xebia/aws/ansible-key-id`
export AWS_SECRET_ACCESS_KEY=`pass xebia/aws/ansible-key-secret`
export DOCKER_HUB_USERNAME=`pass dockerhub/username`
export DOCKER_HUB_PASSWORD=`pass dockerhub/password`
