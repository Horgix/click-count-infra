This project has been really fun, and I thought I would detail some of the
surprising and intersting points I encountered during this week.

# Zookeeper SERVERS

While trying to use the [mesoscloud/zookeeper Docker
image](https://hub.docker.com/r/mesoscloud/zookeeper/), I originally used
hardcoded IP to configure Zookeeper with the list of its nodes.

The zookeeper image can indeed be configured at runtime with the "SERVERS"
environment variable, under the following form :

    SERVERS=first_node_ip,second_node_ip,third_node_ip

Obviously, since this approach is absolutely neither flexible nor scalable, I
then decided to use the dynamic inventory from EC2 to populate this list of
servers, which looks like that in Jinja :

    zk_nodes: "{% for host in groups['ec2'] %}{{ hostvars[host]['ec2_private_ip_address'] }}{% if not loop.last %},{% endif %}{% endfor %}"

We just loop through the hosts referenced under the 'ec2' group, take each host
IP address, and separate them with comas.

Well, this should work, shouldn't it ?

At this point, it's worth mentioning that we also pass a "MYID" environment
variable to the zookeeper container, referencing... well, its ID.

How does this matter ?

The SERVERS and MYID environment variables are used by the
[entrypoint.sh](https://github.com/mesoscloud/zookeeper/blob/master/3.4.8/centos/7/entrypoint.sh)
script used as entrypoint for the image.

The following parts are what interests us :

    echo "${MYID:-1}" > /tmp/zookeeper/myid

It just fill a file with the Zookeeper ID, everything good here. Then, a few
lines later:

    printf '%s' "$SERVERS" | awk 'BEGIN { RS = "," }; { printf "server.%i=%s:2888:3888\n", NR, $0 }' >> /opt/zookeeper/conf/zoo.cfg

The important part here is the `server.%i`, with increment at each node in the
list.

So, this environment variable:

    SERVERS=first_node_ip,second_node_ip,third_node_ip

is transformed into this configuration :

    server.1=first_node_ip
    server.2=second_node_ip
    server.3=third_node_ip

# GitLab first login automation

When you first install GitLab, it automatically sets a random password for the
root account and force you to change it at your first connection. For a
traditional use, it's not a big deal, but when you're trying to automate the
GitLab spawn and its configuration... you get a problem.

So, since there is absolutely no documentation on this usecase, I thought about
these 3 ways to solve it :

1. Reset the password through the API. Except it doesn't have any endpoint for
   this initial password, and we wouldn't be able to authenticate to the API
   anyway
2. Just POST the answer as if we did it from a browser. Except GitLab is based
   on rails, which as built-in `authenticity_token` handling to avoid CSRF; so
   we would have to GET the page first, then parse it, the POST the answer...
   no way.
3. Play with the assets/wrapper that is used as entrypoint/CMD of the docker
   image

After investigating on this 3rd point, I finaly realized that it's possible to
set the root password at installation through environment, which seems to be
documented **nowhere**.

See [001_admin.rb from gitlab-ce
source](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/db/fixtures/production/001_admin.rb)
for the code :

    if ENV['GITLAB_ROOT_PASSWORD'].blank?
      user_args[:password_automatically_set] = true
      user_args[:force_random_password] = true
    else
      user_args[:password] = ENV['GITLAB_ROOT_PASSWORD']
    end

# GitLab CI runner token

need a token, how to register ? Again, badly documented.
Need to discover runners. End up hitting the API

Heureusement, le gitlab runner est en go et sait parser sa conf depuis l'env...
juste à automatiser le register à la création :)

# Pass files to docker inside runners

The volume is from the host ! BUild dir, etc

# Undocumented meta refresh_inventory

# Ansible's gitlab_user module is bugged :(
