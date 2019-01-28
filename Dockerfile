FROM alpine:3.8

ARG ETCD_VER=v3.3.11
ENV ETCD_DATA_DIR=/var/etcd/data \
    ETCD_CLIENT_PORT=2379 \
    ETCD_SERVER_PORT=2380

RUN echo && \
  apk add --no-cache --no-progress \
    python py-pip \
    jq curl bash \
    dumb-init supervisor && \
  pip install --upgrade awscli && \
  mkdir -p /root/.aws && \
echo

RUN echo && \
  curl -v -L -o /tmp/etcd.tar.gz https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
  tar xf /tmp/etcd.tar.gz -C /usr/bin --strip-components=1 && \
  rm -f /tmp/etcd.tar.gz && \
  mkdir -p /var/etcd/data /var/etcd/config \
echo

COPY etcd-aws-cluster /etcd-aws-cluster
COPY entrypoint.sh /entrypoint.sh

# Expose volume for adding credentials
VOLUME ["/root/.aws"]

ENTRYPOINT ["/usr/bin/dumb-init", "/bin/bash", "/entrypoint.sh"]
CMD ["etcd"]

HEALTHCHECK --interval=3s --timeout=2s \
  CMD wget -U 'Docker-Healthcheck' -O /dev/null http://localhost:2379/v2/stats/self -q || exit 1
