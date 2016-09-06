make:: deploy base services

deploy::
	ansible-playbook playbooks/deploy.yml -t deploy
	./inventory/ec2.py --refresh-cache > /dev/null
	ansible-playbook playbooks/deploy.yml -t route53

base::
	ansible-playbook playbooks/master.yml -b -t base

services::
	ansible-playbook playbooks/master.yml -b -t services
