FROM adoptopenjdk:8-jdk-hotspot-bionic
LABEL maintainer="Atlassian Bamboo Team" \
      description="Official Bamboo Server Docker Image"

ENV BAMBOO_USER bamboo
ENV BAMBOO_GROUP bamboo

ENV BAMBOO_USER_HOME /home/${BAMBOO_USER}
ENV BAMBOO_SERVER_HOME /var/atlassian/application-data/bamboo
ENV BAMBOO_SERVER_INSTALL_DIR /opt/atlassian/bamboo

# Expose HTTP and AGENT JMS ports
ENV BAMBOO_JMS_CONNECTION_PORT=54663
EXPOSE 8085
EXPOSE $BAMBOO_JMS_CONNECTION_PORT

RUN set -x && \
     addgroup ${BAMBOO_GROUP} && \
     adduser ${BAMBOO_USER} --gecos "" --home ${BAMBOO_USER_HOME} --ingroup ${BAMBOO_GROUP} --disabled-password &&

RUN set -x && \
     apt-get update && \
     apt-get install -y --no-install-recommends \
          curl \
          git \
          bash \
          procps \
          openssl \
          maven \
     && \
# create symlink to maven to automate capability detection
     ln -s /usr/share/maven /usr/share/maven3 && \
     rm -rf /var/lib/apt/lists/*

ARG BAMBOO_VERSION=6.9.2
ARG DOWNLOAD_URL=https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz

RUN set -x && \
     mkdir -p ${BAMBOO_SERVER_INSTALL_DIR} && \
     mkdir -p ${BAMBOO_SERVER_HOME} && \
     curl -L --silent ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$BAMBOO_SERVER_INSTALL_DIR" && \
     echo "bamboo.home=${BAMBOO_SERVER_HOME}" > $BAMBOO_SERVER_INSTALL_DIR/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties && \
     chown -R "${BAMBOO_USER}:${BAMBOO_GROUP}" "${BAMBOO_SERVER_INSTALL_DIR}" && \
     chown -R "${BAMBOO_USER}:${BAMBOO_GROUP}" "${BAMBOO_SERVER_HOME}"

VOLUME ["${BAMBOO_SERVER_HOME}"]
WORKDIR $BAMBOO_SERVER_HOME

USER ${BAMBOO_USER}
COPY  --chown=bamboo:bamboo entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
