# This project

qewwqe : {{ site_name }}

# Requirements

The following software/modules are required to be able to use this repo :

- ansible (2.2, latest)
- python2
- pyapi-gitlab (python module for GitLab API)
- boto (python module for AWS API)

- An AWS key with the following policies:
    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess

- A zone handled by Route 53

# What you end up with

## The cluster itself

- 3 nodes cluster on AWS:
    - One "services" node
    - One "staging" node
    - One "production" node
- Each one of them runs:
    - Zookeeper
    - Mesos Slave
    - Mesos Master
    - Marathon
- The "services" node also runs the following services as marathon apps:
    - a pretty alternative Mesos UI
    - Traefik
    - GitLab
    - a GitLab CI runner
- The application click-count is deployed, depending on the targeted
  environment, on the staging and production nodes

## The services

- [GitLab](http://gitlab.xebia.horgix.fr)
- [Traefik](http://traefik.xebia.horgix.fr)
- [Mesos UI](http://cluster.xebia.horgix.fr)
- [This documentation](http://doc.xebia.horgix.fr)
