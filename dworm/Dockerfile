from ubuntu:jammy as prep
WORKDIR /
RUN apt-get update && apt-get install -y erlang make git
COPY pkgbuild.sh pkgbuild.sh
COPY control control
COPY PKGBUILD PKGBUILD
CMD ["/pkgbuild.sh"]

FROM prep as build
RUN /pkgbuild.sh -o /opt
