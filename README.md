# Requirements

The following software/modules are required to be able to use this repo :

- ansible (2.2, latest)
- python2
- pyapi-gitlab (python module for GitLab API)
- boto (python module for AWS API)

# todo

change template ? tmp already exists

# Fun Parts

## Zookeeper SERVERS

It uses the order in which they are given...

## Mesos-slave and AWS docker engine version

SURPRISE UPDATE, thx mesos

## GitLab first login

* Look in the code for what makes it ask...
* End up discovering it can take something from env, undocumented

I'm automating the spawn of a Gitlab (gitlab/gitlab-ce Docker image) and the
creation of some groups/users/projects for a demo platform.

However, I can't find anything to automate the first "Reset your password" for
the root account after installation.
Any hint ? Things I've tried so far :

1. API; doesn't seem to have any endpoint for this use case
2. POST as if I was doing it from my browser; but the authenticity_token from
   rails would force me to GET and parse the page, which I would like to avoid
3. Playing with the assets/wrapper that is used as entrypoint/cmd of the docker
   image, but then I found by getting the user in the gitlab-rails console that
   it already as an encrypted_password and no field forcing a reset

## GitLab CI runner token

need a token, how to register ? Again, badly documented.
Need to discover runners. End up hitting the API

## GitLab Runner health checks

They don't listen on anything :(

Heureusement, le gitlab runner est en go et sait parser sa conf depuis l'env...
juste à automatiser le register à la création :)

## Pass files to docker inside runners

The volume is from the host ! BUild dir, etc

## Undocumented meta refresh_inventory

# Improvements

## Zookeeper ID

Currently, Zookeeper IDs are taken from the tag "zkid" on the instances, which
will be kind of a pain to scale. It would be better if each Zookeeper could
discover its ID.

## Use Gitlab Container Registry

Since the [8.8
release](https://about.gitlab.com/2016/05/23/gitlab-container-registry/),
GitLab can provide a Docker private registry. It would be really nice to use
it; however, it has not been integrated in this project/demo, as it requires
passing SSL certificates to it, which are currently only known to Traefik.

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

## Pull images only when required

## Wait for Gitlab to be available before creating groups

## Marathon apps : check for latest

## Ansible's module is bugged :(

## Unregister runners

## Get Docker hub credentials from env

"{{ lookup('env','xxxx') }}"

+ pass ?
