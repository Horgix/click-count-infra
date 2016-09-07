make:: deploy base services

deploy::
	ansible-playbook playbooks/deploy.yml -t deploy
	./inventory/ec2.py --refresh-cache > /dev/null
	ansible-playbook playbooks/deploy.yml -t route53

base::
	ansible-playbook playbooks/master.yml -b -t base

services::
	ansible-playbook playbooks/master.yml -b -t services

.SILENT: gen_readme

# Better read the mkdocs, but better keep a README for Github
gen_readme:
	echo '# Introduction' > README.md
	cat doc/src/index.md >> README.md
	echo -e '\n# How To\n' >> README.md
	cat doc/src/howto.md >> README.md
	echo -e '\n# Demo\n' >> README.md
	cat doc/src/demo.md >> README.md
	echo -e '\n# Improvements ideas\n' >> README.md
	cat doc/src/improvements.md >> README.md
	echo -e '\n# Fun parts\n' >> README.md
	cat doc/src/fun.md >> README.md
