# GForth 0.7.9 for VitaSound toolchain (fmix, flint, fcov, fmcp).
# Publish: ghcr.io/vitasound/gforth:0.7.9
#
# Multi-stage: build from the GNU tarball (same recipe as
# .github/scripts/build-gforth-0.7.9.sh), then copy the prefix into a
# slim runtime image.

ARG UBUNTU_VERSION=22.04
ARG GFORTH_PREFIX=/opt/gforth-0.7.9

FROM ubuntu:${UBUNTU_VERSION} AS build
ARG GFORTH_PREFIX

ENV DEBIAN_FRONTEND=noninteractive
ENV GFORTH_PREFIX=${GFORTH_PREFIX}
ENV GNU_TARBALL=https://ftp.gnu.org/gnu/gforth/gforth-0.7.9.tar.gz
ENV GIT_TARBALL=https://github.com/forthy42/gforth/archive/refs/tags/0.7.9_20250101.tar.gz

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential wget ca-certificates \
      autoconf automake libtool-bin libltdl-dev libffi-dev flex bison zlib1g-dev \
      gforth texinfo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/src
COPY build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && /tmp/build.sh

FROM ubuntu:${UBUNTU_VERSION}
ARG GFORTH_PREFIX

ENV DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.title="gforth" \
      org.opencontainers.image.description="GForth 0.7.9 for VitaSound Forth tooling" \
      org.opencontainers.image.source="https://github.com/VitaSound/fmix" \
      org.opencontainers.image.version="0.7.9"

RUN apt-get update && apt-get install -y --no-install-recommends \
      libffi8 libltdl7 zlib1g ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build ${GFORTH_PREFIX} ${GFORTH_PREFIX}

ENV PATH="${GFORTH_PREFIX}/bin:${PATH}"

WORKDIR /work
ENTRYPOINT ["gforth"]
CMD ["--version"]
