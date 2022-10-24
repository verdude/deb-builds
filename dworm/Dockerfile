from ubuntu:jammy as prep
RUN set -eux; \
  apt-get update; \
  apt-get install -y gosu; \
  gosu nobody true
COPY buildentry.sh /usr/local/bin/entrypoint.sh
RUN chmod 555 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM prep AS base
WORKDIR /
RUN apt-get update && apt-get install -y erlang make git
COPY pkgbuild.sh pkgbuild.sh
COPY control control
COPY PKGBUILD PKGBUILD
CMD ["/pkgbuild.sh"]

FROM base as build
RUN /pkgbuild.sh -o /opt
