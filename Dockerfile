FROM base/archlinux:latest as builder
MAINTAINER Samuel Bernard "samuel.bernard@gmail.com"

# Let's run stuff
RUN \
  # First, update everything (start by keyring and pacman)
  pacman -Sy && \
  pacman -S archlinux-keyring --noconfirm && \
  pacman -S pacman --noconfirm && \
  pacman-db-upgrade && \
  pacman -Su --noconfirm && \
  # Install what is needed to build xmr-stak
  pacman -S base-devel --noconfirm && \
  # Install useful tools
  pacman -S vim tree iproute2 inetutils --noconfirm && \
  # Generate locale en_US
  locale-gen en_US.UTF-8

RUN \
  # Install archlinux repo to get yaourt
  echo -e "[archlinuxfr]\n"\
    "SigLevel = Never\n"\
    "Server = http://repo.archlinux.fr/\$arch\n" |\
    sed 's/^ *//g' >> /etc/pacman.conf && \
  # Install yaourt
  pacman -Sy yaourt --noconfirm && \
  # Create an user
  useradd -m -G wheel -s /bin/bash user && \
  # Install sudo and configure it
  pacman -S sudo --noconfirm && \
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER user
WORKDIR /home/user
RUN yaourt -Sy hwloc cmake --noconfirm && yaourt -G xmr-stak_cpu && \
  OLD=e064478a559a2153703e0889032c343c1c108e939d36c5d687474b92fb4d8ddd \
  NEW=8be57a0b9712d854859dc846efdae532c073b8d1767d969ef92ae81d519ddc12; \
  sed -i -e "s/$OLD/$NEW/g" xmr-stak_cpu/PKGBUILD && \
    cat xmr-stak_cpu/PKGBUILD
WORKDIR /home/user/xmr-stak_cpu
RUN makepkg

FROM base/archlinux:latest
RUN useradd -m -s /bin/bash xmr
COPY --from=builder \
  /home/user/xmr-stak_cpu/xmr-stak_cpu-*-x86_64.pkg.tar.xz /tmp/.
RUN pacman -Sy hwloc --noconfirm && \
  pacman -U /tmp/xmr-stak_cpu-*-x86_64.pkg.tar.xz --noconfirm && \
  pacman -Scc --noconfirm
WORKDIR /home/xmr
USER xmr
CMD ["/usr/bin/xmr-stak"]
