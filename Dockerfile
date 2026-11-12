# syntax=docker/dockerfile:1
ARG FROM=ubuntu:22.04
FROM ${FROM}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata apt-utils && \
    # Compilers
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    gcc make pkg-config \
    debhelper dpkg-dev lsb-release xz-utils quilt git \
    liblmdb-dev

ARG SRC_DIR=/src
ARG BUILD_USER=build
RUN useradd -m -d ${SRC_DIR} ${BUILD_USER}

ARG SRC_DIR=/src
WORKDIR ${SRC_DIR}
ARG PKG_VERSION
RUN git clone --depth 1 --branch ${PKG_VERSION} https://github.com/hnakamur/ngx-ats-lmdb
RUN tar cf - ngx-ats-lmdb | xz -c > ngx-ats-lmdb_${PKG_VERSION}.orig.tar.xz

COPY --chown=${BUILD_USER}:${BUILD_USER} ./debian /src/ngx-ats-lmdb/debian/
WORKDIR ${SRC_DIR}/ngx-ats-lmdb
ARG PKG_REL_DISTRIB
RUN sed -i "s/DebRelDistrib/${PKG_REL_DISTRIB}/;s/UNRELEASED/$(lsb_release -cs)/" /src/ngx-ats-lmdb/debian/changelog
RUN dpkg-buildpackage -us -uc

USER root
