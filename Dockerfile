FROM debian:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

MAINTAINER Jeison Sosa <j.sosa@bristol.ac.uk>

COPY config.cfg /tmp/icc-config.cfg
COPY license.lic /tmp/icc-license.lic

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git cpio build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
  wget -O icc.tgz http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/16744/parallel_studio_xe_2020_update2_cluster_edition_online.tgz && \
  tar -xvzf icc.tgz && \
  cd /tmp/parallel_studio_xe_* && \
  bash ./install.sh --silent=/tmp/icc-config.cfg && \
  cd /tmp && \
  rm -rf parallel_studio_xe_* icc.tgz && \
  rm /tmp/icc-config.cfg

RUN echo "source /opt/intel//intel/compilers_and_libraries/linux/bin/compilervars.sh intel64 \&\& source /opt/intel/compilers_and_libraries/linux/mkl/bin/mklvars.sh intel64" >> ~/.bashrc

ENV CC=icc CXX=icpc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
