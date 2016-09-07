# 4 steps to rule them all

Ideally, you should be able to have the infrastructure to start building in
5min, and totally built after 20min (15min for Ansible to run everything)

- Make sure to have your AWS key in `~/.ssh/ansible-click-count.pem`
- `source ./init_credentials.sh` or export the environment variables by hand
- Tweak what you want in `inventory/groups_vars/all`, probably:
    - `domain_name`
    - `vpc_subnet_id`
    - `vpc_id`
- Run `make docker` ; the image pull will be long, and the Ansible run too, but
  you should be able to grab a coffee while it runs.

# Configuration

Before taking the time to configure anything, make sure you meet the
[requirements announced on the home page](index.md#requirements).

## Using docker

If you decided to use the "ansible-aws-gitlab" docker image which provides
everything, you should be ok with the above 4 steps instructions.

## Ansible python interpreter

If you decided to run Ansible from your machine, and if you're not on
Archlinux, you might want to comment lines 7-8 and 22-23 in
playbooks/deploy.yml:

  vars:
      ansible_python_interpreter: python2

these lines are here to be able to run Ansible tasks delegated to `localhost`
on an Archlinux host.

## Credentials

To be able to do its job, this project require a login/password for 2 things :

- AWS
- Docker Hub

You have to provide them as environment variable; the script
`init_credentials.sh` can also be used to load them from
[`pass`](https://git.zx2c4.com/password-store/) (if you don't know what it is,
I invite you to try it, it's a really simple way to store passwords, based on
GPG, git, and tree).

### AWS

#### Why is it needed ?

- Create EC2 instances and Route 53 DNS records
- Execute the dynamic inventory

#### What to define

2 environment variable are required :

- AWS\_ACCESS\_KEY\_ID
- AWS\_SECRET\_ACCESS\_KEY

You can also export them by running `init_credentials.sh` if they are stored in
pass under `xebia/aws/ansible-key-id` and `xebia/aws/ansible-key-secret`.

### Docker Hub

#### Why is it needed ?

The GitLab CI `build` step builds a Docker image locally and then pushes it to
the [Docker Hub](https://hub.docker.com/) using `docker login` then `docker
push`.

#### What to define

2 environment variable are required :

- DOCKER\_HUB\_USERNAME
- DOCKER\_HUB\_PASSWORD=`

You can also export them by running `init_credentials.sh` if they are stored in
pass under `dockerhub/username` and `dockerhub/password`.

# Run

- `make deploy` will create the EC2 instances and Route 53 DNS records
- `make base` will install the base cluster on these instances
- `make services` will deploy services, includind GitLab and its Runner which
  power the CI for the Click-Count application

You can also simply call `make` to deploy the entire stack.

Finaly, it's possible to prefix every make rule by `docker_` to make it run
inside the all-provisionned Docker container.
