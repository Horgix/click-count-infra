# Requirements

The following software/modules are required to be able to use this repo :

- ansible (2.2, latest)
- python2
- pyapi-gitlab (python module for GitLab API)
- boto (python module for AWS API)

# Fun Parts

## Zookeeper SERVERS

It uses the order in which they are given...

## Mesos-slave and AWS docker engine version

SURPRISE UPDATE, thx mesos

## GitLab first login

When you first install GitLab, it automatically set a random password for the
root account and force you to change it at your first connection. For a
traditional use, it's not a big deal, but when you're trying to automate the
GitLab spawn and configuration... it is painful.

So, since there is absolutely no documentation on this usecase, I thought about
these 3 ways to solve it :

1. Reset the password through the API. Except it doesn't have any endpoint for
   this initial password, and we wouldn't be able to authenticate to the API
   anyway
2. Just POST the answer as if we did it from a browser. Except GitLab is based
   on rails, which as built-in authenticity_token handling to avoid CSRF; so we
   would have to GET the page first, then parse it, the POST the answer... no
   way.
3. Play with the assets/wrapper that is used as entrypoint/CMD of the docker
   image

After investigating on this 3rd point, I finaly realized that it's possible to
set the root password at installation through environment, which is documented
nowhere ! See
https://gitlab.com/gitlab-org/gitlab-ce/blob/master/db/fixtures/production/001_admin.rb
for the code.

## GitLab CI runner token

need a token, how to register ? Again, badly documented.
Need to discover runners. End up hitting the API

Heureusement, le gitlab runner est en go et sait parser sa conf depuis l'env...
juste à automatiser le register à la création :)

## Pass files to docker inside runners

The volume is from the host ! BUild dir, etc

## Undocumented meta refresh_inventory

# Improvements ideas

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

## GitLab Runner health checks

Currently, there is no health chekcs on Marathon side for GitLab runners.
Since they don't listen for connection and directly connect to GitLab, there is
no real way to check for its aliveness; something based on the health check
type "command" which would hit GitLab API to detect if the runners is
referenced as active or not would be possible, but currently not implemented.
