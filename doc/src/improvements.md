# Zookeeper ID

Currently, Zookeeper IDs are taken from the tag "zkid" on the instances, which
will be kind of a pain to scale. It would be better if each Zookeeper could
discover its ID.

# Use Gitlab Container Registry

Since the [8.8
release](https://about.gitlab.com/2016/05/23/gitlab-container-registry/),
GitLab can provide a Docker private registry. It would be really nice to use
it; however, it has not been integrated in this project/demo, as it requires
passing SSL certificates to it, which are currently only known to Traefik.

# GitLab Runner health checks

Currently, there is no health chekcs on Marathon side for GitLab runners.
Since they don't listen for connection and directly connect to GitLab, there is
no real way to check for its aliveness; something based on the health check
type "command" which would hit GitLab API to detect if the runners is
referenced as active or not would be possible, but currently not implemented.

# Docker images based on Alpine

Currently, this project is using the most possible "standard" images, mainly
just using the "latest" tag. Reducing the global size of containers using ones
based on Alpine would be nice, but would maybe have to be benchmarked before.

# Make marathon json artifacts

http://docs.gitlab.com/ce/user/project/builds/artifacts.html

# Rolling upgrade without service interruption

# GitLab Runners unregistering

# Contribute a Marathon Ansible module

# Tailor needed AWS key policies

# Improve security groups

# Auto accept host ecdsa keys ?
