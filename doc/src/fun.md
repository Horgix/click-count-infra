# Zookeeper SERVERS

It uses the order in which they are given...

# Mesos-slave and AWS docker engine version

SURPRISE UPDATE, thx mesos

# GitLab first login

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

# GitLab CI runner token

need a token, how to register ? Again, badly documented.
Need to discover runners. End up hitting the API

Heureusement, le gitlab runner est en go et sait parser sa conf depuis l'env...
juste à automatiser le register à la création :)

# Pass files to docker inside runners

The volume is from the host ! BUild dir, etc

# Undocumented meta refresh_inventory

# Ansible's gitlab_user module is bugged :(
