# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Rest Data Services
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) ords.3.0.10.165.06.53.zip
#     Download Oracle Rest Data Services from
#     http://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put the downloaded file in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/restdataservices:3.0.10 . 
#
# Pull base image
# ---------------

ARG BASE_IMAGE=container-registry.oracle.com/java/openjdk:latest
FROM ${BASE_IMAGE}

# Labels
# ----------
#LABEL maintainer "gerald.venzl@oracle.com"
LABEL maintainer="sascha@methusalem.net"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORDS_HOME=/opt/oracle/ords \
    ORACLE_HOME=/home/oracle \
    ORDS_CONFIG_DIR=/home/oracle/config \
    INSTALL_FILE=ords*.zip \
    INSTALL_APEX=apex*.zip \
    RUN_FILE="runOrds.sh"

# Copy binaries
# -------------
COPY ${INSTALL_FILE} ${INSTALL_APEX} ${RUN_FILE} ${ORACLE_HOME}/

# ARG for installing APEX prerequisites
ARG INCLUDE_APEX=true

# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with ORDS installation
# ------------------------------------------------------------
RUN groupadd -g 54322 dba && \
    useradd -u 54321 -d ${ORACLE_HOME} -g dba -m -s /bin/bash oracle  && \
    if [ ! -e ${ORACLE_HOME}/${INSTALL_FILE} ]; then \
      curl https://download.oracle.com/otn_software/java/ords/ords-latest.zip -o ${ORACLE_HOME}/ords-latest.zip; \
    fi && \
    mkdir -p  ${ORDS_HOME} ${ORACLE_HOME}/config && \
    if [ ${INCLUDE_APEX} == "true" ]; then \
        dnf -y install oracle-instantclient-release-el8 && \
        dnf -y install oracle-instantclient-sqlplus.x86_64 && \
        if [ ! -e ${ORACLE_HOME}/${INSTALL_APEX} ]; then \
          curl https://download.oracle.com/otn_software/apex/apex-latest.zip -o ${ORACLE_HOME}/apex-latest.zip; \
        fi && \
        cd ${ORACLE_HOME} && \
        jar -xvf apex-latest.zip && \
        rm apex-latest.zip; \
    fi && \
    cd ${ORDS_HOME} && \
    jar -xf ${ORACLE_HOME}/${INSTALL_FILE} && \
    rm ${ORACLE_HOME}/${INSTALL_FILE} && \
    chown -R oracle:dba ${ORDS_HOME} ${ORACLE_HOME}&& \
    chmod ug+x $ORDS_HOME/bin/ords && \
    dnf install -y tar && \
    rm -rf /var/cache/dnf && \
    rm -rf /var/tmp/*
#    
# Finalize setup
# -------------------
USER oracle
WORKDIR ${ORACLE_HOME}

VOLUME ["${ORDS_CONFIG_DIR}"]
VOLUME ["${ORACLE_HOME}/apex"]
EXPOSE 8443

# Define default command to start Oracle Database.
CMD ${ORACLE_HOME}/${RUN_FILE}

