# AWS

## AWS Keys rights

Currently, the aws key used to deploy this has ec2 and route53 full
permissions, which could be restricted.

## Security groups

Security groups currently let everything from everywhere connect...

# Infra

## Docker images

Use the ones based on Alpine !

## Still have to accept keys manually

## Ansible's gitlab_user module is bugged :(

## Unregister runners

# CI

## Add cache for maven

## Cleanup Gitlab CI builddir

Have to add a step that **always** run to clean /tmp gitlab build directories

