## Cleanup Gitlab CI builddir

Have to add a step that **always** run to clean /tmp gitlab build directories

## AWS Keys rights

Currently, the aws key used to deploy this has ec2 and route53 full
permissions, which could be restricted.

## Security groups

Security groups currently let everything from everywhere connect...

## Docker images

Use the ones based on Alpine !

## Still have to accept keys manually

## Wait for Gitlab to be available before creating groups

## Ansible's gitlab_user module is bugged :(

## Unregister runners

## Add cache for maven

