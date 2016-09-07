**If you want to directly jump to the "do it" part of this documentation, head
over to the ["How To" page](howto.md).**

# This project

This project aims at building to the CI/CD infrastructure for the [Click-Count
application](TODO), as asked by the following statement:

> Le livrable attendu doit être un repository sur GitHub contenant la
> **description de l’infrastructure** et du pipeline de livraison continu
> entièrement automatisés afin que la solution puisse être déployée sur un
> environnement différent.

This repository will allow you to spawn the so-said infrastucture, with the
following properties:

- Deployed with Ansible
- Based on AWS EC2
- Running **entirely** on Docker
- Using Zookeeper, Mesos and Marathon to deploy and orchestrate services and
  the application itself

The EC2 part can of course be replaced by any other IAAS provider, may it be
public or private, admitting some adaptations.

# Requirements

## On your machine

You will need the AWS key with the privilege described in the ["AWS
side"](index.md#aws-side) part at this path : `~/.ssh/ansible-click-count.pem`

The following software/modules are required to be able to use this repo:

- Ansible (2.2, latest)
- Python 2.7 (Ansible sadly doesn't work with Python 3)
- pyapi-gitlab (python module for GitLab API)
- boto (python module for AWS API)

**If you don't want to install all of these, it's fine; there is already a
Dockerfile packaging them right there for you so just make sure you have the
docker daemon running and run `docker build -t horgix/ansible-aws-gitlab . ` at
the root of this repository**.

## AWS side

Theses parts are also required on AWS side:

- An AWS user with the following policies:
    - AdministratorAccess
    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
- A DNS Zone managed by Route 53

# What you end up with

## The cluster itself

- 3 nodes cluster on AWS:
    - One "services" node (m4.large)
    - One "staging" node (t2.micro)
    - One "production" node (t2.micro)
- Each one of them runs:
    - Zookeeper
    - Mesos Slave
    - Mesos Master
    - Marathon
- The "services" node also runs the following services as Marathon apps:
    - [GitLab](https://about.gitlab.com/)
    - a [GitLab CI runner](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner)
    - [Traefik](http://traefik.io/)
    - a pretty [alternative Mesos UI](https://github.com/Capgemini/mesos-ui/)
- The application [click-count](https://github.com/Horgix/click-count-app) is
  deployed, depending on the targeted environment, on the staging and
  production nodes

# How it works

![Steps](images/steps.png)
