FROM base/archlinux

RUN pacman --noconfirm -Sy archlinux-keyring \
      && pacman --noconfirm -Syu \
      && pacman-db-upgrade

RUN pacman -S --noconfirm ca-certificates-mozilla
RUN pacman -S --noconfirm python2-pip openssh sudo make binutils \
      && pip2 install pyapi-gitlab boto \
      && pacman -Sc --noconfirm

RUN useradd build \
  && echo 'build ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && cd /tmp \
  && sudo -u build curl https://aur.archlinux.org/cgit/aur.git/snapshot/ansible-git.tar.gz -o ansible-git.tar.gz \
  && sudo -u build tar xf ansible-git.tar.gz \
  && cd ansible-git \
  && sudo -u build makepkg -sri --noconfirm

RUN ln -s /usr/bin/python2 /usr/bin/python

CMD ansible
