FROM base/archlinux

RUN pacman --noconfirm -Sy archlinux-keyring \
      && pacman --noconfirm -Syu \
      && pacman-db-upgrade

RUN pacman -S --noconfirm ca-certificates-mozilla
RUN pacman -S --noconfirm ansible python2-pip openssh \
      && pip2 install pyapi-gitlab boto \
      && pacman -Sc

CMD ansible
