#**This README is a 'plain' version, you will find the real documentation in a readable format on https://clickcount.horgix.fr**


# Introduction

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
[Docker image](https://hub.docker.com/r/horgix/ansible-aws-gitlab/) packaging
them right there for you so just make sure you have the docker daemon running**

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

# How To

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

# Demo

If you want to see the result running, it's possible, but will probably not be
here forever since it's running on AWS with my own money.

# Services

- [Marathon](http://deploy.coffee:8080); credentials: xebia/verysecure
- [GitLab](https://gitlab.deploy.coffee); credentials: xebia/verysecure
- [Traefik](https://traefik.deploy.coffee)
- [Mesos UI](https://cluster.deploy.coffee)
- [This documentation](https://clickcount.horgix.fr)

# Example run

```none
$ time make

ansible-playbook playbooks/deploy.yml -t deploy
statically included: /home/horgix/work/xebia/ansible/roles/deploy/tasks/secgroup.yml
statically included: /home/horgix/work/xebia/ansible/roles/deploy/tasks/ec2.yml

PLAY [Base setup] **************************************************************

TASK [deploy : EC2 - Create security group] ************************************
changed: [localhost]

TASK [deploy : EC2 - Create instances] *****************************************
changed: [localhost] => (item={u'type': u'm4.large', u'tags': {u'zkid': 1, u'type': u'svc', u'Name': u'services'}})
changed: [localhost] => (item={u'type': u't2.micro', u'tags': {u'zkid': 2, u'type': u'staging', u'Name': u'staging'}})
changed: [localhost] => (item={u'type': u't2.micro', u'tags': {u'zkid': 3, u'type': u'prod', u'Name': u'production'}})

TASK [deploy : Wait for SSH to come up] ****************************************
ok: [localhost] => (item={'_ansible_parsed': True, u'changed': True, '_ansible_no_log': False, u'instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-4-225.eu-west-1.compute.internal', u'public_ip': u'52.209.138.214', u'private_ip': u'172.31.4.225', u'id': u'i-5446a165', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-e439d466'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-209-138-214.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'1', u'type': u'svc', u'Name': u'services'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-209-138-214.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:57:36.000Z', u'instance_type': u'm4.large', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], '_ansible_item_result': True, u'instance_ids': [u'i-5446a165'], 'item': {u'type': u'm4.large', u'tags': {u'zkid': 1, u'type': u'svc', u'Name': u'services'}}, u'tagged_instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-4-225.eu-west-1.compute.internal', u'public_ip': u'52.209.138.214', u'private_ip': u'172.31.4.225', u'id': u'i-5446a165', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-e439d466'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-209-138-214.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'1', u'type': u'svc', u'Name': u'services'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-209-138-214.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:57:36.000Z', u'instance_type': u'm4.large', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], 'invocation': {'module_name': u'ec2', u'module_args': {u'kernel': None, u'image': u'ami-f9dd458a', u'monitoring': False, u'user_data': None, u'termination_protection': False, u'private_ip': None, u'spot_type': u'one-time', u'ec2_url': None, u'id': None, u'source_dest_check': True, u'aws_secret_key': None, u'spot_wait_timeout': u'600', u'spot_price': None, u'zone': None, u'exact_count': 1, u'ebs_optimized': False, u'state': u'present', u'placement_group': None, u'count_tag': u"{'type': 'svc'}", u'ramdisk': None, u'key_name': u'aws', u'spot_launch_group': None, u'vpc_subnet_id': u'subnet-3adebc5e', u'instance_ids': None, u'tenancy': u'default', u'profile': None, u'assign_public_ip': True, u'group': [u'Click-Count'], u'wait': True, u'count': 1, u'aws_access_key': None, u'security_token': None, u'instance_profile_name': None, u'region': u'eu-west-1', u'network_interfaces': None, u'instance_initiated_shutdown_behavior': u'stop', u'instance_type': u'm4.large', u'wait_timeout': u'300', u'volumes': [{u'volume_size': 20, u'volume_type': u'gp2', u'device_name': u'/dev/xvda'}], u'instance_tags': {u'zkid': 1, u'type': u'svc', u'Name': u'services'}, u'group_id': None, u'validate_certs': True}}})
ok: [localhost] => (item={'_ansible_parsed': True, u'changed': True, '_ansible_no_log': False, u'instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-5-225.eu-west-1.compute.internal', u'public_ip': u'52.210.28.188', u'private_ip': u'172.31.5.225', u'id': u'i-5e45a26f', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-1e39d49c'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-210-28-188.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'2', u'type': u'staging', u'Name': u'staging'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-210-28-188.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:57:57.000Z', u'instance_type': u't2.micro', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], '_ansible_item_result': True, u'instance_ids': [u'i-5e45a26f'], 'item': {u'type': u't2.micro', u'tags': {u'zkid': 2, u'type': u'staging', u'Name': u'staging'}}, u'tagged_instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-5-225.eu-west-1.compute.internal', u'public_ip': u'52.210.28.188', u'private_ip': u'172.31.5.225', u'id': u'i-5e45a26f', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-1e39d49c'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-210-28-188.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'2', u'type': u'staging', u'Name': u'staging'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-210-28-188.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:57:57.000Z', u'instance_type': u't2.micro', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], 'invocation': {'module_name': u'ec2', u'module_args': {u'kernel': None, u'image': u'ami-f9dd458a', u'monitoring': False, u'user_data': None, u'termination_protection': False, u'private_ip': None, u'spot_type': u'one-time', u'ec2_url': None, u'id': None, u'source_dest_check': True, u'aws_secret_key': None, u'spot_wait_timeout': u'600', u'spot_price': None, u'zone': None, u'exact_count': 1, u'ebs_optimized': False, u'state': u'present', u'placement_group': None, u'count_tag': u"{'type': 'staging'}", u'ramdisk': None, u'key_name': u'aws', u'spot_launch_group': None, u'vpc_subnet_id': u'subnet-3adebc5e', u'instance_ids': None, u'tenancy': u'default', u'profile': None, u'assign_public_ip': True, u'group': [u'Click-Count'], u'wait': True, u'count': 1, u'aws_access_key': None, u'security_token': None, u'instance_profile_name': None, u'region': u'eu-west-1', u'network_interfaces': None, u'instance_initiated_shutdown_behavior': u'stop', u'instance_type': u't2.micro', u'wait_timeout': u'300', u'volumes': [{u'volume_size': 20, u'volume_type': u'gp2', u'device_name': u'/dev/xvda'}], u'instance_tags': {u'zkid': 2, u'type': u'staging', u'Name': u'staging'}, u'group_id': None, u'validate_certs': True}}})
ok: [localhost] => (item={'_ansible_parsed': True, u'changed': True, '_ansible_no_log': False, u'instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-4-36.eu-west-1.compute.internal', u'public_ip': u'52.210.134.157', u'private_ip': u'172.31.4.36', u'id': u'i-1d44a32c', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-e839d46a'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-210-134-157.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'3', u'type': u'prod', u'Name': u'production'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-210-134-157.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:58:19.000Z', u'instance_type': u't2.micro', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], '_ansible_item_result': True, u'instance_ids': [u'i-1d44a32c'], 'item': {u'type': u't2.micro', u'tags': {u'zkid': 3, u'type': u'prod', u'Name': u'production'}}, u'tagged_instances': [{u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-4-36.eu-west-1.compute.internal', u'public_ip': u'52.210.134.157', u'private_ip': u'172.31.4.36', u'id': u'i-1d44a32c', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'architecture': u'x86_64', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': False, u'volume_id': u'vol-e839d46a'}}, u'key_name': u'aws', u'image_id': u'ami-f9dd458a', u'tenancy': u'default', u'groups': {u'sg-5b717d3c': u'Click-Count'}, u'public_dns_name': u'ec2-52-210-134-157.eu-west-1.compute.amazonaws.com', u'state_code': 16, u'tags': {u'zkid': u'3', u'type': u'prod', u'Name': u'production'}, u'placement': u'eu-west-1a', u'ami_launch_index': u'0', u'dns_name': u'ec2-52-210-134-157.eu-west-1.compute.amazonaws.com', u'region': u'eu-west-1', u'launch_time': u'2016-09-06T19:58:19.000Z', u'instance_type': u't2.micro', u'root_device_name': u'/dev/xvda', u'hypervisor': u'xen'}], 'invocation': {'module_name': u'ec2', u'module_args': {u'kernel': None, u'image': u'ami-f9dd458a', u'monitoring': False, u'user_data': None, u'termination_protection': False, u'private_ip': None, u'spot_type': u'one-time', u'ec2_url': None, u'id': None, u'source_dest_check': True, u'aws_secret_key': None, u'spot_wait_timeout': u'600', u'spot_price': None, u'zone': None, u'exact_count': 1, u'ebs_optimized': False, u'state': u'present', u'placement_group': None, u'count_tag': u"{'type': 'prod'}", u'ramdisk': None, u'key_name': u'aws', u'spot_launch_group': None, u'vpc_subnet_id': u'subnet-3adebc5e', u'instance_ids': None, u'tenancy': u'default', u'profile': None, u'assign_public_ip': True, u'group': [u'Click-Count'], u'wait': True, u'count': 1, u'aws_access_key': None, u'security_token': None, u'instance_profile_name': None, u'region': u'eu-west-1', u'network_interfaces': None, u'instance_initiated_shutdown_behavior': u'stop', u'instance_type': u't2.micro', u'wait_timeout': u'300', u'volumes': [{u'volume_size': 20, u'volume_type': u'gp2', u'device_name': u'/dev/xvda'}], u'instance_tags': {u'zkid': 3, u'type': u'prod', u'Name': u'production'}, u'group_id': None, u'validate_certs': True}}})

PLAY [Route 53] ****************************************************************

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0

./inventory/ec2.py --refresh-cache > /dev/null
ansible-playbook playbooks/deploy.yml -t route53
statically included: /home/horgix/work/xebia/ansible/roles/deploy/tasks/secgroup.yml
statically included: /home/horgix/work/xebia/ansible/roles/deploy/tasks/ec2.yml

PLAY [Base setup] **************************************************************

PLAY [Route 53] ****************************************************************

TASK [route53 : Add Route 53 host records] *************************************
changed: [production -> 127.0.0.1]
changed: [services -> 127.0.0.1]
changed: [staging -> 127.0.0.1]

TASK [route53 : Add Route 53 main record] **************************************
skipping: [production]
skipping: [staging]
changed: [services -> 127.0.0.1]

TASK [route53 : Add Route 53 services records] *********************************
skipping: [production]
skipping: [staging]
ok: [services -> 127.0.0.1]

PLAY RECAP *********************************************************************
production                 : ok=1    changed=1    unreachable=0    failed=0
services                   : ok=3    changed=2    unreachable=0    failed=0
staging                    : ok=1    changed=1    unreachable=0    failed=0

ansible-playbook playbooks/master.yml -b -t base
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/requirements.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/zookeeper.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/mesos.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/marathon.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/mesos-ui.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/traefik.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab-content.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab-runner.yml

PLAY [Base setup] **************************************************************

TASK [setup] *******************************************************************
ok: [staging]
ok: [production]
ok: [services]

TASK [base : Set Zookeeper Nodes fact] *****************************************
ok: [staging]
ok: [production]
ok: [services]

TASK [base : Zookeeper nodes] **************************************************
ok: [production] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}
ok: [staging] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}
ok: [services] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}

TASK [base : Upgrade every package] ********************************************
changed: [staging]
changed: [services]
changed: [production]

TASK [base : Docker - Install package] *****************************************
changed: [services]
changed: [staging]
changed: [production]

TASK [base : Docker - Install python lib] **************************************
changed: [staging]
changed: [production]
changed: [services]

TASK [base : Docker - start and enable service] ********************************
changed: [staging]
changed: [production]
changed: [services]

TASK [base : Docker - Pull base images] ****************************************
changed: [services] => (item=horgix/zookeeper)
changed: [staging] => (item=horgix/zookeeper)
changed: [production] => (item=horgix/zookeeper)
changed: [services] => (item=horgix/mesos-slave)
changed: [production] => (item=horgix/mesos-slave)
changed: [staging] => (item=horgix/mesos-slave)
changed: [services] => (item=mesoscloud/mesos-master)
changed: [production] => (item=mesoscloud/mesos-master)
changed: [staging] => (item=mesoscloud/mesos-master)
changed: [services] => (item=mesoscloud/marathon)
changed: [production] => (item=mesoscloud/marathon)
changed: [staging] => (item=mesoscloud/marathon)

TASK [base : Zookeeper - Start] ************************************************
changed: [services]
changed: [production]
changed: [staging]

TASK [base : Mesos - Start slave] **********************************************
changed: [production]
changed: [services]
changed: [staging]

TASK [base : Mesos - Start master] *********************************************
changed: [staging]
changed: [services]
changed: [production]

TASK [base : Marathon - Start] *************************************************
changed: [staging]
changed: [services]
changed: [production]

PLAY [Setup Services] **********************************************************

TASK [setup] *******************************************************************
ok: [services]

PLAY RECAP *********************************************************************
production                 : ok=12   changed=9    unreachable=0    failed=0
services                   : ok=13   changed=9    unreachable=0    failed=0
staging                    : ok=12   changed=9    unreachable=0    failed=0

ansible-playbook playbooks/master.yml -b -t services
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/requirements.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/zookeeper.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/mesos.yml
statically included: /home/horgix/work/xebia/ansible/roles/base/tasks/marathon.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/mesos-ui.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/traefik.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab-content.yml
statically included: /home/horgix/work/xebia/ansible/roles/services/tasks/gitlab-runner.yml

PLAY [Base setup] **************************************************************

TASK [setup] *******************************************************************
ok: [staging]
ok: [production]
ok: [services]

TASK [base : Set Zookeeper Nodes fact] *****************************************
ok: [production]
ok: [services]
ok: [staging]

TASK [base : Zookeeper nodes] **************************************************
ok: [production] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}
ok: [services] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}
ok: [staging] => {
    "msg": "3:172.31.4.36,2:172.31.5.225,1:172.31.4.225"
}

PLAY [Setup Services] **********************************************************

TASK [setup] *******************************************************************
ok: [services]

TASK [services : Docker - Pull service images] *********************************
changed: [services] => (item=gitlab/gitlab-ce)
changed: [services] => (item=horgix/gitlab-runner)
changed: [services] => (item=traefik)
changed: [services] => (item=jetty)
changed: [services] => (item=maven)

TASK [services : MesosUI - Generate Marathon JSON description] *****************
changed: [services -> localhost]

TASK [services : MesosUI - Run Marathon app] ***********************************
ok: [services]

TASK [services : Create volumes directories] ***********************************
changed: [services]

TASK [services : Make sure acme.json exists] ***********************************
ok: [services]

TASK [services : Configure] ****************************************************
changed: [services]

TASK [services : Generate Marathon JSON description] ***************************
changed: [services -> localhost]

TASK [services : Run Marathon app] *********************************************
ok: [services]

TASK [services : Create volumes directories] ***********************************
changed: [services] => (item=/srv/gitlab)
changed: [services] => (item=/srv/gitlab/config)
changed: [services] => (item=/srv/gitlab/logs)
changed: [services] => (item=/srv/gitlab/data)
changed: [services] => (item=/srv/gitlab/logs/reconfigure)

TASK [services : Generate Marathon JSON description] ***************************
changed: [services -> localhost]

TASK [services : Run Marathon app] *********************************************
ok: [services]

TASK [services : Wait for GitLab to come up] ***********************************
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (20 retries left).
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (19 retries left).
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (18 retries left).
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (17 retries left).
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (16 retries left).
FAILED - RETRYING: TASK: services : Wait for GitLab to come up (15 retries left).
ok: [services]
 [WARNING]: Consider using get_url or uri module rather than running curl


TASK [services : Get GitLab private token] *************************************
ok: [services]

TASK [services : Set GitLab private token as fact] *****************************
ok: [services]

TASK [services : Create Gitlab Group] ******************************************
changed: [services -> 127.0.0.1]

TASK [services : Create Gitlab User] *******************************************
changed: [services -> 127.0.0.1]

TASK [services : Create Gitlab Project] ****************************************
changed: [services -> 127.0.0.1]

TASK [services : Set variables] ************************************************
ok: [services] => (item=key=HUB_LOGIN&value=<stripped>)
ok: [services] => (item=key=HUB_PASSWORD&value=<stripped>)
ok: [services] => (item=key=MARATHON_URL&value=http://xebia.horgix.fr:8080)
ok: [services] => (item=key=MARATHON_USERNAME&value=<stripped>)
ok: [services] => (item=key=MARATHON_PASSWORD&value=<stripped>)
ok: [services] => (item=key=STAGING_ENDPOINT&value=staging.xebia.horgix.fr)
ok: [services] => (item=key=PRODUCTION_ENDPOINT&value=prod.xebia.horgix.fr)
ok: [services] => (item=key=STAGING_REDIS&value=<stripped>)
ok: [services] => (item=key=PRODUCTION_REDIS&value=<stripped>)

TASK [services : GitLab Runner - Get runners token] ****************************
ok: [services]

TASK [services : GitLab Runner - Set runners token as fact] ********************
ok: [services]

TASK [services : GitLab Runner - Generate Marathon JSON description] ***********
changed: [services -> localhost]

TASK [services : Runner - Run Marathon app] ************************************
ok: [services]

PLAY RECAP *********************************************************************
production                 : ok=3    changed=0    unreachable=0    failed=0
services                   : ok=26   changed=11   unreachable=0    failed=0
staging                    : ok=3    changed=0    unreachable=0    failed=0

make  51.26s user 8.01s system 8% cpu 12:03.27 total
```

# Screenshots

## Mesos Dashboard

![Mesos Dashboard](images/mesos_dashboard.png)

## Mesos Nodes

![Mesos Nodes](images/mesos_nodes.png)

## Mesos Tasks

![Mesos Tasks](images/mesos_tasks.png)

## Marathon

![Marathon](images/marathon.png)

## Traefik

![Traefik](Images/traefik.png)

# Improvements ideas

**Since this project as been made from scratch in a week, there is a room for a
lot of improvements. This is a list of some ideas that could be implemented
with a bit more time and depending on the needs.**

## Zookeeper IDs

Currently, Zookeeper IDs are taken from the tag `zkid` on the instances, which
will be kind of a pain to handle if we introduce autoscaling of the
infrastructure. It would be better if each Zookeeper could discover its ID.

## Gitlab Container Registry

Since the [8.8
release](https://about.gitlab.com/2016/05/23/gitlab-container-registry/),
GitLab can provide a Docker private registry. It would be really nice to use
it; however, it has not been integrated in this project/demo, as it requires
passing SSL certificates to it, which are currently only known to Traefik.

## GitLab Runner health checks

Currently, there is no health checks on Marathon side for GitLab runners.
Since they don't listen for connections and directly connect to GitLab, there
is no easy way to check for its aliveness; something based on the health check
type "command" which would hit GitLab API to detect if the runners is
referenced as active or not would be possible, but currently not implemented.

## Docker images based on Alpine

Currently, this project is using the most possible "standard" images, mainly
just using the "latest" tag. Reducing the global size of containers using ones
based on Alpine would be nice, but would maybe have to be benchmarked before.

## Rolling upgrade without service interruption

Currently, if we try to run the app with less than 300MB of memory, it simply
ends up being killed by the oom killer:

    $ docker run -it --rm -m 200m horgix/click-count
    $ dmesg
    [ 5662.970129] Memory cgroup out of memory: Kill process 13119 (java) score 986 or sacrifice child
    [ 5662.970139] Killed process 13119 (java) total-vm:3725396kB, anon-rss:201312kB, file-rss:0kB, shmem-rss:0kB

Furthermore, the t2.micro EC2 are given "0.5GB" of memory, actually reported as
"497" by Mesos.

So, at the end, it's impossible to have 2 instances of the click-count
application running side by side on the same t2.micro instance.

So we have 2 solutions to allow Marathon to update the application:

1. Set the `minimumHealthCapacity` to 0, allowing Marathon to completely
   shutdown the "old" application before starting the new one
2. Set the `mem` resource limitation to 0, asking Mesos to not limit the memory
   used by the running container, which will allow it to make offers to
   Marathon so it could do a proper rolling upgrade

The first solution has been chosen, since the second one would introduce the
risk of anyway having one or both instances of the application killed by the
oom killer. The best case, of course, would be to run on something better than
t2.micro instances, or having more of them.

## GitLab Runners autoscaling and deregistering

Currently not implemented but would be nice to have.

## Contribute a Marathon Ansible module

The lack of an Ansible module dedicated to running Marathon applications forces
to use the `uri` module. It would be better and cleaner to have a dedicated
module for Ansible, which could probably be created easily.

## Tailor needed AWS key policies

Currently, the required policies listed for the AWS user are the following :

- AdministratorAccess
- AmazonEC2FullAccess
- AmazonRoute53FullAccess

It could probably be restricted a bit more.

## Improve security groups

Currently, the security groups are probably the worst part of this project.
The one created by Ansible allow everything, both inbound and outbound.

I had a first try with the following opened ports, but still had issues with
Zookeeper so I postponed that to focus on the rest of this project.

- 80 / 443 : HTTP(S)
- 2888 / 3888 / 2181 : Zookeeper
- 8080 : Marathon
- 31000 - 32000 : Mesos Docker containers
- 5050 : Mesos
- 22 : SSH
- ICMP

## Discover host keys

Currently, the host key checking is disabled in Ansible's configuration to
allow running on newly spawned instances without having to confirm anything. It
would be better to discover these keys.

## Work without Route 53

To allow people to test this infrastructure more easily, it would be nice if it
didn't depend on some of the records like `gitlab.<domain>`.

## Tests...

A real test step in the CI Pipeline would be a must have in a real usecase,
since until know I focused on the delivery part.

# Fun parts

This project was really fun, and I thought I would detail some of the
surprising and interesting points I encountered during this week.

# Zookeeper SERVERS

While trying to use the [mesoscloud/zookeeper Docker
image](https://hub.docker.com/r/mesoscloud/zookeeper/), I originally used
hardcoded IP to configure Zookeeper with the list of its nodes.

The zookeeper image can indeed be configured at runtime with the "SERVERS"
environment variable, under the following form:

    SERVERS=first_node_ip,second_node_ip,third_node_ip

Obviously, since this approach is absolutely neither flexible nor scalable, I
then decided to use the dynamic inventory from EC2 to populate this list of
servers, which looks like that in Jinja:

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

It just fills a file with the Zookeeper ID, everything looks good here. Then, a
few lines later:

    printf '%s' "$SERVERS" | awk 'BEGIN { RS = "," }; { printf "server.%i=%s:2888:3888\n", NR, $0 }' >> /opt/zookeeper/conf/zoo.cfg

The important part here is the `server.%i`, which increments at each node in
the list.

So, this environment variable:

    SERVERS=first_node_ip,second_node_ip,third_node_ip

is transformed into this configuration :

    server.1=first_node_ip
    server.2=second_node_ip
    server.3=third_node_ip

And the `X` in `server.X` is assumed to be the node ID. But since their ID is
set by the `zkid` tag, when using a dynamic inventory it probably won't build
the list in the increasing order of your ID !

So at the end I just ended up tweaking the entrypoint to give couples of ID/IP
as SERVERS.

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

I think I might submit a PR on the documentation to add this point.

# GitLab CI runner token

GitLab CI Runners need a token to register themselves on GitLab. However, there
is absolutely no way to discover this token, so I ended up doing it through the
GitLab API and then feeding it by environment variables to the GitLab Runner
Docker image.

The Docker image is also not made for autoregistering so I quickly [implemented
it](https://github.com/Horgix/dockerfiles/tree/master/gitlab-runner) and will
probably suggest it as an improvement to the official gitlab-runner image.
