# Configuration

## From docker or host ?

## Ansible python interpreter

If you're not on Archlinux, you might want to comment lines 7-8 and 22-23 in
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
`init_credentials.sh` can also be used to load them from [`pass`](TODO) (if you
don't know what it is, I invite you to try it, it's a really simple way to
store passwords, based on GPG, git, and tree).

### AWS

#### Why is it needed ?

- Create EC2 instances and Route 53 DNS records
- Execute the dynamic inventory

#### What to define

2 environment variable are required :

- AWS\_ACCESS\_KEY\_ID
- AWS\_SECRET\_ACCESS\_KEY

You can also export them by running `init_credentials.sh` if they are stored in
pass under `xebia/aws/ansible-key-id` and `xebia/aws/ansible-key-secret`

### Docker Hub

#### Why is it needed ?

The GitLab CI `build` step builds a Docker image locally and then push it to
the [Docker Hub](TODO) using `docker login` then BLABLA

# Run

- `make deploy` will create the EC2 instances and Route 53 DNS records
- `make base` will install the base cluster on these instances
- `make services` will deploy services, includind GitLab and its Runner which
  power the CI for the Click-Count application

You can also simply call `make` to deploy the entire stack.
