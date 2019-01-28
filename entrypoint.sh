#!/bin/bash
set -e -u

# Run the cluster script, then use its vars in Etcd
bash /etcd-aws-cluster

if [ ! -f /tmp/etcd-vars ]; then
	echo "Startup failed!"
	exit 1
fi
. /tmp/etcd-vars

# Run Etcd under supervisor if that is our command.
for i in "$@"; do echo $i; done
if [ "$(basename $1)" = 'etcd' ]; then
	exec supervisord -n -c <(cat <<CONFIG
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0

[program:etcd]
user=root
command=$@
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autorestart=true
CONFIG
)
else
	exec "$@"
fi
