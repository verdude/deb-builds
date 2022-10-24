from ubuntu:jammy
WORKDIR /
RUN apt-get update && apt-get install -y erlang make git
COPY pkgbuild.sh pkgbuild.sh
COPY control /control
CMD ["/pkgbuild.sh"]
