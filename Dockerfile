FROM alpine:3.19.1

RUN apk add --no-cache curl bind-tools jq

COPY dyndns.sh /usr/bin/

ENV CRON="*/5	*	*	*	*"

CMD /bin/sh -c "echo $CRON && crontab <(echo '$CRON /bin/ash /usr/bin/dyndns.sh >> /var/log/hetzner-dyndns.log') && /usr/sbin/crond -f -d8"