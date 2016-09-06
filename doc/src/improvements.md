**Since this project as been made from scratch in a week, there is a room for a
lot of improvements. This is a list of some ideas that could be implemented
with a bit more time and depending on the needs.**

# Zookeeper IDs

Currently, Zookeeper IDs are taken from the tag `zkid` on the instances, which
will be kind of a pain to handle if we introduce autoscaling of the
infrastructure. It would be better if each Zookeeper could discover its ID.

# Gitlab Container Registry

Since the [8.8
release](https://about.gitlab.com/2016/05/23/gitlab-container-registry/),
GitLab can provide a Docker private registry. It would be really nice to use
it; however, it has not been integrated in this project/demo, as it requires
passing SSL certificates to it, which are currently only known to Traefik.

# GitLab Runner health checks

Currently, there is no health chekcs on Marathon side for GitLab runners.
Since they don't listen for connections and directly connect to GitLab, there
is no real way to check for its aliveness; something based on the health check
type "command" which would hit GitLab API to detect if the runners is
referenced as active or not would be possible, but currently not implemented.

# Docker images based on Alpine

Currently, this project is using the most possible "standard" images, mainly
just using the "latest" tag. Reducing the global size of containers using ones
based on Alpine would be nice, but would maybe have to be benchmarked before.

# Make marathon json artifacts

GitLab CI knows [how to store build
artifacts](http://docs.gitlab.com/ce/user/project/builds/artifacts.html). The
main artifact currently is the Docker image built from the source code, which
is already sent to the Docker Hub. Storing the generated
`marathon_app_staging.json` and `marathon_app_production.json` would make
sense.

# Rolling upgrade without service interruption

Currently, if we try to run the app with less than 300MB, it simply ends up
behind killed by the oom killer:

    $ docker run -it --rm -m 200m horgix/click-count
    $ dmesg
    [ 5662.970129] Memory cgroup out of memory: Kill process 13119 (java) score 986 or sacrifice child
    [ 5662.970139] Killed process 13119 (java) total-vm:3725396kB, anon-rss:201312kB, file-rss:0kB, shmem-rss:0kB

Furthermore, the t2.micro EC2 are given "0.5GB" of memory, actually reported as
"497" by Mesos.

So, at the end, it's impossible to have 2 instances of the click-count
application running side by side on the same t2.micro instance.

So we have 2 solutions to allow Marathon to update the application :

1. Set the "minimumHealthCapacity" to 0, allowing Marathon to completely
   shutdown the "old" application before starting the new one
2. Set the "mem" resource limitation to 0, asking Mesos to not limit the memory
   used by the running container, which will allow it to make offers to
   Marathon so it could do a proper rolling upgrade

The first solution has been chosen, since the second one would introduce the
risk of anyway having one or both instances of the application killed by the
oom killer. The best case, of course, would be to run on something better than
t2.micro instance, or having more of them.

# GitLab Runners unregistering

# Contribute a Marathon Ansible module

# Tailor needed AWS key policies

# Improve security groups

# Auto accept host ecdsa keys ?

## Work without Route 53

## Run Traefik on each node
