DOCKERCMD	= docker run -it --rm -v `pwd`:/root/ansible -w /root/ansible -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e DOCKER_HUB_USERNAME=${DOCKER_HUB_USERNAME} -e DOCKER_HUB_PASSWORD=${DOCKER_HUB_PASSWORD} -v ${HOME}/.ssh/ansible-click-count.pem:/root/.ssh/ansible-click-count.pem horgix/ansible-aws-gitlab

make:: deploy base services

docker: docker_deploy docker_base docker_services

deploy::
	ansible-playbook playbooks/deploy.yml -t deploy
	ansible-playbook playbooks/deploy.yml -t route53
docker_deploy::
	${DOCKERCMD} ansible-playbook playbooks/deploy.yml -t deploy
	${DOCKERCMD} ansible-playbook playbooks/deploy.yml -t route53

base::
	ansible-playbook playbooks/master.yml -b -t base
docker_base::
	${DOCKERCMD} ansible-playbook playbooks/master.yml -b -t base

services::
	ansible-playbook playbooks/master.yml -b -t services
docker_services::
	ansible-playbook playbooks/master.yml -b -t services

.SILENT: gen_readme

# Better read the mkdocs on https://clickcount.horgix.fr, but here is a README,
# just in case
gen_readme:
	echo -e "#**This README is a 'plain' version, you will find the real documentation in a readable format on https://clickcount.horgix.fr**\n" > README.md
	echo -e '\n# Introduction\n' >> README.md
	cat doc/src/index.md >> README.md
	echo -e '\n# How To\n' >> README.md
	cat doc/src/howto.md >> README.md
	echo -e '\n# Demo\n' >> README.md
	cat doc/src/demo.md >> README.md
	echo -e '\n# Improvements ideas\n' >> README.md
	cat doc/src/improvements.md >> README.md
	echo -e '\n# Fun parts\n' >> README.md
	cat doc/src/fun.md >> README.md
