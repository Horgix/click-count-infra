FROM base/archlinux

RUN pacman --noconfirm -Sy archlinux-keyring \
      && pacman --noconfirm -Syu \
      && pacman-db-upgrade \
      && pacman -Sc

RUN pacman -S --noconfirm ca-certificates-mozilla
RUN pacman -S --noconfirm ansible python2-pip \
      && pip2 install pyapi-gitlab boto

RUN pacman -S --noconfirm openssh

CMD ansible
