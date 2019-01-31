FROM alpine:3.8

ARG ETCD_VER=v3.3.11
ENV ETCD_DATA_DIR=/var/etcd/data \
    ETCD_CLIENT_PORT=2379 \
    ETCD_SERVER_PORT=2380 \
    ETCD_DATA_DIR=/data

RUN echo && \
  apk add --no-cache --no-progress \
    python py-pip \
    jq curl bash \
    nodejs \
    dumb-init && \
  pip install --upgrade awscli && \
  mkdir -p /root/.aws && \
echo

COPY etcd-wrapper /usr/local/bin/etcd-wrapper
RUN echo && \
  curl -v -L -o /tmp/etcd.tar.gz https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
  tar xf /tmp/etcd.tar.gz -C /usr/bin --strip-components=1 && \
  rm -f /tmp/etcd.tar.gz && \
  mkdir -p /var/etcd/data /var/etcd/config && \
  chmod +x /usr/local/bin/etcd-wrapper && \
echo

COPY etcd-aws-cluster /etcd-aws-cluster
COPY entrypoint.sh /entrypoint.sh

# Expose volumes for credentials, persistence, certs
VOLUME ["/root/.aws", "/data", "/certs"]

ENTRYPOINT ["/usr/bin/dumb-init", "/bin/bash", "/entrypoint.sh"]
CMD ["etcd"]

HEALTHCHECK --interval=3s --timeout=2s \
  CMD wget -U 'Docker-Healthcheck' -O /dev/null http://localhost:2379/health -q | jq -e '.health == "true"' >/dev/null || exit 1
