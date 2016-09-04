# requirements

pyapi-gitlab
boto for ec2
ansible 2.2 >

# todo

better IAM for ansible key (ec2 full atm)
alpine

gitlab runner unregister ?

change template ? tmp already exists

# fun parts

Zookeeper SERVERS
Mesos-slave and AWS docker engine version
Gitlab first login. Look in the code for what makes it ask... to end up
discovering it can take something from env, undocumented
Gitlab CI runner : need a token, how to register ? Again, badly documented.
Need to discover runners. End up hitting the API

Gitlab runners health checks ? :(


Heureusement, le gitlab runner est en go et sait parser sa conf depuis l'env...
juste à automatiser le register à la création :)

Hi everyone ! I have a maybe unusual question : I'm automating the spawn of a
Gitlab (gitlab/gitlab-ce
Docker image) and the creation of some groups/users/projects for a demo
platform. However, I can't find
anything to automate the first "Reset your password" for the root account after
installation. Any hint
? Things I've tried so far : 1) API; doesn't seem to have any endpoint for this
use case 2) POST as if
I was doing it from my browser; but the authenticity_token from rails would
force me to GET and parse
the page, which I would like to avoid 3) Playing with the assets/wrapper that
is used as entrypoint/cmd
of the docker image, but then I found by getting the user in the gitlab-rails
console that it already
as an encrypted_password and no field forcing a reset
How would someone go about automating this particular point ?


fun : pass files to docker inside runners, because the volume

# Improvements

## Zookeeper ID

Currently, Zookeeper IDs are taken from the tag "zkid" on the instances, which
will be kind of a pain to scale. It would be better if each Zookeeper could
discover its ID.

## Docker Registry

It would be nice to use the built-in Gitlab Docker registry

## Gitlab CI variables

Could be cool to define Gitlab CI variables from the API

## Cleanup Gitlab CI builddir

Have to add a step that **always** run to clean /tmp gitlab build directories

## Mesos UI

Maybe deploy a nicer Mesos UI ?
